import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_business_app/utils/sizing.dart';
import 'package:my_business_app/utils/listing_constants.dart';
import 'package:my_business_app/utils/validators.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final TextInputType keyboardType;
  final int? maxLength;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool showCountryCode;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final String? hintText;
  final bool readOnly;
  final bool enabled;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double? borderRadius;

  const CustomInputField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.maxLines = 1,
    this.inputFormatters,
    this.showCountryCode = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.hintText,
    this.readOnly = false,
    this.enabled = true,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (showCountryCode) {
      return Row(
        children: [
          // Fixed country code container
          Container(
            width: AppSizing.width(20),
            padding: EdgeInsets.symmetric(
              horizontal: AppSizing.md,
              vertical: AppSizing.lg,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor ?? Colors.grey[300]!),
              borderRadius: BorderRadius.circular(borderRadius ?? AppSizing.radiusMd),
              color: fillColor ?? Colors.grey[100],
            ),
            child: Text(
              '+91',
              style: TextStyle(
                fontSize: AppSizing.fontSize(16),
                fontWeight: FontWeight.w500,
                color: enabled ? Colors.grey[700] : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: AppSizing.sm),
          // Mobile input field
          Expanded(
            child: _buildTextField(context),
          ),
        ],
      );
    }

    return _buildTextField(context);
  }

  Widget _buildTextField(BuildContext context) {
    final effectiveFillColor = _getFillColor();
    final effectiveBorderColor = borderColor ?? Colors.grey[300]!;
    final effectiveFocusedBorderColor = focusedBorderColor ?? Theme.of(context).primaryColor;
    final effectiveBorderRadius = borderRadius ?? AppSizing.radiusMd;

    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      readOnly: readOnly,
      enabled: enabled,
      inputFormatters: inputFormatters,
      style: TextStyle(
        fontSize: AppSizing.fontSize(16),
        color: enabled ? Colors.black87 : Colors.grey[600],
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(
          prefixIcon,
          color: enabled ? Colors.grey[600] : Colors.grey[400],
        )
            : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
          icon: Icon(
            suffixIcon,
            color: enabled ? Colors.grey[600] : Colors.grey[400],
          ),
          onPressed: enabled ? onSuffixIconPressed : null,
        )
            : null,
        filled: true,
        fillColor: effectiveFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          borderSide: BorderSide(color: effectiveBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          borderSide: BorderSide(color: effectiveBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          borderSide: BorderSide(color: effectiveFocusedBorderColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizing.md,
          vertical: maxLines != null && maxLines! > 1
              ? AppSizing.md
              : AppSizing.lg,
        ),
        counterText: maxLength != null ? '' : null,
        // Accessibility improvements
        labelStyle: TextStyle(
          color: enabled ? Colors.grey[700] : Colors.grey[500],
          fontSize: AppSizing.fontSize(14),
        ),
        hintStyle: TextStyle(
          color: enabled ? Colors.grey[500] : Colors.grey[400],
          fontSize: AppSizing.fontSize(14),
        ),
      ),
    );
  }

  Color _getFillColor() {
    if (fillColor != null) return fillColor!;
    if (!enabled) return Colors.grey[100]!;
    if (readOnly) return Colors.grey[50]!;
    return Colors.grey[100]!;
  }
}

// Extension to provide common input field variations
extension CustomInputFieldVariations on CustomInputField {
  static CustomInputField email({
    required TextEditingController controller,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    String? hintText,
    bool readOnly = false,
    bool enabled = true,
  }) {
    return CustomInputField(
      controller: controller,
      labelText: 'Email Address',
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email_outlined,
      validator: validator,
      onChanged: onChanged,
      hintText: hintText ?? 'Enter your email address',
      readOnly: readOnly,
      enabled: enabled,
    );
  }

  static CustomInputField password({
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onVisibilityToggle,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    String? hintText,
    bool enabled = true,
  }) {
    return CustomInputField(
      controller: controller,
      labelText: 'Password',
      keyboardType: TextInputType.visiblePassword,
      prefixIcon: Icons.lock_outline,
      suffixIcon: obscureText ? Icons.visibility_off : Icons.visibility,
      onSuffixIconPressed: onVisibilityToggle,
      validator: validator,
      onChanged: onChanged,
      hintText: hintText ?? 'Enter your password',
      enabled: enabled,
    );
  }

  static CustomInputField phone({
    required TextEditingController controller,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    bool showCountryCode = true,
    bool enabled = true,
  }) {
    return CustomInputField(
      controller: controller,
      labelText: showCountryCode ? 'Mobile Number' : 'Phone Number',
      keyboardType: TextInputType.phone,
      prefixIcon: showCountryCode ? null : Icons.phone_outlined,
      showCountryCode: showCountryCode,
      validator: validator,
      onChanged: onChanged,
      maxLength: 10,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      enabled: enabled,
    );
  }

  static CustomInputField search({
    required TextEditingController controller,
    required VoidCallback onClear,
    Function(String)? onChanged,
    String? hintText,
    bool enabled = true,
  }) {
    return CustomInputField(
      controller: controller,
      labelText: 'Search',
      keyboardType: TextInputType.text,
      prefixIcon: Icons.search,
      suffixIcon: Icons.clear,
      onSuffixIconPressed: onClear,
      onChanged: onChanged,
      hintText: hintText ?? 'Search...',
      enabled: enabled,
    );
  }
}

class ListingFormContainer extends StatelessWidget {
  final Widget child;

  const ListingFormContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: AppSizing.width(2.5),
            offset: Offset(0, AppSizing.width(0.5)),
          ),
        ],
      ),
      padding: EdgeInsets.all(AppSizing.md),
      child: child,
    );
  }
}

class ListingTextField extends StatefulWidget {
  final TextEditingController controller;
  final String fieldKey;
  final String listingType;
  final String? Function(String?)? validator;
  final VoidCallback? onChanged;
  final int? maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool showCharacterCount;

  const ListingTextField({
    super.key,
    required this.controller,
    required this.fieldKey,
    required this.listingType,
    this.validator,
    this.onChanged,
    this.maxLines,
    this.keyboardType,
    this.inputFormatters,
    this.showCharacterCount = true,
  });

  @override
  State<ListingTextField> createState() => _ListingTextFieldState();
}

class _ListingTextFieldState extends State<ListingTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isRequired = ListingConstants.isFieldRequired(widget.fieldKey, widget.listingType);
    final limit = ListingConstants.getFieldLimit(widget.fieldKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: "${ListingConstants.getFieldLabel(widget.fieldKey, widget.listingType)}${isRequired ? ' *' : ''}",
            hintText: ListingConstants.getFieldHint(widget.fieldKey, widget.listingType),
            prefixIcon: Icon(
              ListingConstants.getFieldIcon(widget.fieldKey, widget.listingType),
              color: Colors.blue,
            ),
            border: InputBorder.none,
            counterText: "",
            alignLabelWithHint: widget.maxLines != null && widget.maxLines! > 1,
          ),
          maxLines: widget.maxLines ?? 1,
          maxLength: limit,
          maxLengthEnforcement: MaxLengthEnforcement.none,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters ?? [
            LengthLimitingTextInputFormatter(limit),
          ],
          validator: widget.validator,
          onChanged: (_) => widget.onChanged?.call(),
        ),
        if (widget.showCharacterCount) ...[
          SizedBox(height: AppSizing.sm),
          _buildCharacterCounter(),
        ],
      ],
    );
  }

  Widget _buildCharacterCounter() {
    final info = _getCharacterInfo();

    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        info.displayText,
        style: TextStyle(
          fontSize: AppSizing.fontSize(12),
          color: info.isDanger
              ? Colors.red
              : info.isWarning
              ? Colors.orange
              : Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  CharacterCountInfo _getCharacterInfo() {
    switch (widget.fieldKey) {
      case 'title':
        return ListingValidators.getTitleCharacterInfo(widget.controller.text);
      case 'experience':
        return ListingValidators.getExperienceCharacterInfo(widget.controller.text);
      case 'warranty':
        return ListingValidators.getWarrantyCharacterInfo(widget.controller.text);
      case 'description':
        return ListingValidators.getDescriptionCharacterInfo(widget.controller.text);
      default:
        final limit = ListingConstants.getFieldLimit(widget.fieldKey);
        final remaining = limit - widget.controller.text.length;
        return CharacterCountInfo(
          current: widget.controller.text.length,
          max: limit,
          remaining: remaining,
          isWarning: remaining <= 10,
          isDanger: remaining <= 5,
        );
    }
  }
}

class ListingDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final String fieldKey;
  final String listingType;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const ListingDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.fieldKey,
    required this.listingType,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isRequired = ListingConstants.isFieldRequired(fieldKey, listingType);

    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      )).toList(),
      decoration: InputDecoration(
        labelText: "${ListingConstants.getFieldLabel(fieldKey, listingType)}${isRequired ? ' *' : ''}",
        prefixIcon: Icon(
          ListingConstants.getFieldIcon(fieldKey, listingType),
          color: Colors.blue,
        ),
        border: InputBorder.none,
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}

class ListingTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  const ListingTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedType,
      items: ListingConstants.listingTypes.map((type) =>
          DropdownMenuItem(
            value: type,
            child: Text(ListingConstants.listingTypeLabels[type] ?? type),
          )
      ).toList(),
      decoration: const InputDecoration(
        labelText: "What are you listing? *",
        border: InputBorder.none,
      ),
      onChanged: enabled ? onChanged : null,
      validator: (value) => ListingValidators.validateListingType(value),
    );
  }
}

class ListingPriceField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onChanged;
  final String? Function(String?)? validator;

  const ListingPriceField({
    super.key,
    required this.controller,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: "Price *",
        hintText: "Enter amount",
        prefixIcon: Icon(Icons.currency_rupee, color: Colors.blue),
        border: InputBorder.none,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(5),
      ],
      validator: validator ?? (value) => ListingValidators.validatePrice(value),
      onChanged: (_) => onChanged?.call(),
    );
  }
}

class IdDisplayWidget extends StatelessWidget {
  final String id;
  final VoidCallback? onCopy;

  const IdDisplayWidget({
    super.key,
    required this.id,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.fingerprint, color: Colors.blue, size: AppSizing.fontSize(20)),
        SizedBox(width: AppSizing.md),
        Text(
          "ID: ",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: AppSizing.fontSize(14),
          ),
        ),
        GestureDetector(
          onTap: onCopy,
          child: Text(
            '${id.substring(0, 8)}...',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
              fontSize: AppSizing.fontSize(14),
            ),
          ),
        ),
        const Spacer(),
        Icon(
          Icons.copy,
          color: Colors.grey,
          size: AppSizing.fontSize(16),
        ),
      ],
    );
  }
}

class FormActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const FormActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppSizing.buttonHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.blueAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: AppSizing.width(3),
            offset: Offset(0, AppSizing.width(1.5)),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizing.radiusLg),
          ),
        ),
        child: isLoading
            ? SizedBox(
          width: AppSizing.fontSize(20),
          height: AppSizing.fontSize(20),
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          text,
          style: TextStyle(
            fontSize: AppSizing.fontSize(16),
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}