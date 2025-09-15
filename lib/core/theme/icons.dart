import 'package:flutter/material.dart';
import 'dim.dart';

class AppIcons {
  // Icon sizes
  static const double sizeXs = 16.0;
  static const double sizeS = 20.0;
  static const double sizeM = 24.0;
  static const double sizeL = 32.0;
  static const double sizeXl = 40.0;

  // Default icon style
  static const IconThemeData defaultIconTheme = IconThemeData(
    size: sizeM,
    color: Colors.black54,
  );

  // Icon button configurations
  static const double iconButtonSize = 40.0; // legacy default
  static const double iconButtonSizeSmall = 32.0;
  static const double iconButtonSizeMedium = 40.0;
  static const double iconButtonSizeLarge = 48.0;
  static const double iconButtonPadding = Dim.s;

  // Common icons (Material Icons)
  static const IconData home = Icons.home;
  static const IconData search = Icons.search;
  static const IconData notifications = Icons.notifications;
  static const IconData settings = Icons.settings;
  static const IconData profile = Icons.person;
  static const IconData menu = Icons.menu;
  static const IconData close = Icons.close;
  static const IconData back = Icons.arrow_back;
  static const IconData forward = Icons.arrow_forward;
  static const IconData up = Icons.keyboard_arrow_up;
  static const IconData down = Icons.keyboard_arrow_down;
  static const IconData left = Icons.keyboard_arrow_left;
  static const IconData right = Icons.keyboard_arrow_right;
  static const IconData add = Icons.add;
  static const IconData remove = Icons.remove;
  static const IconData edit = Icons.edit;
  static const IconData delete = Icons.delete;
  static const IconData share = Icons.share;
  static const IconData favorite = Icons.favorite;
  static const IconData favoriteBorder = Icons.favorite_border;
  static const IconData star = Icons.star;
  static const IconData starBorder = Icons.star_border;
  static const IconData visibility = Icons.visibility;
  static const IconData visibilityOff = Icons.visibility_off;
  static const IconData info = Icons.info;
  static const IconData warning = Icons.warning;
  static const IconData error = Icons.error;
  static const IconData success = Icons.check_circle;
  static const IconData email = Icons.email;
  static const IconData phone = Icons.phone;
  static const IconData location = Icons.location_on;
  static const IconData calendar = Icons.calendar_today;
  static const IconData time = Icons.access_time;
  static const IconData download = Icons.download;
  static const IconData upload = Icons.upload;
  static const IconData refresh = Icons.refresh;
  static const IconData sync = Icons.sync;
  static const IconData filter = Icons.filter_list;
  static const IconData sort = Icons.sort;
  static const IconData grid = Icons.grid_view;
  static const IconData list = Icons.list;
  static const IconData card = Icons.view_agenda;

  // Navigation icons
  static const IconData bottomNavHome = Icons.home_outlined;
  static const IconData bottomNavHomeSelected = Icons.home;
  static const IconData bottomNavSearch = Icons.search_outlined;
  static const IconData bottomNavSearchSelected = Icons.search;
  static const IconData bottomNavFavorites = Icons.favorite_border;
  static const IconData bottomNavFavoritesSelected = Icons.favorite;
  static const IconData bottomNavProfile = Icons.person_outline;
  static const IconData bottomNavProfileSelected = Icons.person;

  // Helper method to get icon with specific size
  static Icon iconWithSize(IconData iconData, double size, {Color? color}) {
    return Icon(
      iconData,
      size: size,
      color: color,
    );
  }

  // Helper method to get themed icon
  static Icon themedIcon(IconData iconData, BuildContext context, {double? size}) {
    final theme = Theme.of(context);
    return Icon(
      iconData,
      size: size ?? sizeM,
      color: theme.iconTheme.color,
    );
  }
}
