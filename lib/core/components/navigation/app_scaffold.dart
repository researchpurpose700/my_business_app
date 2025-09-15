import 'package:flutter/material.dart';
// Removed unused imports to keep the scaffold lean and themed via AppTheme

class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final bool useSafeArea;
  final bool scrollBody;
  final EdgeInsetsGeometry? padding;
  final bool resizeToAvoidBottomInset;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.useSafeArea = true,
    this.scrollBody = false,
    this.padding,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      body: _buildBody(theme),
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      // Default to themed surface color if not provided
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }

  Widget _buildBody(ThemeData theme) {
    Widget content = body;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }
    if (scrollBody) {
      content = SingleChildScrollView(
        padding: padding == null ? EdgeInsets.zero : EdgeInsets.zero,
        child: content,
      );
    }
    if (useSafeArea) {
      content = SafeArea(child: content);
    }
    return content;
  }
}

class AppBottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final Color? color;

  const AppBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.color,
  });
}

class AppBottomNavigationBar extends StatelessWidget {
  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final BottomNavigationBarType? type;

  const AppBottomNavigationBar({
    super.key,
    required this.items,
    this.currentIndex = 0,
    this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: items.map((item) => BottomNavigationBarItem(
        icon: Icon(item.icon),
        activeIcon: item.activeIcon != null ? Icon(item.activeIcon!) : null,
        label: item.label,
      )).toList(),
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      type: type ?? (items.length > 3
          ? BottomNavigationBarType.fixed
          : BottomNavigationBarType.shifting),
    );
  }
}