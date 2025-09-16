import 'package:flutter/material.dart';

// Centralized icons for the application
class AppIcons {
  // Navigation icons
  static const IconData home = Icons.home;
  static const IconData homeOutlined = Icons.home_outlined;
  static const IconData back = Icons.arrow_back;
  static const IconData close = Icons.close;
  static const IconData menu = Icons.menu;

  // Story and content icons
  static const IconData story = Icons.circle;
  static const IconData addStory = Icons.add_circle_outline;
  static const IconData camera = Icons.camera_alt;
  static const IconData cameraOutlined = Icons.camera_alt_outlined;
  static const IconData video = Icons.videocam;
  static const IconData videoOutlined = Icons.videocam_outlined;
  static const IconData image = Icons.image;
  static const IconData imageOutlined = Icons.image_outlined;
  static const IconData gallery = Icons.photo_library;
  static const IconData edit = Icons.edit;
  static const IconData textPost = Icons.text_fields;

  // Engagement icons
  static const IconData views = Icons.visibility;
  static const IconData viewsOutlined = Icons.visibility_outlined;
  static const IconData clicks = Icons.touch_app;
  static const IconData clicksOutlined = Icons.touch_app_outlined;
  static const IconData likes = Icons.favorite;
  static const IconData likesOutlined = Icons.favorite_outline;
  static const IconData comments = Icons.comment;
  static const IconData commentsOutlined = Icons.comment_outlined;
  static const IconData share = Icons.share;
  static const IconData shareOutlined = Icons.share_outlined;

  // Business and service icons
  static const IconData services = Icons.build;
  static const IconData kitchen = Icons.kitchen;
  static const IconData plumbing = Icons.plumbing;
  static const IconData electrical = Icons.electrical_services;
  static const IconData design = Icons.design_services;
  static const IconData painting = Icons.format_paint;
  static const IconData orders = Icons.shopping_bag;
  static const IconData ordersOutlined = Icons.shopping_bag_outlined;
  static const IconData earnings = Icons.account_balance_wallet;
  static const IconData earningsOutlined = Icons.account_balance_wallet_outlined;

  // Communication icons
  static const IconData notifications = Icons.notifications;
  static const IconData notificationsOutlined = Icons.notifications_outlined;
  static const IconData messages = Icons.message;
  static const IconData messagesOutlined = Icons.message_outlined;
  static const IconData queries = Icons.help_outline;
  static const IconData complaints = Icons.warning;
  static const IconData complaintsOutlined = Icons.warning_outlined;

  // User and profile icons
  static const IconData person = Icons.person;
  static const IconData personOutlined = Icons.person_outlined;
  static const IconData profile = Icons.account_circle;
  static const IconData profileOutlined = Icons.account_circle_outlined;

  // Action icons
  static const IconData add = Icons.add;
  static const IconData delete = Icons.delete;
  static const IconData deleteOutlined = Icons.delete_outlined;
  static const IconData search = Icons.search;
  static const IconData filter = Icons.filter_list;
  static const IconData sort = Icons.sort;
  static const IconData refresh = Icons.refresh;
  static const IconData settings = Icons.settings;
  static const IconData settingsOutlined = Icons.settings_outlined;

  // Status and feedback icons
  static const IconData success = Icons.check_circle;
  static const IconData error = Icons.error;
  static const IconData warning = Icons.warning_amber;
  static const IconData info = Icons.info;
  static const IconData loading = Icons.hourglass_empty;

  // Camera specific icons
  static const IconData cameraSwitch = Icons.cameraswitch;
  static const IconData flash = Icons.flash_on;
  static const IconData flashOff = Icons.flash_off;
  static const IconData record = Icons.fiber_manual_record;
  static const IconData stop = Icons.stop;
  static const IconData play = Icons.play_arrow;
  static const IconData pause = Icons.pause;

  // Rating and review icons
  static const IconData star = Icons.star;
  static const IconData starOutlined = Icons.star_outline;
  static const IconData starHalf = Icons.star_half;

  // Promotional icons
  static const IconData promote = Icons.trending_up;
  static const IconData boost = Icons.rocket_launch;
  static const IconData visibility = Icons.visibility;

  // Utility function to get service icon by service name
  static IconData getServiceIcon(String serviceName) {
    switch (serviceName.toLowerCase()) {
      case 'kitchen cabinet making':
      case 'kitchen':
        return kitchen;
      case 'plumbing services':
      case 'plumbing':
        return plumbing;
      case 'electrical work':
      case 'electrical':
        return electrical;
      case 'interior design':
      case 'design':
        return design;
      case 'painting services':
      case 'painting':
        return painting;
      default:
        return services;
    }
  }

  // Utility function to get engagement icon
  static IconData getEngagementIcon(String type) {
    switch (type.toLowerCase()) {
      case 'views':
        return views;
      case 'clicks':
        return clicks;
      case 'likes':
        return likes;
      case 'comments':
        return comments;
      default:
        return info;
    }
  }

  // ============================================================================
  // WIDGET BUILDERS
  // ============================================================================

  // Business logo widget
  static Widget businessLogo({double? size}) {
    // Note: This needs AppSizing to be imported in the file where it's used
    final logoSize = size ?? 64.0; // Default size if AppSizing not available
    final radiusSize = logoSize * 0.15; // Proportional radius

    return Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radiusSize),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radiusSize),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              Icons.store,
              size: logoSize * 0.6,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // Floating background circles for decoration
  static Widget floatingCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
    );
  }

  // Background decoration with floating circles
  static Widget backgroundDecoration({double? screenWidth, double? screenHeight}) {
    // Default values if screen dimensions not provided
    final width = screenWidth ?? 400.0;
    final height = screenHeight ?? 800.0;

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: height * 0.12,
          left: width * 0.13,
          child: floatingCircle(width * 0.16),
        ),
        Positioned(
          bottom: height * 0.18,
          right: width * 0.10,
          child: floatingCircle(width * 0.21),
        ),
        Positioned(
          bottom: height * 0.12,
          left: width * 0.26,
          child: floatingCircle(width * 0.10),
        ),
      ],
    );
  }
}