import 'package:flutter/material.dart';
import 'package:my_business_app/core/theme/dim.dart';
import 'package:my_business_app/core/theme/icons.dart';

enum AppButtonVariant { primary, secondary, outline, text }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget button = _buildButton(context, theme);

    if (isFullWidth) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  Widget _buildButton(BuildContext context, ThemeData theme) {
    switch (variant) {
      case AppButtonVariant.primary:
        return _buildElevatedButton(theme);
      case AppButtonVariant.secondary:
        return _buildFilledTonalButton(theme);
      case AppButtonVariant.outline:
        return _buildOutlinedButton(theme);
      case AppButtonVariant.text:
        return _buildTextButton(theme);
    }
  }

  Widget _buildElevatedButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(0, _getHeight()),
        padding: _getPadding(),
      ),
      child: _buildButtonContent(theme),
    );
  }

  Widget _buildFilledTonalButton(ThemeData theme) {
    return FilledButton.tonal(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: Size(0, _getHeight()),
        padding: _getPadding(),
      ),
      child: _buildButtonContent(theme),
    );
  }

  Widget _buildOutlinedButton(ThemeData theme) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(0, _getHeight()),
        padding: _getPadding(),
      ),
      child: _buildButtonContent(theme),
    );
  }

  Widget _buildTextButton(ThemeData theme) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        minimumSize: Size(0, _getHeight()),
        padding: _getPadding(),
      ),
      child: _buildButtonContent(theme),
    );
  }

  Widget _buildButtonContent(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AppButtonVariant.primary
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.primary,
          ),
        ),
      );
    }

    final children = <Widget>[];

    if (leadingIcon != null) {
      children.add(Icon(leadingIcon, size: _getIconSize()));
      children.add(SizedBox(width: Dim.s));
    }

    final TextStyle? baseLabelStyle = _getLabelTextStyle(theme);
    children.add(Text(text, style: baseLabelStyle));

    if (trailingIcon != null) {
      children.add(SizedBox(width: Dim.s));
      children.add(Icon(trailingIcon, size: _getIconSize()));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return Dim.buttonHeightSmall;
      case AppButtonSize.medium:
        return Dim.buttonHeight;
      case AppButtonSize.large:
        return Dim.buttonHeightLarge;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return EdgeInsets.symmetric(horizontal: Dim.s, vertical: Dim.s);
      case AppButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: Dim.m, vertical: Dim.m);
      case AppButtonSize.large:
        return EdgeInsets.symmetric(horizontal: Dim.xl, vertical: Dim.m);
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return AppIcons.sizeS;
      case AppButtonSize.medium:
        return AppIcons.sizeM;
      case AppButtonSize.large:
        return AppIcons.sizeL;
    }
  }

  TextStyle? _getLabelTextStyle(ThemeData theme) {
    // Use theme-provided button label styles and only adjust size via scaled variants
    final TextStyle? labelLarge = theme.textTheme.labelLarge;
    switch (size) {
      case AppButtonSize.small:
        return labelLarge?.copyWith(fontSize: (labelLarge?.fontSize ?? 14) - 2);
      case AppButtonSize.medium:
        return labelLarge;
      case AppButtonSize.large:
        return labelLarge?.copyWith(fontSize: (labelLarge?.fontSize ?? 14) + 2);
    }
  }
}
