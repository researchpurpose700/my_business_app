import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/save_data.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ============================================================================
  // CONSTANTS & STATE VARIABLES
  // ============================================================================

  // OTP Constants
  static const int _cooldownSeconds = 30;
  static const String _dummyOtp = "123456"; // TODO: Replace with production API

  // State variables for OTP
  Timer? _cooldownTimer;
  int _resendCountdown = 0;
  bool _isOtpSent = false;

  // Registration data
  Map<String, dynamic> _registrationData = {};

  // Callbacks
  Function(int)? _onCountdownUpdate;
  Function(String)? _onError;
  Function(String)? _onSuccess;

  // ============================================================================
  // GETTERS
  // ============================================================================

  bool get isOtpSent => _isOtpSent;
  int get resendCountdown => _resendCountdown;

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize service with callbacks
  void initialize({
    Function(int)? onCountdownUpdate,
    Function(String)? onError,
    Function(String)? onSuccess,
  }) {
    _onCountdownUpdate = onCountdownUpdate;
    _onError = onError;
    _onSuccess = onSuccess;
  }

  // ============================================================================
  // AUTHENTICATION METHODS
  // ============================================================================

  /// Send OTP to mobile number
  Future<bool> sendOtp(String mobileNumber, {bool fromAuto = false}) async {
    if (fromAuto && _isOtpSent) return false;

    if (_resendCountdown > 0) {
      _onError?.call('Please wait $_resendCountdown seconds to resend OTP');
      return false;
    }

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      _isOtpSent = true;
      _startCooldown();
      _onSuccess?.call('OTP sent to your mobile number');
      return true;
    } catch (e) {
      _onError?.call('Failed to send OTP. Please try again.');
      return false;
    }
  }

  /// Verify OTP for login
  Future<bool> verifyOtp(String otp, String mobileNumber) async {
    try {
      // TODO: Replace with actual API verification
      await Future.delayed(const Duration(seconds: 2));

      if (otp != _dummyOtp) {
        _onError?.call('Invalid OTP. Please enter 123456');
        return false;
      }

      // Save user data after successful verification
      await _saveUserData(mobileNumber);

      // IMPORTANT: Also save to SharedPreferences for main app flow
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isRegistered', true);

      _onSuccess?.call('Login Successful');
      return true;
    } catch (e) {
      _onError?.call('OTP verification failed. Please try again.');
      return false;
    }
  }

  /// Load saved mobile number
  Future<String?> loadSavedMobile() async {
    try {
      final jsonMap = await LocalStorage.loadProfile();
      return jsonMap?['mobile'];
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // REGISTRATION METHODS
  // ============================================================================

  /// Load saved registration data
  Future<Map<String, dynamic>?> loadSavedRegistrationData() async {
    try {
      final jsonMap = await LocalStorage.loadProfile();
      if (jsonMap != null) {
        _registrationData = Map<String, dynamic>.from(jsonMap);
        return _registrationData;
      }
      return null;
    } catch (e) {
      _onError?.call('Failed to load saved data');
      return null;
    }
  }

  /// Update registration data temporarily
  void updateRegistrationData({
    String? fullName,
    String? shopName,
    String? service,
    String? mobile,
  }) {
    if (fullName != null) _registrationData['fullName'] = fullName.trim();
    if (shopName != null) _registrationData['shopName'] = shopName.trim();
    if (service != null) _registrationData['service'] = service;
    if (mobile != null) _registrationData['mobile'] = mobile.trim();
  }

  /// Complete registration process
  Future<bool> completeRegistration({
    required String fullName,
    required String shopName,
    required String service,
    required String mobile,
    required String otp,
  }) async {
    try {
      // TODO: Replace with actual API call to verify OTP and register business
      await Future.delayed(const Duration(seconds: 2));

      // For now, using dummy OTP validation
      if (otp != _dummyOtp) {
        _onError?.call('Invalid OTP. Please enter 123456');
        return false;
      }

      // Save all registration data to LocalStorage
      final registrationData = {
        'fullName': fullName.trim(),
        'shopName': shopName.trim(),
        'service': service,
        'countryCode': '+91',
        'mobile': mobile.trim(),
        'registrationMethod': 'mobile',
        'isRegistered': true,
      };

      await LocalStorage.upsertProfile(registrationData);

      // IMPORTANT: Also save to SharedPreferences for main app flow
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isRegistered', true);

      _onSuccess?.call('Account created successfully!');
      return true;
    } catch (e) {
      _onError?.call('Registration failed. Please try again.');
      return false;
    }
  }

  /// Auto-save registration data periodically
  Future<void> autoSaveRegistrationData() async {
    try {
      if (_registrationData.isNotEmpty) {
        await LocalStorage.upsertProfile(_registrationData);
      }
    } catch (e) {
      // Silent fail for auto-save
    }
  }

  /// Get specific saved registration value
  String? getSavedRegistrationValue(String key) {
    return _registrationData[key]?.toString();
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Save user data to local storage (private method)
  Future<void> _saveUserData(String mobileNumber) async {
    final data = {
      'countryCode': '+91',
      'mobile': mobileNumber,
      'loginMethod': 'mobile',
    };
    await LocalStorage.upsertProfile(data);
  }

  /// Start countdown timer for OTP resend (private method)
  void _startCooldown() {
    _cooldownTimer?.cancel();
    _resendCountdown = _cooldownSeconds;
    _onCountdownUpdate?.call(_resendCountdown);

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown <= 1) {
        timer.cancel();
        _resendCountdown = 0;
        _onCountdownUpdate?.call(_resendCountdown);
      } else {
        _resendCountdown--;
        _onCountdownUpdate?.call(_resendCountdown);
      }
    });
  }

  // ============================================================================
  // STATE MANAGEMENT
  // ============================================================================

  /// Reset authentication state
  void resetAuth() {
    _cooldownTimer?.cancel();
    _isOtpSent = false;
    _resendCountdown = 0;
    _onCountdownUpdate?.call(0);
  }

  /// Clear registration data
  void clearRegistrationData() {
    _registrationData.clear();
  }

  /// Clear all data
  void clearAllData() {
    resetAuth();
    clearRegistrationData();
  }

  /// Cleanup all resources
  void dispose() {
    _cooldownTimer?.cancel();
    _onCountdownUpdate = null;
    _onError = null;
    _onSuccess = null;
    _registrationData.clear();
  }
}