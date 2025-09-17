import 'package:uuid/uuid.dart';
import 'package:my_business_app/config/save_data.dart';
import 'package:my_business_app/utils/error_handling.dart';

class Listing {
  final String id;
  String title;
  String experience;
  String price;
  String warranty;
  String status;
  String description;
  List<String> imagePaths;
  String type; // "Seller" or "Service"
  DateTime createdAt;
  DateTime updatedAt;

  Listing({
    required this.id,
    required this.title,
    required this.experience,
    required this.price,
    required this.warranty,
    required this.status,
    required this.description,
    required this.imagePaths,
    required this.type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Helper getter for backward compatibility
  String get imagePath => imagePaths.isNotEmpty ? imagePaths.first : "";

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'experience': experience,
      'price': price,
      'warranty': warranty,
      'status': status,
      'description': description,
      'imagePaths': imagePaths,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      experience: json['experience'] ?? '',
      price: json['price'] ?? '',
      warranty: json['warranty'] ?? '',
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      imagePaths: List<String>.from(json['imagePaths'] ?? []),
      type: json['type'] ?? 'Seller',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Listing copyWith({
    String? title,
    String? experience,
    String? price,
    String? warranty,
    String? status,
    String? description,
    List<String>? imagePaths,
    String? type,
  }) {
    return Listing(
      id: id,
      title: title ?? this.title,
      experience: experience ?? this.experience,
      price: price ?? this.price,
      warranty: warranty ?? this.warranty,
      status: status ?? this.status,
      description: description ?? this.description,
      imagePaths: imagePaths ?? this.imagePaths,
      type: type ?? this.type,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class ListingService {
  static ListingService? _instance;
  static ListingService get instance => _instance ??= ListingService._();
  ListingService._();

  static const String _storageKey = 'listings';
  static const Uuid _uuid = Uuid();

  List<Listing> _listings = [];
  List<Listing> get listings => List.unmodifiable(_listings);

  // Initialize and load existing listings
  Future<void> initialize() async {
    try {
      await _loadListings();
    } catch (e) {
      ListingErrorHandler.handleStorageError(e);
    }
  }

  // Load listings from storage
  Future<void> _loadListings() async {
    final data = await LocalStorage.loadProfile();
    if (data != null && data[_storageKey] != null) {
      final listingsJson = data[_storageKey] as List;
      _listings = listingsJson
          .map((json) => Listing.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }
  }

  // Save listings to storage
  Future<bool> _saveListings() async {
    try {
      final listingsJson = _listings.map((listing) => listing.toJson()).toList();
      await LocalStorage.upsertProfile({_storageKey: listingsJson});
      return true;
    } catch (e) {
      ListingErrorHandler.handleStorageError(e);
      return false;
    }
  }

  // Add new listing
  Future<bool> addListing(Listing listing) async {
    try {
      _listings.add(listing);
      return await _saveListings();
    } catch (e) {
      ListingErrorHandler.handleAddError(e);
      return false;
    }
  }

  // Update existing listing
  Future<bool> updateListing(String id, Listing updatedListing) async {
    try {
      final index = _listings.indexWhere((listing) => listing.id == id);
      if (index == -1) {
        throw Exception('Listing not found');
      }
      _listings[index] = updatedListing;
      return await _saveListings();
    } catch (e) {
      ListingErrorHandler.handleUpdateError(e);
      return false;
    }
  }

  // Delete listing
  Future<bool> deleteListing(String id) async {
    try {
      _listings.removeWhere((listing) => listing.id == id);
      return await _saveListings();
    } catch (e) {
      ListingErrorHandler.handleDeleteError(e);
      return false;
    }
  }

  // Get listing by ID
  Listing? getListingById(String id) {
    try {
      return _listings.firstWhere((listing) => listing.id == id);
    } catch (e) {
      return null;
    }
  }

  // Generate unique ID for new listings
  String generateListingId() {
    return _uuid.v4();
  }

  // Get status options based on listing type
  List<String> getStatusOptions(String listingType) {
    if (listingType == "Service") {
      return ["Available", "Busy"];
    } else {
      return ["In Stock", "Out of Stock"];
    }
  }

  // Get default status for listing type
  String getDefaultStatus(String listingType) {
    return listingType == "Service" ? "Available" : "In Stock";
  }

  // Search listings by title
  List<Listing> searchListings(String query) {
    if (query.isEmpty) return listings;

    final lowercaseQuery = query.toLowerCase();
    return _listings.where((listing) =>
    listing.title.toLowerCase().contains(lowercaseQuery) ||
        listing.description.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  // Filter listings by type
  List<Listing> getListingsByType(String type) {
    return _listings.where((listing) => listing.type == type).toList();
  }

  // Filter listings by status
  List<Listing> getListingsByStatus(String status) {
    return _listings.where((listing) => listing.status == status).toList();
  }

  // Clear all listings
  Future<bool> clearAllListings() async {
    try {
      _listings.clear();
      return await _saveListings();
    } catch (e) {
      ListingErrorHandler.handleStorageError(e);
      return false;
    }
  }

  // Get listings count
  int get listingsCount => _listings.length;

  // Check if listings exist
  bool get hasListings => _listings.isNotEmpty;
}