import 'package:flutter/material.dart';
import 'dart:async';

/// Custom hooks and utility functions for components

/// Debounce hook for search inputs
class DebouncedValue<T> {
  final T value;
  final Duration delay;
  Timer? _timer;

  DebouncedValue(this.value, {this.delay = const Duration(milliseconds: 500)});

  void call(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Hook for managing form validation state
class FormValidationState {
  final Map<String, String?> _errors = {};
  final ValueNotifier<bool> _isValid = ValueNotifier(true);

  ValueNotifier<bool> get isValid => _isValid;

  void setError(String field, String? error) {
    if (error == null) {
      _errors.remove(field);
    } else {
      _errors[field] = error;
    }
    _updateValidState();
  }

  String? getError(String field) => _errors[field];

  void clearErrors() {
    _errors.clear();
    _updateValidState();
  }

  void _updateValidState() {
    _isValid.value = _errors.isEmpty;
  }

  void dispose() {
    _isValid.dispose();
  }
}

/// Hook for managing loading states
class LoadingState {
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<String?> _error = ValueNotifier(null);

  ValueNotifier<bool> get isLoading => _isLoading;
  ValueNotifier<String?> get error => _error;

  Future<T> execute<T>(Future<T> Function() operation) async {
    _isLoading.value = true;
    _error.value = null;

    try {
      final result = await operation();
      return result;
    } catch (e) {
      _error.value = e.toString();
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  void dispose() {
    _isLoading.dispose();
    _error.dispose();
  }
}

/// Hook for responsive design
class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static T responsive<T>(
      BuildContext context, {
        required T mobile,
        T? tablet,
        T? desktop,
      }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }
}

/// Animation helper
class AnimationHelper {
  static AnimationController createController(
      TickerProvider vsync, {
        Duration duration = const Duration(milliseconds: 300),
      }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
    );
  }

  static Animation<double> createFadeAnimation(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  static Animation<Offset> createSlideAnimation(
      AnimationController controller, {
        Offset begin = const Offset(0.0, 1.0),
        Offset end = Offset.zero,
      }) {
    return Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }
}
