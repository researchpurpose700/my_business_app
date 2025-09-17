import 'package:flutter/material.dart';

class BusinessCategories {
  // Static list of business categories
  static const List<String> categories = [
    'Restaurant & Food',
    'Retail & Shopping',
    'Beauty & Wellness',
    'Healthcare',
    'Automotive',
    'Education & Training',
    'Professional Services',
    'Home & Garden',
    'Technology',
    'Entertainment',
    'Fitness & Sports',
    'Travel & Tourism',
    'Real Estate',
    'Manufacturing',
    'Construction',
    'Agriculture',
    'Transportation',
    'Financial Services',
    'Cleaning Services',
    'Repair Services',
    'Other',
  ];

  // Get localized category name (if you have translations)
  static String getLocalizedCategory(BuildContext context, String category) {
    // You can implement localization logic here
    // For now, returning the original category
    return category;
  }

  // Generate dropdown items for the ServiceDropdown
  static List<DropdownMenuItem<String>> getDropdownItems(BuildContext context) {
    return categories.map((category) {
      return DropdownMenuItem<String>(
        value: category,
        child: Text(
          getLocalizedCategory(context, category),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      );
    }).toList();
  }

  // Check if a category is valid
  static bool isValidCategory(String? category) {
    return category != null && categories.contains(category);
  }

  // Get category by index (useful for programmatic access)
  static String? getCategoryByIndex(int index) {
    if (index >= 0 && index < categories.length) {
      return categories[index];
    }
    return null;
  }

  // Search categories (useful for autocomplete)
  static List<String> searchCategories(String query) {
    if (query.isEmpty) return categories;

    return categories
        .where((category) =>
        category.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}