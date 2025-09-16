import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../components/input_field.dart';
import '../utils/validators.dart';
import '../utils/error_handling.dart';
import '../utils/sizing.dart';
import '../utils/app_icons.dart';
import 'package:my_business_app/screens/business_registration_page.dart';

class BusinessLoginPage extends StatefulWidget {
  final VoidCallback onFinished;
  const BusinessLoginPage({Key? key, required this.onFinished}) : super(key: key);

  @override
  State<BusinessLoginPage> createState() => _BusinessLoginPageState();
}

class _BusinessLoginPageState extends State<BusinessLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  void _initializeAuth() {
    _authService.initialize(
      onCountdownUpdate: (countdown) {
        if (mounted) setState(() => _resendCountdown = countdown);
      },
      onError: (message) => ErrorHandler.showError(context, message),
      onSuccess: (message) => ErrorHandler.showSuccess(context, message),
    );
    _loadSavedMobile();
  }

  Future<void> _loadSavedMobile() async {
    final savedMobile = await _authService.loadSavedMobile();
    if (savedMobile != null && mounted) {
      _mobileController.text = savedMobile;
    }
  }

  void _onMobileChanged(String value) {
    if (Validators.isValidMobile(value) && !_authService.isOtpSent) {
      _authService.sendOtp(value, fromAuto: true);
    }
  }

  void _sendOtp() {
    if (_formKey.currentState!.validate()) {
      _authService.sendOtp(_mobileController.text.trim());
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await _authService.verifyOtp(
      _otpController.text,
      _mobileController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      widget.onFinished();
    }
  }

  void _navigateToRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessRegistrationPage(onFinished: widget.onFinished),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppSizing.init(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            AppIcons.backgroundDecoration(),
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSizing.formPadding),
                child: _buildLoginCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: EdgeInsets.all(AppSizing.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
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
            AppIcons.businessLogo(),
            SizedBox(height: AppSizing.md),
            _buildHeader(),
            SizedBox(height: AppSizing.lg),
            _buildMobileInput(),
            SizedBox(height: AppSizing.md),
            _buildOtpSection(),
            SizedBox(height: AppSizing.lg),
            _buildLoginButton(),
            SizedBox(height: AppSizing.md),
            _buildRegisterButton(),
            SizedBox(height: AppSizing.sm),
            _buildTermsText(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          "Welcome Back",
          style: TextStyle(
            fontSize: AppSizing.fontSize(26),
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: AppSizing.xs),
        Text(
          "Sign in to your account",
          style: TextStyle(
            fontSize: AppSizing.fontSize(16),
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileInput() {
    return CustomInputField(
      controller: _mobileController,
      labelText: "Mobile Number",
      validator: Validators.validateMobile,
      onChanged: _onMobileChanged,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      showCountryCode: true,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
    );
  }

  Widget _buildOtpSection() {
    return Container(
      padding: EdgeInsets.all(AppSizing.md),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Text(
            "Enter OTP",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppSizing.fontSize(16),
            ),
          ),
          SizedBox(height: AppSizing.sm),
          CustomInputField(
            controller: _otpController,
            labelText: "- - - - - -",
            validator: Validators.validateOtp,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
          ),
          TextButton(
            onPressed: (_authService.isOtpSent && _resendCountdown > 0) ? null : _sendOtp,
            child: Text(
              !_authService.isOtpSent
                  ? "Didn't receive? Send OTP"
                  : (_resendCountdown > 0
                  ? 'Resend in ${_resendCountdown}s'
                  : "Resend OTP"),
              style: TextStyle(
                color: (_authService.isOtpSent && _resendCountdown > 0)
                    ? Colors.grey
                    : Colors.blue,
                fontWeight: FontWeight.w600,
                fontSize: AppSizing.fontSize(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSizing.buttonHeight,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          ),
          backgroundColor: Colors.deepPurple,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          "SIGN IN",
          style: TextStyle(
            fontSize: AppSizing.fontSize(18),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSizing.buttonHeight,
      child: OutlinedButton(
        onPressed: _navigateToRegistration,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          ),
          side: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        child: Text(
          "CREATE NEW ACCOUNT",
          style: TextStyle(
            fontSize: AppSizing.fontSize(16),
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return GestureDetector(
      onTap: () => ErrorHandler.showInfo(context, "Terms page coming soon..."),
      child: Text(
        "By continuing, you agree to our Terms & Privacy Policy",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: AppSizing.fontSize(12),
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authService.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}