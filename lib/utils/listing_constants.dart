import 'package:flutter/material.dart';

class ListingConstants {
  // ============================================================================
  // LISTING LIMITS
  // ============================================================================

  static const int maxImages = 5;
  static const int maxTitleLength = 50;
  static const int maxExperienceLength = 8;
  static const int maxWarrantyLength = 8;
  static const int maxDescriptionLength = 300;
  static const int maxPriceValue = 99999;
  static const int minDescriptionLength = 10;

  // ============================================================================
  // LISTING TYPES AND STATUS
  // ============================================================================

  static const List<String> listingTypes = ["Seller", "Service"];
  static const List<String> sellerStatuses = ["In Stock", "Out of Stock"];
  static const List<String> serviceStatuses = ["Available", "Busy"];

  static const Map<String, String> listingTypeLabels = {
    "Seller": "🏪 Seller",
    "Service": "🛠 Service",
  };

  static const Map<String, IconData> listingTypeIcons = {
    "Seller": Icons.inventory_2_outlined,
    "Service": Icons.handyman_outlined,
  };

  // ============================================================================
  // STATUS COLORS
  // ============================================================================

  static const Map<String, Color> statusColors = {
    "In Stock": Colors.green,
    "Available": Colors.green,
    "Out of Stock": Colors.orange,
    "Busy": Colors.orange,
  };

  // ============================================================================
  // FORM FIELD CONFIGURATIONS
  // ============================================================================

  static const Map<String, String> fieldLabels = {
    "title_seller": "Product Name",
    "title_service": "Service Name",
    "description_seller": "Product Description",
    "description_service": "Service Description",
    "experience": "Experience",
    "warranty": "Warranty",
    "price": "Price",
    "status": "Status",
    "images": "Add Photos",
  };

  static const Map<String, String> fieldHints = {
    "title": "Enter a descriptive name...",
    "experience": "e.g., 5 years, Expert level",
    "warranty": "e.g., 1 year, 6 months",
    "price": "Enter amount",
    "description_seller": "Tell us about your product...",
    "description_service": "Tell us about your service...",
  };

  static const Map<String, IconData> fieldIcons = {
    "title_seller": Icons.inventory_2_outlined,
    "title_service": Icons.handyman_outlined,
    "experience": Icons.timeline,
    "warranty": Icons.verified_outlined,
    "price": Icons.currency_rupee,
    "description": Icons.description_outlined,
    "status": Icons.info_outline,
    "images": Icons.add_photo_alternate,
  };

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get status options for a listing type
  static List<String> getStatusOptions(String listingType) {
    return listingType == "Service" ? serviceStatuses : sellerStatuses;
  }

  /// Get default status for a listing type
  static String getDefaultStatus(String listingType) {
    return listingType == "Service" ? "Available" : "In Stock";
  }

  /// Get status color
  static Color getStatusColor(String status) {
    return statusColors[status] ?? Colors.grey;
  }

  /// Get listing type icon
  static IconData getListingTypeIcon(String listingType) {
    return listingTypeIcons[listingType] ?? Icons.help_outline;
  }

  /// Get field label based on listing type
  static String getFieldLabel(String field, String listingType) {
    if (field == "title") {
      return listingType == "Service" ? fieldLabels["title_service"]! : fieldLabels["title_seller"]!;
    } else if (field == "description") {
      return listingType == "Service" ? fieldLabels["description_service"]! : fieldLabels["description_seller"]!;
    }
    return fieldLabels[field] ?? field;
  }

  /// Get field hint based on listing type
  static String getFieldHint(String field, String listingType) {
    if (field == "description") {
      return listingType == "Service" ? fieldHints["description_service"]! : fieldHints["description_seller"]!;
    }
    return fieldHints[field] ?? "";
  }

  /// Get field icon based on listing type
  static IconData getFieldIcon(String field, String listingType) {
    if (field == "title") {
      return listingType == "Service" ? fieldIcons["title_service"]! : fieldIcons["title_seller"]!;
    }
    return fieldIcons[field] ?? Icons.help_outline;
  }

  /// Check if field is required for listing type
  static bool isFieldRequired(String field, String listingType) {
    switch (field) {
      case "title":
      case "price":
      case "description":
      case "status":
        return true;
      case "experience":
        return listingType == "Service";
      case "warranty":
        return listingType == "Seller"; // Required for products, optional for services
      case "images":
        return false; // Images are optional by default
      default:
        return false;
    }
  }

  /// Get character limits for fields
  static int getFieldLimit(String field) {
    switch (field) {
      case "title":
        return maxTitleLength;
      case "experience":
        return maxExperienceLength;
      case "warranty":
        return maxWarrantyLength;
      case "description":
        return maxDescriptionLength;
      default:
        return 100;
    }
  }
}