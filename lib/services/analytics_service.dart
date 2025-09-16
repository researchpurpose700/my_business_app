import 'dart:async';
import 'package:flutter/material.dart';

// Analytics Data Models
class DashboardStats {
  final int ordersToday;
  final int ordersYesterday;
  final double earningsToday;
  final double earningsYesterday;
  final int queriesTotal;
  final int queriesPending;
  final int complaintsTotal;
  final bool hasUrgentComplaints;

  DashboardStats({
    required this.ordersToday,
    required this.ordersYesterday,
    required this.earningsToday,
    required this.earningsYesterday,
    required this.queriesTotal,
    required this.queriesPending,
    required this.complaintsTotal,
    required this.hasUrgentComplaints,
  });

  int get ordersChange => ordersToday - ordersYesterday;
  double get earningsChange => earningsToday - earningsYesterday;
  String get queriesStatus => '$queriesPending pending';
  String get complaintsStatus => hasUrgentComplaints ? 'Needs attention' : 'All resolved';
}

class StoryAnalytics {
  final int totalViews;
  final int totalClicks;
  final int totalLikes;
  final int totalComments;
  final double engagementRate;
  final List<String> topPerformingStories;

  StoryAnalytics({
    required this.totalViews,
    required this.totalClicks,
    required this.totalLikes,
    required this.totalComments,
    required this.engagementRate,
    required this.topPerformingStories,
  });
}

// Analytics Service
class AnalyticsService extends ChangeNotifier {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal() {
    _initializeDummyData();
    _startPeriodicUpdates();
  }

  DashboardStats _dashboardStats = DashboardStats(
    ordersToday: 0,
    ordersYesterday: 0,
    earningsToday: 0.0,
    earningsYesterday: 0.0,
    queriesTotal: 0,
    queriesPending: 0,
    complaintsTotal: 0,
    hasUrgentComplaints: false,
  );

  StoryAnalytics _storyAnalytics = StoryAnalytics(
    totalViews: 0,
    totalClicks: 0,
    totalLikes: 0,
    totalComments: 0,
    engagementRate: 0.0,
    topPerformingStories: [],
  );

  Timer? _updateTimer;
  bool _isLoading = false;

  // Getters
  DashboardStats get dashboardStats => _dashboardStats;
  StoryAnalytics get storyAnalytics => _storyAnalytics;
  bool get isLoading => _isLoading;

  void _initializeDummyData() {
    _dashboardStats = DashboardStats(
      ordersToday: 12,
      ordersYesterday: 9,
      earningsToday: 4850.0,
      earningsYesterday: 3650.0,
      queriesTotal: 5,
      queriesPending: 2,
      complaintsTotal: 1,
      hasUrgentComplaints: true,
    );

    _storyAnalytics = StoryAnalytics(
      totalViews: 156,
      totalClicks: 23,
      totalLikes: 45,
      totalComments: 12,
      engagementRate: 14.7,
      topPerformingStories: ['Kitchen Cabinet Project', 'Bathroom Renovation'],
    );
  }

  void _startPeriodicUpdates() {
    _updateTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      _simulateRealTimeUpdates();
    });
  }

  void _simulateRealTimeUpdates() {
    // Simulate small incremental changes
    _dashboardStats = DashboardStats(
      ordersToday: _dashboardStats.ordersToday + (DateTime.now().minute % 3 == 0 ? 1 : 0),
      ordersYesterday: _dashboardStats.ordersYesterday,
      earningsToday: _dashboardStats.earningsToday + (DateTime.now().second % 10 == 0 ? 125.0 : 0),
      earningsYesterday: _dashboardStats.earningsYesterday,
      queriesTotal: _dashboardStats.queriesTotal,
      queriesPending: _dashboardStats.queriesPending,
      complaintsTotal: _dashboardStats.complaintsTotal,
      hasUrgentComplaints: _dashboardStats.hasUrgentComplaints,
    );

    notifyListeners();
  }

  // Refresh analytics data
  Future<void> refreshAnalytics() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call
      await Future.delayed(Duration(seconds: 1));

      // In production, fetch real data from API
      _calculateStoryAnalytics();
      _fetchBusinessAnalytics();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void _calculateStoryAnalytics() {
    // This would calculate from actual story data in production
    // For now, simulate updated data
    final random = DateTime.now().millisecond;
    _storyAnalytics = StoryAnalytics(
      totalViews: _storyAnalytics.totalViews + (random % 5),
      totalClicks: _storyAnalytics.totalClicks + (random % 2),
      totalLikes: _storyAnalytics.totalLikes + (random % 3),
      totalComments: _storyAnalytics.totalComments,
      engagementRate: _calculateEngagementRate(),
      topPerformingStories: _storyAnalytics.topPerformingStories,
    );
  }

  double _calculateEngagementRate() {
    if (_storyAnalytics.totalViews == 0) return 0.0;

    final totalEngagements = _storyAnalytics.totalClicks +
        _storyAnalytics.totalLikes +
        _storyAnalytics.totalComments;

    return (totalEngagements / _storyAnalytics.totalViews) * 100;
  }

  void _fetchBusinessAnalytics() {
    // In production, this would fetch from business analytics API
    // For now, keep existing data with minor updates
  }

  // Track specific events
  Future<void> trackStoryView(String storyId) async {
    // In production, send to analytics service
    _storyAnalytics = StoryAnalytics(
      totalViews: _storyAnalytics.totalViews + 1,
      totalClicks: _storyAnalytics.totalClicks,
      totalLikes: _storyAnalytics.totalLikes,
      totalComments: _storyAnalytics.totalComments,
      engagementRate: _calculateEngagementRate(),
      topPerformingStories: _storyAnalytics.topPerformingStories,
    );
    notifyListeners();
  }

  Future<void> trackStoryClick(String storyId) async {
    // In production, send to analytics service
    _storyAnalytics = StoryAnalytics(
      totalViews: _storyAnalytics.totalViews,
      totalClicks: _storyAnalytics.totalClicks + 1,
      totalLikes: _storyAnalytics.totalLikes,
      totalComments: _storyAnalytics.totalComments,
      engagementRate: _calculateEngagementRate(),
      topPerformingStories: _storyAnalytics.topPerformingStories,
    );
    notifyListeners();
  }

  Future<void> trackStoryLike(String storyId) async {
    // In production, send to analytics service
    _storyAnalytics = StoryAnalytics(
      totalViews: _storyAnalytics.totalViews,
      totalClicks: _storyAnalytics.totalClicks,
      totalLikes: _storyAnalytics.totalLikes + 1,
      totalComments: _storyAnalytics.totalComments,
      engagementRate: _calculateEngagementRate(),
      topPerformingStories: _storyAnalytics.topPerformingStories,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}