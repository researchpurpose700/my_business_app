import 'dart:async';
import '../config/save_data.dart';

class AuthenticationService {
  static final AuthenticationService _instance = AuthenticationService._internal();
  factory AuthenticationService() => _instance;
  AuthenticationService._internal();

  // Constants
  static const int _cooldownSeconds = 30;
  static const String _dummyOtp = "123456"; // TODO: Replace with production API

  // State variables
  Timer? _cooldownTimer;
  int _resendCountdown = 0;
  bool _isOtpSent = false;
  Function(int)? _onCountdownUpdate;
  Function(String)? _onError;
  Function(String)? _onSuccess;

  // Getters
  bool get isOtpSent => _isOtpSent;
  int get resendCountdown => _resendCountdown;

  // Initialize callbacks
  void initialize({
    Function(int)? onCountdownUpdate,
    Function(String)? onError,
    Function(String)? onSuccess,
  }) {
    _onCountdownUpdate = onCountdownUpdate;
    _onError = onError;
    _onSuccess = onSuccess;
  }

  // Send OTP to mobile number
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

  // Verify OTP
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
      _onSuccess?.call('Login Successful');
      return true;
    } catch (e) {
      _onError?.call('OTP verification failed. Please try again.');
      return false;
    }
  }

  // Load saved mobile number
  Future<String?> loadSavedMobile() async {
    try {
      final jsonMap = await LocalStorage.loadProfile();
      return jsonMap?['mobile'];
    } catch (e) {
      return null;
    }
  }

  // Private: Save user data to local storage
  Future<void> _saveUserData(String mobileNumber) async {
    final data = {
      'countryCode': '+91',
      'mobile': mobileNumber,
      'loginMethod': 'mobile',
    };
    await LocalStorage.upsertProfile(data);
  }

  // Private: Start countdown timer
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

  // Reset service state
  void reset() {
    _cooldownTimer?.cancel();
    _isOtpSent = false;
    _resendCountdown = 0;
    _onCountdownUpdate?.call(0);
  }

  // Cleanup resources
  void dispose() {
    _cooldownTimer?.cancel();
    _onCountdownUpdate = null;
    _onError = null;
    _onSuccess = null;
  }
}