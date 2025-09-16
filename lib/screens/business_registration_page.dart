import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../components/input_field.dart';
import '../components/service_dropdown.dart';
import '../utils/validators.dart';
import '../utils/error_handling.dart';
import '../utils/sizing.dart';
import '../utils/app_icons.dart';
import '../core/language/generated/app_localizations.dart';

class BusinessRegistrationPage extends StatefulWidget {
  final VoidCallback onFinished;
  final VoidCallback? onSwitchToLogin;

  const BusinessRegistrationPage({
    Key? key,
    required this.onFinished,
    this.onSwitchToLogin,
  }) : super(key: key);

  @override
  State<BusinessRegistrationPage> createState() => _BusinessRegistrationPageState();
}

class _BusinessRegistrationPageState extends State<BusinessRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();

  final _authService = AuthService();
  final _registrationService = AuthService();

  bool _isLoading = false;
  int _resendCountdown = 0;
  String? _selectedService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    _authService.initialize(
      onCountdownUpdate: (countdown) {
        if (mounted) setState(() => _resendCountdown = countdown);
      },
      onError: (message) => ErrorHandler.showError(context, message),
      onSuccess: (message) => ErrorHandler.showSuccess(context, message),
    );

    _registrationService.initialize(
      onError: (message) => ErrorHandler.showError(context, message),
      onSuccess: (message) => ErrorHandler.showSuccess(context, message),
    );

    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final savedData = await _registrationService.loadSavedRegistrationData();
    if (savedData != null && mounted) {
      _fullNameController.text = savedData['fullName'] ?? '';
      _shopNameController.text = savedData['shopName'] ?? '';
      _mobileController.text = savedData['mobile'] ?? '';
      _selectedService = savedData['service'];
      setState(() {});
    }
  }

  void _onMobileChanged(String value) {
    _registrationService.updateRegistrationData(mobile: value);
    _registrationService.autoSaveRegistrationData();

    if (Validators.isValidMobile(value) && !_authService.isOtpSent) {
      _authService.sendOtp(value, fromAuto: true);
    }
  }

  void _onFieldChanged() {
    _registrationService.updateRegistrationData(
      fullName: _fullNameController.text,
      shopName: _shopNameController.text,
      service: _selectedService,
      mobile: _mobileController.text,
    );
    _registrationService.autoSaveRegistrationData();
  }

  void _sendOtp() {
    if (Validators.validateMobile(_mobileController.text) == null) {
      _authService.sendOtp(_mobileController.text.trim());
    } else {
      ErrorHandler.showError(context, 'Please enter a valid mobile number');
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await _registrationService.completeRegistration(
      fullName: _fullNameController.text,
      shopName: _shopNameController.text,
      service: _selectedService!,
      mobile: _mobileController.text,
      otp: _otpController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      widget.onFinished();
    }
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
                child: _buildRegistrationCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationCard() {
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
            _buildFormFields(),
            SizedBox(height: AppSizing.md),
            _buildMobileInput(),
            SizedBox(height: AppSizing.md),
            _buildOtpSection(),
            SizedBox(height: AppSizing.lg),
            _buildSubmitButton(),
            SizedBox(height: AppSizing.md),
            if (widget.onSwitchToLogin != null) _buildBackToLoginButton(),
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
          AppLocalizations.of(context)!.joinOurNetwork,
          style: TextStyle(
            fontSize: AppSizing.fontSize(26),
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: AppSizing.xs),
        Text(
          AppLocalizations.of(context)!.registerYourBusinessInMinutes,
          style: TextStyle(
            fontSize: AppSizing.fontSize(16),
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        CustomInputField(
          controller: _fullNameController,
          labelText: AppLocalizations.of(context)!.fullName,
          validator: Validators.validateFullName,
          onChanged: (_) => _onFieldChanged(),
        ),
        SizedBox(height: AppSizing.md),
        CustomInputField(
          controller: _shopNameController,
          labelText: AppLocalizations.of(context)!.shopName,
          validator: Validators.validateShopName,
          onChanged: (_) => _onFieldChanged(),
        ),
        SizedBox(height: AppSizing.md),
        ServiceDropdown(
          selectedService: _selectedService,
          onChanged: (value) {
            setState(() => _selectedService = value);
            _onFieldChanged();
          },
          validator: Validators.validateServiceCategory,
        ),
      ],
    );
  }

  Widget _buildMobileInput() {
    return CustomInputField(
      controller: _mobileController,
      labelText: AppLocalizations.of(context)!.mobileNumber,
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
            AppLocalizations.of(context)!.enterOtp,
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
                  ? AppLocalizations.of(context)!.didntReceiveSendOtp
                  : (_resendCountdown > 0
                  ? 'Resend in ${_resendCountdown}s'
                  : AppLocalizations.of(context)!.resendOtp),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSizing.buttonHeight,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitRegistration,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          ),
          backgroundColor: Colors.deepPurple,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          AppLocalizations.of(context)!.createAccount.toUpperCase(),
          style: TextStyle(
            fontSize: AppSizing.fontSize(18),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBackToLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSizing.buttonHeight,
      child: OutlinedButton(
        onPressed: widget.onSwitchToLogin,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          ),
          side: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        child: Text(
          "ALREADY HAVE ACCOUNT? SIGN IN",
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
        AppLocalizations.of(context)!.termsAndPrivacy,
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
    _registrationService.dispose();
    _fullNameController.dispose();
    _shopNameController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}