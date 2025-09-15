import 'package:flutter/material.dart';
import 'package:my_business_app/core/theme/dim.dart';
import '/utils/accessibility.dart';

enum AppCardVariant { filled, outlined, elevated }

class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? color;
  final String? semanticLabel;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.filled,
    this.onTap,
    this.padding,
    this.margin,
    this.elevation,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultPadding = EdgeInsets.all(Dim.m);
    final defaultMargin = EdgeInsets.all(Dim.s);

    Widget card = _buildCard(context, theme);

    if (onTap != null) {
      card = AccessibleWidget(
        semanticLabel: semanticLabel,
        onTap: onTap,
        child: card,
      );
    } else if (semanticLabel != null) {
      card = AccessibleWidget(
        semanticLabel: semanticLabel,
        child: card,
      );
    }

    return Container(
      margin: margin ?? defaultMargin,
      child: card,
    );
  }

  Widget _buildCard(BuildContext context, ThemeData theme) {
    final cardTheme = CardTheme.of(context);
    switch (variant) {
      case AppCardVariant.filled:
        return Card(
          elevation: elevation ?? cardTheme.elevation,
          color: color ?? cardTheme.color ?? theme.colorScheme.surface,
          margin: margin ?? cardTheme.margin,
          shape: cardTheme.shape,
          child: Padding(
            padding: padding ?? (cardTheme.margin != null ? EdgeInsets.zero : EdgeInsets.all(Dim.m)),
            child: child,
          ),
        );
      case AppCardVariant.outlined:
        return Card(
          elevation: elevation ?? 0,
          color: color ?? cardTheme.color ?? theme.colorScheme.surface,
          margin: margin ?? cardTheme.margin,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dim.radiusM),
            side: BorderSide(color: theme.colorScheme.outline, width: 1),
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.all(Dim.m),
            child: child,
          ),
        );
      case AppCardVariant.elevated:
        return Card(
          elevation: elevation ?? cardTheme.elevation ?? Dim.elevation4,
          color: color ?? cardTheme.color ?? theme.colorScheme.surface,
          margin: margin ?? cardTheme.margin,
          shape: cardTheme.shape,
          child: onTap != null
              ? InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(Dim.radiusM),
            child: Padding(
              padding: padding ?? EdgeInsets.all(Dim.m),
              child: child,
            ),
          )
              : Padding(
            padding: padding ?? EdgeInsets.all(Dim.m),
            child: child,
          ),
        );
    }
  }
}