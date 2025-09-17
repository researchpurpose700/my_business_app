import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_business_app/utils/sizing.dart';
import 'package:my_business_app/utils/validators.dart';
import 'package:my_business_app/components/input_field.dart';

// =============================================================================
// COMMON WIDGETS - Reusable UI components used throughout the app
// =============================================================================

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final Color? backgroundColor;
  final double? elevation;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(AppSizing.cardPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(radius ?? AppSizing.radiusMd),
        border: Border.all(color: const Color(0xFFE8EAF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class FeatureBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;

  const FeatureBox({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizing.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
        child: AppCard(
          radius: AppSizing.radiusLg,
          backgroundColor: backgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                  icon,
                  size: AppSizing.iconSize,
                  color: iconColor ?? colorScheme.primary
              ),
              SizedBox(height: AppSizing.sm),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: AppSizing.fontSize(14),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;
  final int maxLines;

  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
    this.iconColor,
    this.textColor,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        Icon(
            icon,
            size: AppSizing.smallIconSize,
            color: iconColor ?? Colors.black45
        ),
        SizedBox(width: AppSizing.xs + 2), // ~6px
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: AppSizing.fontSize(13),
              color: textColor ?? Colors.black87,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return onTap == null
        ? row
        : Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizing.radiusXs + 2), // ~6px
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizing.radiusXs + 2),
        child: Padding(
          padding: EdgeInsets.all(AppSizing.xs / 2), // ~2px
          child: row,
        ),
      ),
    );
  }
}

class StatusToggle extends StatelessWidget {
  final bool isOpen;
  final ValueChanged<bool> onChanged;
  final String openText;
  final String closedText;

  const StatusToggle({
    super.key,
    required this.isOpen,
    required this.onChanged,
    this.openText = 'Open',
    this.closedText = 'Closed',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isOpen ? openText : closedText,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isOpen ? Colors.green : Colors.red,
            fontSize: AppSizing.fontSize(14),
          ),
        ),
        SizedBox(width: AppSizing.xs + 2), // ~6px
        Switch.adaptive(
          value: isOpen,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSizing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (loadingText != null) ...[
                        SizedBox(height: AppSizing.md),
                        Text(
                          loadingText!,
                          style: TextStyle(fontSize: AppSizing.fontSize(16)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onActionPressed;
  final String? actionText;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onActionPressed,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppSizing.width(20), // ~75px
              color: Colors.grey[400],
            ),
            SizedBox(height: AppSizing.lg),
            Text(
              title,
              style: TextStyle(
                fontSize: AppSizing.fontSize(18),
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizing.sm),
            Text(
              message,
              style: TextStyle(
                fontSize: AppSizing.fontSize(14),
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onActionPressed != null && actionText != null) ...[
              SizedBox(height: AppSizing.lg),
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PROFILE WIDGETS - User profile and image management components
// =============================================================================

class CoverImageSection extends StatelessWidget {
  final File? coverImage;
  final VoidCallback onTap;

  const CoverImageSection({
    super.key,
    required this.coverImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize AppSizing at the start of build method
    AppSizing.init(context);

    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(AppSizing.radiusLg),
        bottomRight: Radius.circular(AppSizing.radiusLg),
      ),
      child: SizedBox(
        height: AppSizing.coverImageHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Base gradient (always visible)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7DB2FF), Color(0xFF4A72DA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Cover image (shows if selected)
            if (coverImage != null)
              Image.file(
                coverImage!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),

            // Scrim for legibility
            Container(color: Colors.black.withOpacity(0.12)),

            // Camera button - always shown
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSizing.height(7), // ~60px
              child: Center(
                child: Material(
                  color: Colors.white.withOpacity(0.92),
                  shape: const StadiumBorder(),
                  elevation: 2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSizing.radiusXl),
                    onTap: onTap,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizing.md,
                        vertical: AppSizing.sm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo_camera_rounded,
                            size: AppSizing.fontSize(18),
                            color: Colors.black87,
                          ),
                          SizedBox(width: AppSizing.sm),
                          Text(
                            coverImage == null
                                ? 'Add a cover photo'
                                : 'Change cover photo',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: AppSizing.fontSize(14),
                            ),
                          ),
                        ],
                      ),
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
}

class ProfileImageSection extends StatelessWidget {
  final File? profileImage;
  final VoidCallback onTap;

  const ProfileImageSection({
    super.key,
    required this.profileImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize AppSizing at the start of build method
    AppSizing.init(context);

    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: AppSizing.profileImageRadius,
          backgroundColor: const Color(0xFFE9EEF8),
          backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
          child: profileImage == null
              ? Icon(
            Icons.person_rounded,
            size: AppSizing.width(10.7), // ~40px
            color: Colors.black38,
          )
              : null,
        ),
        Positioned(
          bottom: -2,
          right: -2,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Container(
                padding: EdgeInsets.all(AppSizing.xs),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Icon(
                  profileImage == null ? Icons.add_rounded : Icons.edit_rounded,
                  size: AppSizing.fontSize(18),
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileEditDialog extends StatefulWidget {
  final String initialFullName;
  final String initialShopName;
  final String initialPhoneNumber;
  final String initialAddress;
  final String initialTimings;

  const ProfileEditDialog({
    super.key,
    required this.initialFullName,
    required this.initialShopName,
    required this.initialPhoneNumber,
    required this.initialAddress,
    required this.initialTimings,
  });

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _shopNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _timingsController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.initialFullName);
    _shopNameController = TextEditingController(text: widget.initialShopName);
    _phoneController = TextEditingController(text: widget.initialPhoneNumber);
    _addressController = TextEditingController(text: widget.initialAddress);
    _timingsController = TextEditingController(text: widget.initialTimings);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _shopNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _timingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize AppSizing at the start of build method
    AppSizing.init(context);

    return AlertDialog(
      title: Text(
        'Edit Profile Info',
        style: TextStyle(fontSize: AppSizing.fontSize(18)),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomInputField(
                controller: _fullNameController,
                labelText: 'Your Name',
                prefixIcon: Icons.person,
                validator: Validators.validateName,
              ),
              SizedBox(height: AppSizing.md),
              CustomInputField(
                controller: _shopNameController,
                labelText: 'Shop Name',
                prefixIcon: Icons.store,
                validator: Validators.validateShopName,
              ),
              SizedBox(height: AppSizing.md),
              CustomInputField(
                controller: _phoneController,
                labelText: 'Phone Number',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhone,
              ),
              SizedBox(height: AppSizing.md),
              CustomInputField(
                controller: _addressController,
                labelText: 'Address',
                prefixIcon: Icons.location_on,
                hintText: 'Enter your shop address',
                maxLines: 2,
                validator: Validators.validateAddress,
              ),
              SizedBox(height: AppSizing.md),
              CustomInputField(
                controller: _timingsController,
                labelText: 'Shop Timings (e.g., 9:00 AM â€" 9:00 PM)',
                prefixIcon: Icons.schedule,
                validator: Validators.validateTimings,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _handleSave,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'fullName': _fullNameController.text.trim(),
        'shopName': _shopNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'timings': _timingsController.text.trim(),
      });
    }
  }
}

class ImageSourcePicker extends StatelessWidget {
  final bool isCoverImage;
  final File? currentImage;
  final Function(ImageSource) onSourceSelected;
  final VoidCallback? onRemove;

  const ImageSourcePicker({
    super.key,
    required this.isCoverImage,
    required this.currentImage,
    required this.onSourceSelected,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize AppSizing at the start of build method
    AppSizing.init(context);

    final imageTypeName = isCoverImage ? 'cover photo' : 'profile picture';

    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Camera'),
            onTap: () {
              Navigator.pop(context);
              onSourceSelected(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.pop(context);
              onSourceSelected(ImageSource.gallery);
            },
          ),
          if (currentImage != null && onRemove != null)
            ListTile(
              leading: const Icon(Icons.delete),
              title: Text('Remove $imageTypeName'),
              onTap: () {
                Navigator.pop(context);
                onRemove!();
              },
            ),
        ],
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    required bool isCoverImage,
    required File? currentImage,
    required Function(ImageSource) onSourceSelected,
    VoidCallback? onRemove,
  }) async {
    // Initialize AppSizing before using it
    AppSizing.init(context);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizing.radiusLg),
        ),
      ),
      builder: (context) => ImageSourcePicker(
        isCoverImage: isCoverImage,
        currentImage: currentImage,
        onSourceSelected: onSourceSelected,
        onRemove: onRemove,
      ),
    );
  }
}