import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:my_business_app/services/image_service.dart';
import 'package:my_business_app/utils/error_handling.dart';

class ImageCropperService {
  static ImageCropperService? _instance;
  static ImageCropperService get instance => _instance ??= ImageCropperService._();
  ImageCropperService._();

  Future<CropResult> cropImage({
    required String imagePath,
    required ImageType imageType,
    BuildContext? context,
  }) async {
    try {
      // Validate image path
      if (imagePath.isEmpty) {
        return CropResult.error('Invalid image path provided');
      }

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: _getCompressQuality(imageType),
        uiSettings: _getUiSettings(imageType, context),
      );

      if (croppedFile != null) {
        return CropResult.success(croppedFile);
      } else {
        return CropResult.cancelled();
      }
    } catch (e) {
      print('Image crop error: $e'); // Debug log
      return CropResult.error(ErrorHandler.getImageCropErrorMessage(e));
    }
  }

  List<PlatformUiSettings> _getUiSettings(ImageType imageType, BuildContext? context) {
    final isProfileImage = imageType == ImageType.profile;
    final title = isProfileImage ? 'Crop Profile Picture' : 'Crop Cover Photo';

    return [
      AndroidUiSettings(
        toolbarTitle: title,
        toolbarColor: const Color(0xFF4A72DA),
        toolbarWidgetColor: Colors.white,
        initAspectRatio: isProfileImage
            ? CropAspectRatioPreset.square
            : CropAspectRatioPreset.ratio16x9,
        lockAspectRatio: isProfileImage,
        aspectRatioPresets: _getAspectRatioPresets(imageType),
        backgroundColor: Colors.white,
        cropFrameColor: const Color(0xFF4A72DA),
        cropGridColor: Colors.white.withOpacity(0.8),
        dimmedLayerColor: Colors.black.withOpacity(0.6),
        hideBottomControls: false,
        showCropGrid: true,
      ),
      IOSUiSettings(
        title: title,
        aspectRatioLockEnabled: isProfileImage,
        resetAspectRatioEnabled: !isProfileImage,
        aspectRatioPresets: _getAspectRatioPresets(imageType),
        minimumAspectRatio: isProfileImage ? 1.0 : 0.5,
      ),
    ];
  }

  List<CropAspectRatioPreset> _getAspectRatioPresets(ImageType imageType) {
    if (imageType == ImageType.profile) {
      return [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.original,
      ];
    } else {
      return [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio16x9,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio3x2,
      ];
    }
  }

  int _getCompressQuality(ImageType imageType) {
    switch (imageType) {
      case ImageType.profile:
        return 90; // Higher quality for profile images
      case ImageType.cover:
        return 85; // Slightly lower for cover images due to larger size
    }
  }

  Future<bool> isImageCropperAvailable() async {
    try {
      // Try to initialize image cropper
      return true;
    } catch (e) {
      return false;
    }
  }
}

class CropResult {
  final bool isSuccess;
  final bool isCancelled;
  final CroppedFile? croppedFile;
  final String? errorMessage;

  CropResult._(this.isSuccess, this.isCancelled, this.croppedFile, this.errorMessage);

  factory CropResult.success(CroppedFile croppedFile) =>
      CropResult._(true, false, croppedFile, null);

  factory CropResult.cancelled() =>
      CropResult._(false, true, null, null);

  factory CropResult.error(String message) =>
      CropResult._(false, false, null, message);
}