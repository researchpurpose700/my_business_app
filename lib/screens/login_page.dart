import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/save_data.dart';
import '../core/language/generated/app_localizations.dart';
import 'package:my_business_app/screens/business_registration_page.dart';

class BusinessLoginPage extends StatefulWidget {
  final VoidCallback onFinished;
  const BusinessLoginPage({super.key, required this.onFinished});

  @override
  State<BusinessLoginPage> createState() => _BusinessLoginPageState();
}

class _BusinessLoginPageState extends State<BusinessLoginPage> {
  final int _cooldownSeconds = 30;
  int _resendIn = 0;
  Timer? _cooldownTimer;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String _countryCode = '+91';
  bool _isOtpSent = false;

  final String _dummyOtp = "123456";

  @override
  void initState() {
    super.initState();
    _loadSavedMobile();
  }

  // Load saved mobile number if exists
  Future<void> _loadSavedMobile() async {
    final jsonMap = await LocalStorage.loadProfile();
    if (jsonMap != null) {
      _mobileController.text = jsonMap['mobile'] ?? '';
      _countryCode = jsonMap['countryCode'] ?? '+91';
      setState(() {});
    }
  }

  void _sendOtp({bool fromAuto = false}) {
    final phone = _mobileController.text.trim();
    final pattern = RegExp(r'^[6-9]\d{9}$');

    if (!pattern.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid 10-digit mobile starting with 6,7,8,9")),
      );
      return;
    }

    if (fromAuto && _isOtpSent) return;

    if (_resendIn > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please wait $_resendIn s to resend OTP')),
      );
      return;
    }

    setState(() => _isOtpSent = true);
    _startCooldown();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.otpSentToYourMobileNumber)),
    );
  }

  Future<void> _loginWithOtp() async {
    if (_formKey.currentState!.validate()) {
      if (_otpController.text != _dummyOtp) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Invalid OTP. Please enter 123456")),
        );
        return;
      }

      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));

      // Save mobile number for future use
      final data = {
        'countryCode': _countryCode,
        'mobile': _mobileController.text.trim(),
        'loginMethod': 'mobile',
      };
      await LocalStorage.upsertProfile(data);

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful")),
      );

      widget.onFinished();
    }
  }

  void _navigateToRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessRegistrationPage(
          onFinished: widget.onFinished,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(top: 100, left: 50, child: _floatingCircle(60)),
            Positioned(bottom: 150, right: 40, child: _floatingCircle(80)),
            Positioned(bottom: 100, left: 100, child: _floatingCircle(40)),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _logoBox(),
                        const SizedBox(height: 16),
                        Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Sign in to your account",
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 24),

                        // Mobile Number Section
                        Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: DropdownButtonFormField<String>(
                                value: _countryCode, // Fixed: changed from 'initialValue' to 'value'
                                items: ['+91', '+1', '+44']
                                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                    .toList(),
                                onChanged: (val) => setState(() => _countryCode = val!),
                                decoration: _dropdownDecoration(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _mobileController,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return AppLocalizations.of(context)!.enter10DigitMobile;
                                  }
                                  final pattern = RegExp(r'^[6-9]\d{9}$');
                                  if (!pattern.hasMatch(val)) {
                                    return "Mobile must start with 6,7,8,9 and be 10 digits";
                                  }
                                  return null;
                                },
                                onChanged: (val) {
                                  final pattern = RegExp(r'^[6-9]\d{9}$');
                                  if (pattern.hasMatch(val) && !_isOtpSent) {
                                    _sendOtp(fromAuto: true);
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.mobileNumber,
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  counterText: '',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _otpBox(context),
                        const SizedBox(height: 20),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _loginWithOtp,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: Colors.deepPurple,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              "SIGN IN",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Register Button - FIXED
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _navigateToRegistration, // Changed this line
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: const BorderSide(color: Colors.deepPurple, width: 2),
                            ),
                            child: const Text(
                              "CREATE NEW ACCOUNT",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Terms page coming soon...")),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.termsAndPrivacy,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoBox() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.store, size: 40, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _otpBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Text(AppLocalizations.of(context)!.enterOtp,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _otpController,
            maxLength: 6,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            validator: (val) => val!.length != 6
                ? AppLocalizations.of(context)!.enter6DigitOtp
                : null,
            decoration: InputDecoration(
              labelText: '- - - - - -',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              counterText: '',
            ),
          ),
          TextButton(
            onPressed: (_isOtpSent && _resendIn > 0) ? null : () => _sendOtp(),
            child: Text(
              !_isOtpSent
                  ? AppLocalizations.of(context)!.didntReceiveSendOtp
                  : (_resendIn > 0
                  ? 'Resend in ${_resendIn}s'
                  : AppLocalizations.of(context)!.resendOtp),
              style: TextStyle(
                color: (_isOtpSent && _resendIn > 0) ? Colors.grey : Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }

  Widget _floatingCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration:
      BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
    );
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _resendIn = _cooldownSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_resendIn <= 1) {
        t.cancel();
        setState(() => _resendIn = 0);
      } else {
        setState(() => _resendIn--);
      }
    });
  }
}