import 'package:flutter/material.dart';

// Custom Exception Types
class AppException implements Exception {
  final String message;
  final String code;
  final dynamic details;

  AppException(this.message, {this.code = 'UNKNOWN_ERROR', this.details});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message, code: 'NETWORK_ERROR');
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message, code: 'VALIDATION_ERROR');
}

class PermissionException extends AppException {
  PermissionException(String message) : super(message, code: 'PERMISSION_ERROR');
}

class StorageException extends AppException {
  StorageException(String message) : super(message, code: 'STORAGE_ERROR');
}

class CameraException extends AppException {
  CameraException(String message) : super(message, code: 'CAMERA_ERROR');
}

// Error Handler Class
class ErrorHandler {
  // Error messages
  static const Map<String, String> errorMessages = {
    // Camera errors
    'CAMERA_PERMISSION_DENIED': 'Camera permission is required to take photos and videos',
    'MICROPHONE_PERMISSION_DENIED': 'Microphone permission is required for video recording',
    'CAMERA_NOT_AVAILABLE': 'Camera is not available on this device',
    'CAMERA_INITIALIZATION_FAILED': 'Failed to initialize camera. Please try again.',
    'VIDEO_RECORDING_FAILED': 'Failed to record video. Please check storage space.',
    'PHOTO_CAPTURE_FAILED': 'Failed to capture photo. Please try again.',

    // Story errors
    'STORY_CREATION_FAILED': 'Failed to create story. Please try again.',
    'STORY_LOAD_FAILED': 'Failed to load stories. Check your connection.',
    'STORY_UPDATE_FAILED': 'Failed to update story. Please try again.',
    'INVALID_STORY_CONTENT': 'Story content is invalid or too long.',
    'MEDIA_FILE_TOO_LARGE': 'Media file is too large. Please choose a smaller file.',
    'UNSUPPORTED_FILE_FORMAT': 'File format is not supported.',

    // Network errors
    'NETWORK_UNAVAILABLE': 'No internet connection available',
    'REQUEST_TIMEOUT': 'Request timed out. Please try again.',
    'SERVER_ERROR': 'Server error occurred. Please try again later.',
    'API_ERROR': 'Service is temporarily unavailable',

    // Storage errors
    'INSUFFICIENT_STORAGE': 'Insufficient storage space',
    'FILE_NOT_FOUND': 'File not found or has been deleted',
    'STORAGE_PERMISSION_DENIED': 'Storage permission is required',

    // General errors
    'UNKNOWN_ERROR': 'An unexpected error occurred',
    'OPERATION_CANCELLED': 'Operation was cancelled',
    'FEATURE_NOT_AVAILABLE': 'This feature is not available',
  };

  // ============================================================================
  // SPECIFIC ERROR MESSAGE HANDLERS
  // ============================================================================

  /// Get user-friendly error message for storage-related errors
  static String getStorageErrorMessage(dynamic error) {
    if (error.toString().contains('permission')) {
      return 'Storage permission denied. Please check app permissions.';
    } else if (error.toString().contains('space') || error.toString().contains('disk')) {
      return 'Not enough storage space available.';
    } else if (error.toString().contains('network')) {
      return 'Network error occurred while saving data.';
    }
    return 'Failed to save data. Please try again.';
  }

  /// Get user-friendly error message for image-related errors
  static String getImageErrorMessage(dynamic error) {
    if (error.toString().contains('permission')) {
      return 'Camera/Gallery permission denied. Please check app permissions.';
    } else if (error.toString().contains('camera')) {
      return 'Camera is not available. Please try using gallery.';
    } else if (error.toString().contains('file')) {
      return 'Failed to access the selected image file.';
    }
    return 'Failed to select image. Please try again.';
  }

  /// Get user-friendly error message for image cropping errors
  static String getImageCropErrorMessage(dynamic error) {
    if (error.toString().contains('cancelled')) {
      return 'Image cropping was cancelled.';
    } else if (error.toString().contains('memory')) {
      return 'Not enough memory to crop image. Try a smaller image.';
    }
    return 'Failed to crop image. Please try again.';
  }

  /// Get validation error message for specific fields
  static String getValidationErrorMessage(String field) {
    switch (field.toLowerCase()) {
      case 'name':
      case 'fullname':
        return 'Please enter your name';
      case 'shopname':
        return 'Please enter shop name';
      case 'phone':
      case 'mobile':
        return 'Please enter a valid phone number';
      case 'address':
        return 'Please enter your address';
      case 'timings':
        return 'Please enter shop timings';
      default:
        return 'This field is required';
    }
  }

  // Get user-friendly error message
  static String getUserMessage(dynamic error) {
    if (error is AppException) {
      return errorMessages[error.code] ?? error.message;
    }

    if (error is String) {
      return error;
    }

    return errorMessages['UNKNOWN_ERROR']!;
  }

  // ============================================================================
  // SNACKBAR NOTIFICATIONS
  // ============================================================================

  /// Show error snackbar with enhanced styling
  static void showError(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show info snackbar
  static void showInfo(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show warning snackbar
  static void showWarning(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show error snackbar
  static void showErrorSnackBar(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getUserMessage(error)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // ============================================================================
  // DIALOG HELPERS
  // ============================================================================

  /// Show confirmation dialog
  static Future<bool> showConfirmDialog(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = 'Confirm',
        String cancelText = 'Cancel',
      }) async {
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Show error dialog
  static void showErrorDialog(BuildContext context, dynamic error, {String? title}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Error'),
        content: Text(getUserMessage(error)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(
              child: Text(message ?? 'Please wait...'),
            ),
          ],
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  // Handle and log error
  static void handleError(dynamic error, {String? context}) {
    // Log error (in production, use proper logging service)
    debugPrint('Error in $context: ${error.toString()}');

    // In production, send to crash reporting service
    // crashlytics.recordError(error, stackTrace, context: context);
  }

  // Retry wrapper for operations
  static Future<T?> retryOperation<T>(
      Future<T> Function() operation, {
        int maxRetries = 3,
        Duration delay = const Duration(seconds: 1),
      }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        return await operation();
      } catch (e) {
        if (i == maxRetries - 1) {
          rethrow;
        }
        await Future.delayed(delay);
      }
    }
    return null;
  }

  // Permission error helper
  static PermissionException createPermissionError(String permission) {
    switch (permission.toLowerCase()) {
      case 'camera':
        return PermissionException(errorMessages['CAMERA_PERMISSION_DENIED']!);
      case 'microphone':
        return PermissionException(errorMessages['MICROPHONE_PERMISSION_DENIED']!);
      case 'storage':
        return PermissionException(errorMessages['STORAGE_PERMISSION_DENIED']!);
      default:
        return PermissionException('Permission required: $permission');
    }
  }

  // Network error helper
  static NetworkException createNetworkError(String type) {
    switch (type.toLowerCase()) {
      case 'timeout':
        return NetworkException(errorMessages['REQUEST_TIMEOUT']!);
      case 'unavailable':
        return NetworkException(errorMessages['NETWORK_UNAVAILABLE']!);
      case 'server':
        return NetworkException(errorMessages['SERVER_ERROR']!);
      default:
        return NetworkException(errorMessages['API_ERROR']!);
    }
  }
}

class ListingErrorHandler {
  // ============================================================================
  // LISTING SPECIFIC ERROR HANDLERS
  // ============================================================================

  /// Handle listing storage errors
  static String handleStorageError(dynamic error) {
    if (error.toString().contains('permission')) {
      return 'Unable to save listings. Please check app permissions.';
    } else if (error.toString().contains('space') || error.toString().contains('disk')) {
      return 'Not enough storage space to save listings.';
    } else if (error.toString().contains('network')) {
      return 'Network error while saving listings.';
    }
    return 'Failed to save listings. Please try again.';
  }

  /// Handle listing add errors
  static String handleAddError(dynamic error) {
    if (error.toString().contains('duplicate')) {
      return 'A listing with this information already exists.';
    } else if (error.toString().contains('validation')) {
      return 'Please check all required fields are filled correctly.';
    }
    return 'Failed to add listing. Please try again.';
  }

  /// Handle listing update errors
  static String handleUpdateError(dynamic error) {
    if (error.toString().contains('not found')) {
      return 'This listing no longer exists and cannot be updated.';
    } else if (error.toString().contains('concurrent')) {
      return 'This listing was modified by another process. Please refresh and try again.';
    }
    return 'Failed to update listing. Please try again.';
  }

  /// Handle listing delete errors
  static String handleDeleteError(dynamic error) {
    if (error.toString().contains('not found')) {
      return 'This listing has already been deleted.';
    } else if (error.toString().contains('in use')) {
      return 'Cannot delete listing as it is currently in use.';
    }
    return 'Failed to delete listing. Please try again.';
  }

  /// Handle image related errors specific to listings
  static String handleImageError(dynamic error) {
    if (error.toString().contains('limit')) {
      return 'Maximum 5 images allowed per listing.';
    } else if (error.toString().contains('size')) {
      return 'Image file is too large. Please select a smaller image.';
    } else if (error.toString().contains('format')) {
      return 'Unsupported image format. Please use JPG or PNG.';
    }
    return ErrorHandler.getImageErrorMessage(error);
  }

  /// Get validation error for listing fields
  static String getListingValidationError(String field) {
    switch (field.toLowerCase()) {
      case 'title':
        return 'Please enter a title for your listing';
      case 'price':
        return 'Please enter a valid price';
      case 'experience':
        return 'Please enter your experience level';
      case 'warranty':
        return 'Please enter warranty information';
      case 'description':
        return 'Please provide a description';
      case 'status':
        return 'Please select a status';
      case 'type':
        return 'Please select listing type';
      case 'images':
        return 'Please add at least one image';
      default:
        return ErrorHandler.getValidationErrorMessage(field);
    }
  }

  // ============================================================================
  // LISTING SNACKBAR NOTIFICATIONS
  // ============================================================================

  /// Show listing operation success
  static void showListingSuccess(BuildContext context, String operation) {
    final message = _getSuccessMessage(operation);
    ErrorHandler.showSuccess(context, message);
  }

  /// Show listing operation error
  static void showListingError(BuildContext context, String operation, dynamic error) {
    final message = _getOperationErrorMessage(operation, error);
    ErrorHandler.showError(context, message);
  }

  /// Show listing validation error
  static void showValidationError(BuildContext context, String field) {
    final message = getListingValidationError(field);
    ErrorHandler.showError(context, message);
  }

  /// Show image operation error
  static void showImageError(BuildContext context, dynamic error) {
    final message = handleImageError(error);
    ErrorHandler.showError(context, message);
  }

  // ============================================================================
  // CONFIRMATION DIALOGS
  // ============================================================================

  /// Show delete listing confirmation
  static Future<bool> showDeleteConfirmation(BuildContext context, String listingTitle) async {
    return await ErrorHandler.showConfirmDialog(
      context,
      title: 'Delete Listing',
      message: 'Are you sure you want to delete "$listingTitle"? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );
  }

  /// Show clear all listings confirmation
  static Future<bool> showClearAllConfirmation(BuildContext context) async {
    return await ErrorHandler.showConfirmDialog(
      context,
      title: 'Clear All Listings',
      message: 'Are you sure you want to delete all listings? This action cannot be undone.',
      confirmText: 'Clear All',
      cancelText: 'Cancel',
    );
  }

  /// Show unsaved changes dialog
  static Future<bool> showUnsavedChangesDialog(BuildContext context) async {
    return await ErrorHandler.showConfirmDialog(
      context,
      title: 'Unsaved Changes',
      message: 'You have unsaved changes. Do you want to discard them?',
      confirmText: 'Discard',
      cancelText: 'Keep Editing',
    );
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  static String _getSuccessMessage(String operation) {
    switch (operation) {
      case 'add':
        return 'Listing added successfully!';
      case 'update':
        return 'Listing updated successfully!';
      case 'delete':
        return 'Listing deleted successfully!';
      case 'clear':
        return 'All listings cleared successfully!';
      default:
        return 'Operation completed successfully!';
    }
  }

  static String _getOperationErrorMessage(String operation, dynamic error) {
    switch (operation) {
      case 'add':
        return handleAddError(error);
      case 'update':
        return handleUpdateError(error);
      case 'delete':
        return handleDeleteError(error);
      case 'load':
        return handleStorageError(error);
      default:
        return 'Operation failed. Please try again.';
    }
  }
}