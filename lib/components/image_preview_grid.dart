import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_business_app/services/image_service.dart';
import 'package:my_business_app/utils/sizing.dart';
import 'package:my_business_app/utils/listing_constants.dart';
import 'package:my_business_app/utils/error_handling.dart';

class ImagePreviewGrid extends StatelessWidget {
  final List<String> imagePaths;
  final ValueChanged<List<String>> onImagesChanged;
  final bool enabled;

  const ImagePreviewGrid({
    super.key,
    required this.imagePaths,
    required this.onImagesChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              ListingConstants.fieldLabels["images"]!,
              style: TextStyle(fontSize: AppSizing.fontSize(16)),
            ),
            Text(
              '${imagePaths.length}/${ListingConstants.maxImages}',
              style: TextStyle(
                fontSize: AppSizing.fontSize(14),
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizing.md),

        if (imagePaths.isEmpty && enabled)
          _buildEmptyState(context)
        else
          _buildImageGrid(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(context),
      child: Container(
        height: AppSizing.width(32),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          color: Colors.grey.shade50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: AppSizing.width(8),
              color: Colors.grey.shade500,
            ),
            SizedBox(height: AppSizing.sm),
            Text(
              "Tap to add photos",
              style: TextStyle(
                fontSize: AppSizing.fontSize(14),
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    final crossAxisCount = AppSizing.isSmallScreen ? 3 : 4;
    final itemCount = imagePaths.length +
        (imagePaths.length < ListingConstants.maxImages && enabled ? 1 : 0);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSizing.sm,
        mainAxisSpacing: AppSizing.sm,
        childAspectRatio: 1.0,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < imagePaths.length) {
          return _buildImageTile(context, index);
        } else {
          return _buildAddImageTile(context);
        }
      },
    );
  }

  Widget _buildImageTile(BuildContext context, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizing.radiusMd - 1),
            child: Image.file(
              File(imagePaths[index]),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade100,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.red.shade300,
                  size: AppSizing.width(8),
                ),
              ),
            ),
          ),
        ),
        if (enabled)
          Positioned(
            top: AppSizing.xs,
            right: AppSizing.xs,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: EdgeInsets.all(AppSizing.xs / 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: AppSizing.fontSize(16),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddImageTile(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(context),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          color: Colors.grey.shade50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: AppSizing.width(8),
              color: Colors.grey.shade500,
            ),
            SizedBox(height: AppSizing.xs),
            Text(
              "Add",
              style: TextStyle(
                fontSize: AppSizing.fontSize(12),
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    if (imagePaths.length >= ListingConstants.maxImages) {
      ListingErrorHandler.showImageError(
        context,
        'Maximum ${ListingConstants.maxImages} images allowed',
      );
      return;
    }

    ImageService.instance.showImageSourceDialog(
      context: context,
      onSourceSelected: (source) => _pickImage(context, source),
      imageTypeName: 'listing image',
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final result = await ImageService.instance.pickImage(
        source: source,
        imageType: ImageType.cover, // Use cover type for listing images
        autoCrop: true,
      );

      if (result.isSuccess && result.imageFile != null) {
        final updatedPaths = List<String>.from(imagePaths)
          ..add(result.imageFile!.path);
        onImagesChanged(updatedPaths);
      } else if (!result.isCancelled && result.errorMessage != null) {
        ListingErrorHandler.showImageError(context, result.errorMessage!);
      }
    } catch (e) {
      ListingErrorHandler.showImageError(context, e);
    }
  }

  void _removeImage(int index) {
    final updatedPaths = List<String>.from(imagePaths)..removeAt(index);
    onImagesChanged(updatedPaths);
  }
}

class ImagePreviewWidget extends StatelessWidget {
  final List<String> imagePaths;
  final double? size;
  final VoidCallback? onTap;

  const ImagePreviewWidget({
    super.key,
    required this.imagePaths,
    this.size,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageSize = size ?? AppSizing.width(20);

    if (imagePaths.isEmpty) {
      return _buildEmptyImage(imageSize);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: imageSize,
        height: imageSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd - 1),
          child: Stack(
            children: [
              Image.file(
                File(imagePaths.first),
                fit: BoxFit.cover,
                width: imageSize,
                height: imageSize,
                errorBuilder: (_, __, ___) => _buildEmptyImage(imageSize),
              ),
              if (imagePaths.length > 1)
                Positioned(
                  bottom: AppSizing.xs,
                  right: AppSizing.xs,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizing.xs,
                      vertical: AppSizing.xs / 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(AppSizing.radiusXs + 2),
                    ),
                    child: Text(
                      '+${imagePaths.length - 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppSizing.fontSize(10),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyImage(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
      ),
      child: Icon(
        Icons.image_outlined,
        size: size * 0.6,
        color: Colors.grey.shade400,
      ),
    );
  }
}