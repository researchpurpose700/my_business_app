import 'package:flutter/material.dart';
import 'package:my_business_app/core/theme/dim.dart';
import 'package:my_business_app/core/theme/icons.dart';

enum AppIconButtonVariant { filled, filledTonal, outlined, standard }
enum AppIconButtonSize { small, medium, large }

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;
  final AppIconButtonSize size;
  final String? tooltip;
  final bool isLoading;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = AppIconButtonVariant.standard,
    this.size = AppIconButtonSize.medium,
    this.tooltip,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = _buildButton(context);

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }

  Widget _buildButton(BuildContext context) {
    final iconSize = _getIconSize();
    final buttonSize = _getButtonSize();

    Widget child = isLoading
        ? SizedBox(
      width: iconSize,
      height: iconSize,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).colorScheme.primary,
        ),
      ),
    )
        : Icon(icon, size: iconSize);

    switch (variant) {
    case AppIconButtonVariant.filled:
    return IconButton.filled(
    onPressed: isLoading ? null : onPressed,
    icon: child,
    iconSize: iconSize,
    style: IconButton.styleFrom(
    minimumSize: Size(buttonSize, buttonSize),
    ),
    );
    case AppIconButtonVariant.filledTonal:
    return IconButton.filledTonal(
    onPressed: isLoading ? null : onPressed,
    icon: child,
    iconSize: iconSize,
    style: IconButton.styleFrom(
    minimumSize: Size(buttonSize, buttonSize),
    ), );
      case AppIconButtonVariant.outlined:
        return IconButton.outlined(
          onPressed: isLoading ? null : onPressed,
          icon: child,
          iconSize: iconSize,
          style: IconButton.styleFrom(
            minimumSize: Size(buttonSize, buttonSize),
          ),
        );
      case AppIconButtonVariant.standard:
        return IconButton(
          onPressed: isLoading ? null : onPressed,
          icon: child,
          iconSize: iconSize,
          style: IconButton.styleFrom(
            minimumSize: Size(buttonSize, buttonSize),
          ),
        );
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppIconButtonSize.small:
        return AppIcons.sizeS;
      case AppIconButtonSize.medium:
        return AppIcons.sizeM;
      case AppIconButtonSize.large:
        return AppIcons.sizeL;
    }
  }

  double _getButtonSize() {
    switch (size) {
      case AppIconButtonSize.small:
        return 18.0;
      case AppIconButtonSize.medium:
        return 26.0;
      case AppIconButtonSize.large:
        return 35.0;
    }
  }
}
