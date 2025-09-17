import 'package:flutter/material.dart';
import '../utils/sizing.dart';
import '../utils/business_categories.dart';
import '../core/language/generated/app_localizations.dart';

class ServiceDropdown extends StatelessWidget {
  final String? selectedService;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;

  const ServiceDropdown({
    super.key,
    required this.selectedService,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizing.sm),
      child: DropdownButtonFormField<String>(
        initialValue: selectedService,
        hint: Text(
          AppLocalizations.of(context)!.selectYourCategory,
          style: TextStyle(
            fontSize: AppSizing.fontSize(16),
            color: Colors.grey[600],
          ),
        ),
        items: BusinessCategories.getDropdownItems(context),
        onChanged: onChanged,
        validator: validator,
        style: TextStyle(
          fontSize: AppSizing.fontSize(16),
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizing.md,
            vertical: AppSizing.lg,
          ),
        ),
        dropdownColor: Colors.white,
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.grey[600],
          size: AppSizing.iconMd,
        ),
      ),
    );
  }
}