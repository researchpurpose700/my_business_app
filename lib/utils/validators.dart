import 'dart:io';

class Validators {
  // ============================================================================
  // MOBILE NUMBER VALIDATION
  // ============================================================================

  /// Validates Indian mobile number (starts with 6,7,8,9 and 10 digits)
  static String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    }

    if (value.length != 10) {
      return 'Mobile number must be 10 digits';
    }

    final pattern = RegExp(r'^[6-9]\d{9}$');
    if (!pattern.hasMatch(value)) {
      return 'Mobile must start with 6, 7, 8, or 9';
    }

    return null;
  }

  /// Check if mobile is valid (for auto OTP trigger)
  static bool isValidMobile(String value) {
    final pattern = RegExp(r'^[6-9]\d{9}$');
    return value.length == 10 && pattern.hasMatch(value);
  }

  /// Validates phone number (alias for mobile validation)
  static String? validatePhone(String? value) {
    return validateMobile(value);
  }

  // ============================================================================
  // OTP VALIDATION
  // ============================================================================

  /// Validates 6-digit OTP
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the OTP';
    }

    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }

    final pattern = RegExp(r'^\d{6}$');
    if (!pattern.hasMatch(value)) {
      return 'OTP must contain only numbers';
    }

    return null;
  }

  // ============================================================================
  // NAME VALIDATION
  // ============================================================================

  /// Validates full name for registration
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }

    // Check for valid characters (letters, spaces, and common name characters)
    final pattern = RegExp(r"^[a-zA-Z\s\.''-]+$");
    if (!pattern.hasMatch(value.trim())) {
      return 'Name can only contain letters and common punctuation';
    }

    return null;
  }

  /// Validates name (alias for full name validation)
  static String? validateName(String? value) {
    return validateFullName(value);
  }

  // ============================================================================
  // BUSINESS/SHOP VALIDATION
  // ============================================================================

  /// Validates shop/business name for registration
  static String? validateShopName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your shop/business name';
    }

    if (value.trim().length < 2) {
      return 'Shop name must be at least 2 characters';
    }

    if (value.trim().length > 100) {
      return 'Shop name must be less than 100 characters';
    }

    // Allow letters, numbers, spaces, and common business name characters
    final pattern = RegExp(r"^[a-zA-Z0-9\s\.'&-]+$");
    if (!pattern.hasMatch(value.trim())) {
      return 'Shop name contains invalid characters';
    }

    return null;
  }

  /// Validates service category selection
  static String? validateServiceCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your business category';
    }

    return null;
  }

  // ============================================================================
  // ADDRESS VALIDATION
  // ============================================================================

  /// Validates address
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your address';
    }

    if (value.trim().length < 5) {
      return 'Address must be at least 5 characters';
    }

    if (value.trim().length > 200) {
      return 'Address must be less than 200 characters';
    }

    // Allow letters, numbers, spaces, and common address characters
    final pattern = RegExp(r"^[a-zA-Z0-9\s\.,#\-/()]+$");
    if (!pattern.hasMatch(value.trim())) {
      return 'Address contains invalid characters';
    }

    return null;
  }

  // ============================================================================
  // TIMINGS VALIDATION
  // ============================================================================

  /// Validates shop timings
  static String? validateTimings(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your shop timings';
    }

    if (value.trim().length < 3) {
      return 'Timings must be at least 3 characters';
    }

    if (value.trim().length > 100) {
      return 'Timings must be less than 100 characters';
    }

    // Allow letters, numbers, spaces, and common timing characters (AM/PM, colons, dashes)
    final pattern = RegExp(r"^[a-zA-Z0-9\s\.:,\-–—]+$");
    if (!pattern.hasMatch(value.trim())) {
      return 'Timings contain invalid characters';
    }

    return null;
  }

  // ============================================================================
  // FORM COMPLETION VALIDATION
  // ============================================================================

  /// Check if all registration fields are valid for auto-submit
  static bool isRegistrationFormComplete({
    required String fullName,
    required String shopName,
    required String mobile,
    required String? serviceCategory,
  }) {
    return validateFullName(fullName) == null &&
        validateShopName(shopName) == null &&
        validateServiceCategory(serviceCategory) == null &&
        isValidMobile(mobile);
  }

  /// Check if all profile fields are valid
  static bool isProfileFormComplete({
    required String fullName,
    required String shopName,
    required String phone,
    required String address,
    required String timings,
  }) {
    return validateName(fullName) == null &&
        validateShopName(shopName) == null &&
        validatePhone(phone) == null &&
        validateAddress(address) == null &&
        validateTimings(timings) == null;
  }
}

class ListingValidators {
  // ============================================================================
  // LISTING FIELD VALIDATION
  // ============================================================================

  /// Validates listing title
  static String? validateTitle(String? value, String listingType) {
    if (value == null || value.trim().isEmpty) {
      return listingType == "Seller"
          ? 'Please enter product name'
          : 'Please enter service name';
    }

    if (value.trim().length < 2) {
      return 'Title must be at least 2 characters';
    }

    if (value.trim().length > 50) {
      return 'Title must be less than 50 characters';
    }

    // Allow letters, numbers, spaces, and common business characters
    final pattern = RegExp(r"^[a-zA-Z0-9\s\.'&-]+$");
    if (!pattern.hasMatch(value.trim())) {
      return 'Title contains invalid characters';
    }

    return null;
  }

  /// Validates price
  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter price';
    }

    final intPrice = int.tryParse(value.trim());
    if (intPrice == null) {
      return 'Please enter a valid number';
    }

    if (intPrice <= 0) {
      return 'Price must be greater than 0';
    }

    if (intPrice > 99999) {
      return 'Maximum price is ₹99,999';
    }

    return null;
  }

  /// Validates experience (for services)
  static String? validateExperience(String? value, String listingType) {
    if (listingType != "Service") return null;

    if (value == null || value.trim().isEmpty) {
      return 'Please enter your experience';
    }

    if (value.trim().length < 1) {
      return 'Experience is required';
    }

    if (value.trim().length > 8) {
      return 'Experience must be 8 characters or less';
    }

    return null;
  }

  /// Validates warranty
  static String? validateWarranty(String? value, String listingType) {
    // Warranty is optional for services, required for products
    if (listingType == "Service") {
      // Optional validation for services
      if (value != null && value.trim().isNotEmpty) {
        if (value.trim().length > 8) {
          return 'Warranty must be 8 characters or less';
        }
      }
      return null;
    }

    // Required for products (sellers)
    if (value == null || value.trim().isEmpty) {
      return 'Please enter warranty information';
    }

    if (value.trim().length > 8) {
      return 'Warranty must be 8 characters or less';
    }

    return null;
  }

  /// Validates description
  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please provide a description';
    }

    if (value.trim().length < 10) {
      return 'Description must be at least 10 characters';
    }

    if (value.trim().length > 300) {
      return 'Description must be 300 characters or less';
    }

    return null;
  }

  /// Validates status selection
  static String? validateStatus(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a status';
    }

    const validStatuses = ["In Stock", "Out of Stock", "Available", "Busy"];
    if (!validStatuses.contains(value)) {
      return 'Please select a valid status';
    }

    return null;
  }

  /// Validates listing type
  static String? validateListingType(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select listing type';
    }

    const validTypes = ["Seller", "Service"];
    if (!validTypes.contains(value)) {
      return 'Please select a valid listing type';
    }

    return null;
  }

  /// Validates image list
  static String? validateImages(List<String> imagePaths, {bool requireAtLeastOne = false}) {
    if (requireAtLeastOne && imagePaths.isEmpty) {
      return 'Please add at least one image';
    }

    if (imagePaths.length > 5) {
      return 'Maximum 5 images allowed';
    }

    return null;
  }

  // ============================================================================
  // CHARACTER COUNT HELPERS
  // ============================================================================

  /// Get character count info for title
  static CharacterCountInfo getTitleCharacterInfo(String value) {
    const maxLength = 50;
    final remaining = maxLength - value.length;
    return CharacterCountInfo(
      current: value.length,
      max: maxLength,
      remaining: remaining,
      isWarning: remaining <= 10,
      isDanger: remaining <= 5,
    );
  }

  /// Get character count info for experience
  static CharacterCountInfo getExperienceCharacterInfo(String value) {
    const maxLength = 8;
    final remaining = maxLength - value.length;
    return CharacterCountInfo(
      current: value.length,
      max: maxLength,
      remaining: remaining,
      isWarning: remaining <= 2,
      isDanger: remaining <= 0,
    );
  }

  /// Get character count info for warranty
  static CharacterCountInfo getWarrantyCharacterInfo(String value) {
    const maxLength = 8;
    final remaining = maxLength - value.length;
    return CharacterCountInfo(
      current: value.length,
      max: maxLength,
      remaining: remaining,
      isWarning: remaining <= 2,
      isDanger: remaining <= 0,
    );
  }

  /// Get character count info for description
  static CharacterCountInfo getDescriptionCharacterInfo(String value) {
    const maxLength = 300;
    final remaining = maxLength - value.length;
    return CharacterCountInfo(
      current: value.length,
      max: maxLength,
      remaining: remaining,
      isWarning: remaining <= 30,
      isDanger: remaining <= 10,
    );
  }

  // ============================================================================
  // FORM COMPLETION VALIDATION
  // ============================================================================

  /// Check if listing form is complete and valid
  static bool isListingFormValid({
    required String title,
    required String price,
    required String description,
    required String status,
    required String listingType,
    String? experience,
    String? warranty,
    List<String>? imagePaths,
    bool requireImages = false,
  }) {
    return validateTitle(title, listingType) == null &&
        validatePrice(price) == null &&
        validateDescription(description) == null &&
        validateStatus(status) == null &&
        validateListingType(listingType) == null &&
        validateExperience(experience, listingType) == null &&
        validateWarranty(warranty, listingType) == null &&
        validateImages(imagePaths ?? [], requireAtLeastOne: requireImages) == null;
  }

  /// Get all validation errors for a listing
  static Map<String, String> getAllValidationErrors({
    required String title,
    required String price,
    required String description,
    required String status,
    required String listingType,
    String? experience,
    String? warranty,
    List<String>? imagePaths,
    bool requireImages = false,
  }) {
    final errors = <String, String>{};

    final titleError = validateTitle(title, listingType);
    if (titleError != null) errors['title'] = titleError;

    final priceError = validatePrice(price);
    if (priceError != null) errors['price'] = priceError;

    final descError = validateDescription(description);
    if (descError != null) errors['description'] = descError;

    final statusError = validateStatus(status);
    if (statusError != null) errors['status'] = statusError;

    final typeError = validateListingType(listingType);
    if (typeError != null) errors['type'] = typeError;

    final expError = validateExperience(experience, listingType);
    if (expError != null) errors['experience'] = expError;

    final warrantyError = validateWarranty(warranty, listingType);
    if (warrantyError != null) errors['warranty'] = warrantyError;

    final imageError = validateImages(imagePaths ?? [], requireAtLeastOne: requireImages);
    if (imageError != null) errors['images'] = imageError;

    return errors;
  }
}

/// Helper class for character count information
class CharacterCountInfo {
  final int current;
  final int max;
  final int remaining;
  final bool isWarning;
  final bool isDanger;

  CharacterCountInfo({
    required this.current,
    required this.max,
    required this.remaining,
    required this.isWarning,
    required this.isDanger,
  });

  String get displayText => '$remaining characters left';

  bool get isValid => remaining >= 0;
}

// Story Content Validation
class StoryValidators {
  // Text content limits
  static const int minContentLength = 3;
  static const int maxContentLength = 280;

  // Video limits
  static const int maxVideoSeconds = 30;
  static const double maxVideoSizeMB = 50.0;

  // Image limits
  static const double maxImageSizeMB = 10.0;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedVideoFormats = ['mp4', 'mov', 'avi'];

  // Text content validation
  static String? validateStoryContent(String? content) {
    if (content == null || content.trim().isEmpty) {
      return 'Story content cannot be empty';
    }

    final trimmedContent = content.trim();

    if (trimmedContent.length < minContentLength) {
      return 'Story content must be at least $minContentLength characters';
    }

    if (trimmedContent.length > maxContentLength) {
      return 'Story content cannot exceed $maxContentLength characters';
    }

    // Check for prohibited content
    if (_containsProhibitedContent(trimmedContent)) {
      return 'Story content contains prohibited words or phrases';
    }

    return null;
  }

  // Image file validation
  static Future<String?> validateImageFile(String? filePath) async {
    if (filePath == null || filePath.isEmpty) {
      return 'Image file path is required';
    }

    final file = File(filePath);

    // Check if file exists
    if (!await file.exists()) {
      return 'Image file does not exist';
    }

    // Check file extension
    final extension = filePath.split('.').last.toLowerCase();
    if (!allowedImageFormats.contains(extension)) {
      return 'Invalid image format. Allowed formats: ${allowedImageFormats.join(', ')}';
    }

    // Check file size
    try {
      final fileSizeBytes = await file.length();
      final fileSizeMB = fileSizeBytes / (1024 * 1024);

      if (fileSizeMB > maxImageSizeMB) {
        return 'Image file size cannot exceed ${maxImageSizeMB}MB';
      }
    } catch (e) {
      return 'Unable to determine image file size';
    }

    return null;
  }

  // Video file validation
  static Future<String?> validateVideoFile(String? filePath, {int? durationSeconds}) async {
    if (filePath == null || filePath.isEmpty) {
      return 'Video file path is required';
    }

    final file = File(filePath);

    // Check if file exists
    if (!await file.exists()) {
      return 'Video file does not exist';
    }

    // Check file extension
    final extension = filePath.split('.').last.toLowerCase();
    if (!allowedVideoFormats.contains(extension)) {
      return 'Invalid video format. Allowed formats: ${allowedVideoFormats.join(', ')}';
    }

    // Check file size
    try {
      final fileSizeBytes = await file.length();
      final fileSizeMB = fileSizeBytes / (1024 * 1024);

      if (fileSizeMB > maxVideoSizeMB) {
        return 'Video file size cannot exceed ${maxVideoSizeMB}MB';
      }
    } catch (e) {
      return 'Unable to determine video file size';
    }

    // Check duration
    if (durationSeconds != null && durationSeconds > maxVideoSeconds) {
      return 'Video duration cannot exceed ${maxVideoSeconds} seconds';
    }

    return null;
  }

  // Complete story validation
  static Future<String?> validateStory({
    String? content,
    String? imagePath,
    String? videoPath,
    int? videoDuration,
  }) async {
    // Content is required if no media
    if ((content == null || content.trim().isEmpty) &&
        (imagePath == null || imagePath.isEmpty) &&
        (videoPath == null || videoPath.isEmpty)) {
      return 'Story must have either content or media';
    }

    // Validate content if provided
    if (content != null && content.trim().isNotEmpty) {
      final contentError = validateStoryContent(content);
      if (contentError != null) return contentError;
    }

    // Validate image if provided
    if (imagePath != null && imagePath.isNotEmpty) {
      final imageError = await validateImageFile(imagePath);
      if (imageError != null) return imageError;
    }

    // Validate video if provided
    if (videoPath != null && videoPath.isNotEmpty) {
      final videoError = await validateVideoFile(videoPath, durationSeconds: videoDuration);
      if (videoError != null) return videoError;
    }

    // Cannot have both image and video
    if ((imagePath?.isNotEmpty ?? false) && (videoPath?.isNotEmpty ?? false)) {
      return 'Story cannot have both image and video';
    }

    return null;
  }

  // Comment validation
  static String? validateComment(String? comment) {
    if (comment == null || comment.trim().isEmpty) {
      return 'Comment cannot be empty';
    }

    final trimmedComment = comment.trim();

    if (trimmedComment.length < 1) {
      return 'Comment must have at least 1 character';
    }

    if (trimmedComment.length > 500) {
      return 'Comment cannot exceed 500 characters';
    }

    if (_containsProhibitedContent(trimmedComment)) {
      return 'Comment contains prohibited content';
    }

    return null;
  }

  // Helper method to check for prohibited content
  static bool _containsProhibitedContent(String content) {
    final prohibitedWords = [
      'spam', 'scam', 'fake', 'fraud',
      // Add more prohibited words as needed
    ];

    final lowerContent = content.toLowerCase();

    return prohibitedWords.any((word) => lowerContent.contains(word));
  }
}

// Business Service Validation
class BusinessServiceValidators {
  static const int minServiceNameLength = 3;
  static const int maxServiceNameLength = 50;
  static const int maxDescriptionLength = 200;
  static const double minPrice = 1.0;
  static const double maxPrice = 1000000.0;
  static const double minRating = 0.0;
  static const double maxRating = 5.0;

  static String? validateServiceName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Service name is required';
    }

    final trimmedName = name.trim();

    if (trimmedName.length < minServiceNameLength) {
      return 'Service name must be at least $minServiceNameLength characters';
    }

    if (trimmedName.length > maxServiceNameLength) {
      return 'Service name cannot exceed $maxServiceNameLength characters';
    }

    return null;
  }

  static String? validateServiceDescription(String? description) {
    if (description == null || description.trim().isEmpty) {
      return 'Service description is required';
    }

    if (description.trim().length > maxDescriptionLength) {
      return 'Description cannot exceed $maxDescriptionLength characters';
    }

    return null;
  }

  static String? validateServicePrice(String? priceString) {
    if (priceString == null || priceString.trim().isEmpty) {
      return 'Service price is required';
    }

    final price = double.tryParse(priceString.trim());
    if (price == null) {
      return 'Please enter a valid price';
    }

    if (price < minPrice) {
      return 'Price must be at least ₹$minPrice';
    }

    if (price > maxPrice) {
      return 'Price cannot exceed ₹$maxPrice';
    }

    return null;
  }

  static String? validateServiceRating(double? rating) {
    if (rating == null) {
      return 'Rating is required';
    }

    if (rating < minRating || rating > maxRating) {
      return 'Rating must be between $minRating and $maxRating';
    }

    return null;
  }
}