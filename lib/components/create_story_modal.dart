import 'package:flutter/material.dart';
import 'package:my_business_app/utils/sizing.dart';
import 'package:my_business_app/utils/app_icons.dart';
import 'package:my_business_app/utils/validators.dart';
import 'package:my_business_app/utils/error_handling.dart';
import 'package:my_business_app/components/input_field.dart';
import 'package:my_business_app/services/story_service.dart';
import 'package:my_business_app/services/camera_service.dart';

class CreateStoryModal extends StatefulWidget {
  final Function(Story)? onStoryCreated;

  const CreateStoryModal({
    Key? key,
    this.onStoryCreated,
  }) : super(key: key);

  @override
  State<CreateStoryModal> createState() => _CreateStoryModalState();
}

class _CreateStoryModalState extends State<CreateStoryModal> {
  final TextEditingController _textController = TextEditingController();
  final StoryService _storyService = StoryService();
  final CameraService _cameraService = CameraService();

  bool _isLoading = false;
  String? _selectedImagePath;
  String? _selectedVideoPath;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppSpacing.initialize(context);

    return Container(
      height: AppSpacing.height(60), // 60% of screen height
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),

          AppSpacing.verticalSpaceMd,

          // Creation options
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCreationOptions(),
                  AppSpacing.verticalSpaceMd,
                  _buildTextStorySection(),
                ],
              ),
            ),
          ),

          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Create Story',
          style: TextStyle(
            fontSize: AppSpacing.width(5.3), // ~20px
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            AppIcons.close,
            size: AppSpacing.iconMd,
          ),
        ),
      ],
    );
  }

  Widget _buildCreationOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose how to create your story',
          style: TextStyle(
            fontSize: AppSpacing.width(4), // ~15px
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),

        AppSpacing.verticalSpaceMd,

        // Option buttons
        Row(
          children: [
            Expanded(
              child: _buildOptionButton(
                icon: AppIcons.camera,
                label: 'Camera',
                onTap: _openCamera,
                color: Colors.blue,
              ),
            ),
            AppSpacing.horizontalSpaceMd,
            Expanded(
              child: _buildOptionButton(
                icon: AppIcons.gallery,
                label: 'Gallery',
                onTap: _openGallery,
                color: Colors.green,
              ),
            ),
          ],
        ),

        AppSpacing.verticalSpaceMd,

        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: AppSpacing.paddingHorizontalMd,
              child: Text(
                'or',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: AppSpacing.width(3.7), // ~14px
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: AppSpacing.width(13.3), // ~50px
              height: AppSpacing.width(13.3),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: AppSpacing.iconMd,
              ),
            ),
            AppSpacing.verticalSpaceSm,
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppSpacing.width(3.7), // ~14px
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextStorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Write a text story',
          style: TextStyle(
            fontSize: AppSpacing.width(4.3), // ~16px
            fontWeight: FontWeight.bold,
          ),
        ),

        AppSpacing.verticalSpaceSm,

        // Text input field
        CustomInputField(
          controller: _textController,
          labelText: 'What\'s happening in your business?',
          maxLength: StoryValidators.maxContentLength,
          keyboardType: TextInputType.multiline,
          validator: StoryValidators.validateStoryContent,
        ),

        AppSpacing.verticalSpaceMd,

        // Character count
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_textController.text.length}/${StoryValidators.maxContentLength}',
            style: TextStyle(
              color: _textController.text.length > StoryValidators.maxContentLength * 0.9
                  ? Colors.red
                  : Colors.grey[600],
              fontSize: AppSpacing.width(3.2), // ~12px
            ),
          ),
        ),

        AppSpacing.verticalSpaceMd,

        // Post button
        SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createTextStory,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: _isLoading
                ? SizedBox(
              width: AppSpacing.iconSm,
              height: AppSpacing.iconSm,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(
              'Post Story',
              style: TextStyle(
                fontSize: AppSpacing.width(4.3), // ~16px
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openCamera() async {
    try {
      Navigator.pop(context); // Close modal first

      final success = await _cameraService.initialize();
      if (!success) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(
            context,
            CameraException('Failed to initialize camera'),
          );
        }
        return;
      }

      if (mounted) {
        final result = await Navigator.push<MediaFile>(
          context,
          MaterialPageRoute(
            builder: (context) => CameraPage(
              cameraService: _cameraService,
            ),
          ),
        );

        if (result != null) {
          await _createMediaStory(result);
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
    }
  }

  Future<void> _openGallery() async {
    // Gallery functionality would be implemented here
    // For now, show a placeholder message
    ErrorHandler.showErrorSnackBar(
      context,
      'Gallery selection will be implemented soon',
    );
  }

  Future<void> _createTextStory() async {
    final content = _textController.text.trim();

    // Validate content
    final validationError = StoryValidators.validateStoryContent(content);
    if (validationError != null) {
      ErrorHandler.showErrorSnackBar(context, ValidationException(validationError));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _storyService.createStory(content: content);

      if (success && _storyService.currentStory != null) {
        widget.onStoryCreated?.call(_storyService.currentStory!);

        if (mounted) {
          Navigator.pop(context);
          ErrorHandler.showSuccessSnackBar(context, 'Story posted successfully!');
        }
      } else {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(
            context,
            AppException('Failed to create story. Please try again.'),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createMediaStory(MediaFile mediaFile) async {
    try {
      setState(() => _isLoading = true);

      // Validate media file
      final isValid = await _cameraService.validateMediaFile(mediaFile);
      if (!isValid) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(
            context,
            ValidationException('Invalid media file. Please try again.'),
          );
        }
        return;
      }

      final success = await _storyService.createStory(
        content: mediaFile.isVideo ? 'Shared a video story' : 'Shared a photo story',
        imagePath: mediaFile.isImage ? mediaFile.path : null,
        videoPath: mediaFile.isVideo ? mediaFile.path : null,
      );

      if (success && _storyService.currentStory != null) {
        widget.onStoryCreated?.call(_storyService.currentStory!);

        if (mounted) {
          ErrorHandler.showSuccessSnackBar(
            context,
            '${mediaFile.isVideo ? 'Video' : 'Photo'} story created successfully!',
          );
        }
      } else {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(
            context,
            AppException('Failed to create story. Please try again.'),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Camera page placeholder (simplified version)
class CameraPage extends StatelessWidget {
  final CameraService cameraService;

  const CameraPage({
    Key? key,
    required this.cameraService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Camera', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Text(
          'Camera interface will be implemented here',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}