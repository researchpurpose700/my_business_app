import 'package:flutter/material.dart';

// Business Service Model
class BusinessService {
  final String id;
  final String name;
  final int orders;
  final double rating;
  final double price;
  final IconData icon;
  final Color color;
  final String description;
  final bool isActive;
  final DateTime createdAt;

  BusinessService({
    required this.id,
    required this.name,
    required this.orders,
    required this.rating,
    required this.price,
    required this.icon,
    required this.color,
    required this.description,
    this.isActive = true,
    required this.createdAt,
  });

  BusinessService copyWith({
    String? id,
    String? name,
    int? orders,
    double? rating,
    double? price,
    IconData? icon,
    Color? color,
    String? description,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return BusinessService(
      id: id ?? this.id,
      name: name ?? this.name,
      orders: orders ?? this.orders,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Business Services Service
class BusinessServicesService extends ChangeNotifier {
  static final BusinessServicesService _instance = BusinessServicesService._internal();
  factory BusinessServicesService() => _instance;
  BusinessServicesService._internal() {
    _initializeDummyData();
  }

  List<BusinessService> _services = [];
  bool _isLoading = false;

  // Getters
  List<BusinessService> get allServices => List.unmodifiable(_services);
  List<BusinessService> get activeServices =>
      _services.where((service) => service.isActive).toList();
  List<BusinessService> get topServices =>
      _services.where((s) => s.isActive).take(3).toList();
  List<BusinessService> get mostOrderedServices {
    final sortedServices = List<BusinessService>.from(activeServices);
    sortedServices.sort((a, b) => b.orders.compareTo(a.orders));
    return sortedServices;
  }
  bool get isLoading => _isLoading;
  int get totalServices => _services.length;
  int get activeServicesCount => activeServices.length;

  void _initializeDummyData() {
    _services = [
      BusinessService(
        id: '1',
        name: 'Kitchen Cabinet Making',
        orders: 25,
        rating: 4.8,
        price: 8500,
        icon: Icons.build,
        color: Colors.orange,
        description: 'Custom kitchen cabinets with modern designs',
        createdAt: DateTime.now().subtract(Duration(days: 30)),
      ),
      BusinessService(
        id: '2',
        name: 'Plumbing Services',
        orders: 18,
        rating: 4.6,
        price: 2500,
        icon: Icons.plumbing,
        color: Colors.blue,
        description: 'Complete plumbing solutions for homes and offices',
        createdAt: DateTime.now().subtract(Duration(days: 45)),
      ),
      BusinessService(
        id: '3',
        name: 'Electrical Work',
        orders: 12,
        rating: 4.7,
        price: 3200,
        icon: Icons.electrical_services,
        color: Colors.amber,
        description: 'Professional electrical installations and repairs',
        createdAt: DateTime.now().subtract(Duration(days: 20)),
      ),
      BusinessService(
        id: '4',
        name: 'Interior Design',
        orders: 8,
        rating: 4.9,
        price: 15000,
        icon: Icons.design_services,
        color: Colors.purple,
        description: 'Complete interior design and decoration services',
        createdAt: DateTime.now().subtract(Duration(days: 60)),
      ),
      BusinessService(
        id: '5',
        name: 'Painting Services',
        orders: 22,
        rating: 4.5,
        price: 1800,
        icon: Icons.format_paint,
        color: Colors.green,
        description: 'Interior and exterior painting with premium quality',
        createdAt: DateTime.now().subtract(Duration(days: 15)),
      ),
    ];
  }

  // Fetch all services (API ready)
  Future<void> fetchServices() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call
      await Future.delayed(Duration(milliseconds: 800));

      // In production: final response = await apiService.getBusinessServices();
      // _services = response.map((json) => BusinessService.fromJson(json)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Add new service
  Future<bool> addService(BusinessService service) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call
      await Future.delayed(Duration(milliseconds: 500));

      // In production: await apiService.createBusinessService(service.toJson());

      _services.add(service);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update service
  Future<bool> updateService(BusinessService updatedService) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call
      await Future.delayed(Duration(milliseconds: 500));

      final index = _services.indexWhere((s) => s.id == updatedService.id);
      if (index != -1) {
        _services[index] = updatedService;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Toggle service active status
  Future<bool> toggleServiceStatus(String serviceId) async {
    try {
      final service = _services.firstWhere((s) => s.id == serviceId);
      final updatedService = service.copyWith(isActive: !service.isActive);
      return await updateService(updatedService);
    } catch (e) {
      return false;
    }
  }

  // Increment order count (when order is placed)
  Future<void> incrementOrderCount(String serviceId) async {
    try {
      final service = _services.firstWhere((s) => s.id == serviceId);
      final updatedService = service.copyWith(orders: service.orders + 1);
      await updateService(updatedService);

      // In production: await apiService.incrementServiceOrders(serviceId);
    } catch (e) {
      // Handle error silently or log
    }
  }

  // Update service rating
  Future<bool> updateServiceRating(String serviceId, double newRating) async {
    try {
      final service = _services.firstWhere((s) => s.id == serviceId);
      final updatedService = service.copyWith(rating: newRating);
      return await updateService(updatedService);
    } catch (e) {
      return false;
    }
  }

  // Search services
  List<BusinessService> searchServices(String query) {
    if (query.isEmpty) return activeServices;

    return activeServices.where((service) =>
    service.name.toLowerCase().contains(query.toLowerCase()) ||
        service.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Get services by price range
  List<BusinessService> getServicesByPriceRange(double minPrice, double maxPrice) {
    return activeServices.where((service) =>
    service.price >= minPrice && service.price <= maxPrice
    ).toList();
  }

  // Get service by ID
  BusinessService? getServiceById(String id) {
    try {
      return _services.firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }
}