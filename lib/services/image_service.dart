import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_business_app/services/image_cropper_service.dart';
import 'package:my_business_app/utils/error_handling.dart';

enum ImageType { profile, cover }

class ImageService {
  static ImageService? _instance;
  static ImageService get instance => _instance ??= ImageService._();
  ImageService._();

  final ImagePicker _picker = ImagePicker();

  Future<ImagePickResult> pickImage({
    required ImageSource source,
    required ImageType imageType,
    bool autoCrop = true,
    BuildContext? context,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: _getMaxWidth(imageType),
        maxHeight: _getMaxHeight(imageType),
        imageQuality: _getImageQuality(imageType),
      );

      if (pickedFile == null) {
        return ImagePickResult.cancelled();
      }

      File imageFile = File(pickedFile.path);

      // Auto-crop if enabled
      if (autoCrop) {
        final cropResult = await ImageCropperService.instance.cropImage(
          imagePath: pickedFile.path,
          imageType: imageType,
          context: context,
        );

        if (cropResult.isSuccess && cropResult.croppedFile != null) {
          imageFile = File(cropResult.croppedFile!.path);
        } else if (!cropResult.isSuccess) {
          return ImagePickResult.error(cropResult.errorMessage!);
        }
      }

      return ImagePickResult.success(imageFile);
    } catch (e) {
      return ImagePickResult.error(ErrorHandler.getImageErrorMessage(e));
    }
  }

  Future<void> showImageSourceDialog({
    required BuildContext context,
    required Function(ImageSource) onSourceSelected,
    File? currentImage,
    String? imageTypeName,
  }) async {
    final typeName = imageTypeName ?? 'image';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                onSourceSelected(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                onSourceSelected(ImageSource.gallery);
              },
            ),
            if (currentImage != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: Text('Remove $typeName'),
                onTap: () {
                  Navigator.pop(context);
                  onSourceSelected(ImageSource.gallery); // This will be handled differently
                },
              ),
          ],
        ),
      ),
    );
  }

  double _getMaxWidth(ImageType imageType) {
    switch (imageType) {
      case ImageType.cover:
        return 1200.0;
      case ImageType.profile:
        return 800.0;
    }
  }

  double _getMaxHeight(ImageType imageType) {
    switch (imageType) {
      case ImageType.cover:
        return 800.0;
      case ImageType.profile:
        return 800.0;
    }
  }

  int _getImageQuality(ImageType imageType) {
    switch (imageType) {
      case ImageType.cover:
        return 85;
      case ImageType.profile:
        return 90;
    }
  }

  Future<bool> deleteImageFile(File? imageFile) async {
    if (imageFile == null) return true;

    try {
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<ImageValidationResult> validateImage(File imageFile) async {
    try {
      // Check if file exists
      if (!await imageFile.exists()) {
        return ImageValidationResult.error('Image file does not exist');
      }

      // Check file size (max 10MB)
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        return ImageValidationResult.error('Image file too large (max 10MB)');
      }

      // Check file extension
      final extension = imageFile.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png'].contains(extension)) {
        return ImageValidationResult.error('Unsupported image format');
      }

      return ImageValidationResult.success();
    } catch (e) {
      return ImageValidationResult.error('Error validating image: ${e.toString()}');
    }
  }
}

class ImagePickResult {
  final bool isSuccess;
  final bool isCancelled;
  final File? imageFile;
  final String? errorMessage;

  ImagePickResult._(this.isSuccess, this.isCancelled, this.imageFile, this.errorMessage);

  factory ImagePickResult.success(File imageFile) =>
      ImagePickResult._(true, false, imageFile, null);

  factory ImagePickResult.cancelled() =>
      ImagePickResult._(false, true, null, null);

  factory ImagePickResult.error(String message) =>
      ImagePickResult._(false, false, null, message);
}

class ImageValidationResult {
  final bool isSuccess;
  final String? errorMessage;

  ImageValidationResult._(this.isSuccess, this.errorMessage);

  factory ImageValidationResult.success() => ImageValidationResult._(true, null);
  factory ImageValidationResult.error(String message) => ImageValidationResult._(false, message);
}