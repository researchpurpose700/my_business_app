import 'package:flutter/material.dart';
import '/core/theme/dim.dart';
import '/core/theme/icons.dart';
import '/utils/accessibility.dart';

class AppListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool dense;
  final bool enabled;
  final EdgeInsetsGeometry? contentPadding;
  final String? semanticLabel;

  const AppListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.dense = false,
    this.enabled = true,
    this.contentPadding,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AccessibleWidget(
      semanticLabel: semanticLabel,
      onTap: onTap,
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        dense: dense,
        enabled: enabled,
        contentPadding: contentPadding ?? EdgeInsets.symmetric(
          horizontal: Dim.m,
          vertical: dense ? Dim.s : Dim.xs,
        ),
        minVerticalPadding: dense ? Dim.xs : Dim.s,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dim.radiusS),
        ),
      ),
    );
  }
}

class AppListTileIcon extends StatelessWidget {
  final IconData icon;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool enabled;

  const AppListTileIcon({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(Dim.radiusS),
        ),
        child: Icon(
          icon,
          size: AppIcons.sizeM,
          color: iconColor ?? theme.colorScheme.primary,
        ),
      ),
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      enabled: enabled,
    );
  }
}

class AppListTileAvatar extends StatelessWidget {
  final Widget avatar;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  const AppListTileAvatar({
    super.key,
    required this.avatar,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      leading: SizedBox(
        width: 40,
        height: 40,
        child: avatar,
      ),
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      enabled: enabled,
    );
  }
}