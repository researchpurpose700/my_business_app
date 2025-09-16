import 'dart:io';
import 'package:my_business_app/config/save_data.dart';
import 'package:my_business_app/utils/error_handling.dart';

class ProfileService {
  static ProfileService? _instance;
  static ProfileService get instance => _instance ??= ProfileService._();
  ProfileService._();

  // Profile data
  String _fullName = '';
  String _shopName = '';
  String _phoneNumber = '';
  String _address = '';
  String _timings = '10:00 AM – 9:00 PM';
  bool _isOpen = true;
  File? _coverImage;
  File? _profileImage;

  // Getters
  String get fullName => _fullName;
  String get shopName => _shopName;
  String get phoneNumber => _phoneNumber;
  String get address => _address;
  String get timings => _timings;
  bool get isOpen => _isOpen;
  File? get coverImage => _coverImage;
  File? get profileImage => _profileImage;

  // Default values
  static const String defaultFullName = 'User Name';
  static const String defaultShopName = 'Your Shop Name';
  static const String defaultPhoneNumber = '+91 00000 00000';
  static const String defaultAddress = 'Add your shop address';

  Future<ProfileLoadResult> loadProfile() async {
    try {
      final json = await LocalStorage.loadProfile();

      if (json != null) {
        // Load username from multiple possible keys
        _fullName = ((json['Username'] ?? json['username'] ?? json['fullName'] ?? json['name'])
            ?.toString() ?? '')
            .trim();
        if (_fullName.isEmpty) _fullName = defaultFullName;

        // Load other fields
        _shopName = (json['shopName']?.toString() ?? '').trim();
        if (_shopName.isEmpty) _shopName = defaultShopName;

        _phoneNumber = (json['mobile']?.toString() ?? '').trim();
        if (_phoneNumber.isEmpty) _phoneNumber = defaultPhoneNumber;

        _address = (json['address']?.toString() ?? '').trim();
        if (_address.isEmpty) _address = defaultAddress;

        // Load timings and status
        final savedTimings = (json['timings']?.toString() ?? '').trim();
        if (savedTimings.isNotEmpty) _timings = savedTimings;
        _isOpen = (json['isOpen'] as bool?) ?? true;

        // Load images
        await _loadImages(json);

        return ProfileLoadResult.success();
      } else {
        _setDefaultValues();
        return ProfileLoadResult.success();
      }
    } catch (e) {
      _setDefaultValues();
      return ProfileLoadResult.error(ErrorHandler.getStorageErrorMessage(e));
    }
  }

  Future<void> _loadImages(Map<String, dynamic> json) async {
    final coverPath = json['coverImage'] as String?;
    final profilePath = json['profileImage'] as String?;

    if (coverPath != null && coverPath.isNotEmpty) {
      final coverFile = File(coverPath);
      if (coverFile.existsSync()) _coverImage = coverFile;
    }

    if (profilePath != null && profilePath.isNotEmpty) {
      final profileFile = File(profilePath);
      if (profileFile.existsSync()) _profileImage = profileFile;
    }
  }

  void _setDefaultValues() {
    _fullName = defaultFullName;
    _shopName = defaultShopName;
    _phoneNumber = defaultPhoneNumber;
    _address = defaultAddress;
  }

  Future<SaveResult> saveProfile({
    String? fullName,
    String? shopName,
    String? phoneNumber,
    String? address,
    String? timings,
    bool? isOpen,
    File? coverImage,
    File? profileImage,
  }) async {
    try {
      // Update local values
      if (fullName != null) _fullName = fullName;
      if (shopName != null) _shopName = shopName;
      if (phoneNumber != null) _phoneNumber = phoneNumber;
      if (address != null) _address = address;
      if (timings != null) _timings = timings;
      if (isOpen != null) _isOpen = isOpen;
      if (coverImage != null) _coverImage = coverImage;
      if (profileImage != null) _profileImage = profileImage;

      // Save to storage
      await LocalStorage.upsertProfile({
        'Username': _fullName,
        'shopName': _shopName,
        'address': _address,
        'mobile': _phoneNumber,
        'timings': _timings,
        'isOpen': _isOpen,
        'coverImage': _coverImage?.path,
        'profileImage': _profileImage?.path,
      });

      return SaveResult.success();
    } catch (e) {
      return SaveResult.error(ErrorHandler.getStorageErrorMessage(e));
    }
  }

  void updateOpenStatus(bool isOpen) {
    _isOpen = isOpen;
    saveProfile(isOpen: isOpen);
  }
}

class ProfileLoadResult {
  final bool isSuccess;
  final String? errorMessage;

  ProfileLoadResult._(this.isSuccess, this.errorMessage);

  factory ProfileLoadResult.success() => ProfileLoadResult._(true, null);
  factory ProfileLoadResult.error(String message) => ProfileLoadResult._(false, message);
}

class SaveResult {
  final bool isSuccess;
  final String? errorMessage;

  SaveResult._(this.isSuccess, this.errorMessage);

  factory SaveResult.success() => SaveResult._(true, null);
  factory SaveResult.error(String message) => SaveResult._(false, message);
}