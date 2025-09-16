import 'package:flutter/material.dart';
import 'package:my_business_app/utils/sizing.dart';
import 'package:my_business_app/utils/app_icons.dart';
import 'package:my_business_app/utils/error_handling.dart';

// Services
import 'package:my_business_app/services/story_service.dart';
import 'package:my_business_app/services/analytics_service.dart';
import 'package:my_business_app/services/business_services_service.dart';

// Widgets
import 'package:my_business_app/components/story_card.dart';
import 'package:my_business_app/components/stats_card.dart';
import 'package:my_business_app/components/service_item_card.dart';
import 'package:my_business_app/components/create_story_modal.dart';
import 'package:my_business_app/components/story_detail_modal.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Services
  final StoryService _storyService = StoryService();
  final AnalyticsService _analyticsService = AnalyticsService();
  final BusinessServicesService _businessService = BusinessServicesService();

  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    // Listen to service changes
    _storyService.addListener(_onStoryServiceUpdate);
    _analyticsService.addListener(_onAnalyticsUpdate);
    _businessService.addListener(_onBusinessServiceUpdate);
  }

  @override
  void dispose() {
    _storyService.removeListener(_onStoryServiceUpdate);
    _analyticsService.removeListener(_onAnalyticsUpdate);
    _businessService.removeListener(_onBusinessServiceUpdate);
    super.dispose();
  }

  void _onStoryServiceUpdate() {
    if (mounted) setState(() {});
  }

  void _onAnalyticsUpdate() {
    if (mounted) setState(() {});
  }

  void _onBusinessServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    AppSpacing.initialize(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: AppSpacing.screenPaddingHorizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.verticalSpaceMd,

                  // Header
                  _buildHeader(),

                  AppSpacing.verticalSpaceLg,

                  // Story Section
                  _buildStorySection(),

                  AppSpacing.verticalSpaceLg,

                  // Today's Overview
                  _buildTodaysOverview(),

                  AppSpacing.verticalSpaceMd,

                  // Stats Cards
                  _buildStatsSection(),

                  AppSpacing.verticalSpaceLg,

                  // Services Section
                  _buildServicesSection(),

                  AppSpacing.verticalSpaceLg,

                  // Promotional Card
                  _buildPromotionalCard(),

                  AppSpacing.verticalSpaceLg,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Townzy Partners',
              style: TextStyle(
                fontSize: AppSpacing.width(6.4), // ~24px
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            AppSpacing.verticalSpaceXs,
            Text(
              'Good morning, Raj',
              style: TextStyle(
                fontSize: AppSpacing.width(4), // ~15px
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Notifications
            IconButton(
              onPressed: _showNotifications,
              icon: Icon(
                AppIcons.notificationsOutlined,
                size: AppSpacing.iconMd,
                color: Colors.grey[700],
              ),
            ),

            // Messages with badge
            Stack(
              children: [
                IconButton(
                  onPressed: _showMessages,
                  icon: Icon(
                    AppIcons.messagesOutlined,
                    size: AppSpacing.iconMd,
                    color: Colors.grey[700],
                  ),
                ),
                Positioned(
                  right: AppSpacing.sm,
                  top: AppSpacing.sm,
                  child: Container(
                    width: AppSpacing.width(4.3), // ~16px
                    height: AppSpacing.width(4.3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppSpacing.width(2.7), // ~10px
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStorySection() {
    return Column(
      children: [
        if (_storyService.hasStory)
          StoryCard(
            story: _storyService.currentStory!,
            onTap: _showStoryDetails,
            onCreateStory: _showCreateStory,
            userName: 'Your Story',
            isCurrentUser: true,
          )
        else
          CreateStoryCard(onTap: _showCreateStory),
      ],
    );
  }

  Widget _buildTodaysOverview() {
    return Text(
      "Today's Overview",
      style: TextStyle(
        fontSize: AppSpacing.width(5.3), // ~20px
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildStatsSection() {
    final stats = _analyticsService.dashboardStats;

    return Column(
      children: [
        // Top row
        Row(
          children: [
            Expanded(
              child: OrderStatsCard(
                ordersToday: stats.ordersToday,
                ordersChange: stats.ordersChange,
                onTap: _showOrderDetails,
                isLoading: _analyticsService.isLoading,
              ),
            ),
            AppSpacing.horizontalSpaceMd,
            Expanded(
              child: EarningsStatsCard(
                earningsToday: stats.earningsToday,
                earningsChange: stats.earningsChange,
                onTap: _showEarningsDetails,
                isLoading: _analyticsService.isLoading,
              ),
            ),
          ],
        ),

        AppSpacing.verticalSpaceMd,

        // Bottom row
        Row(
          children: [
            Expanded(
              child: QueriesStatsCard(
                totalQueries: stats.queriesTotal,
                pendingQueries: stats.queriesPending,
                onTap: _showQueriesDetails,
                isLoading: _analyticsService.isLoading,
              ),
            ),
            AppSpacing.horizontalSpaceMd,
            Expanded(
              child: ComplaintsStatsCard(
                totalComplaints: stats.complaintsTotal,
                hasUrgent: stats.hasUrgentComplaints,
                onTap: _showComplaintsDetails,
                isLoading: _analyticsService.isLoading,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServicesSection() {
    final topServices = _businessService.mostOrderedServices.take(2).toList();

    return Column(
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Most Ordered',
              style: TextStyle(
                fontSize: AppSpacing.width(5.3), // ~20px
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: _showAllServices,
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: AppSpacing.width(3.7), // ~14px
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        AppSpacing.verticalSpaceMd,

        // Service cards
        if (_businessService.isLoading)
          _buildLoadingServices()
        else if (topServices.isEmpty)
          _buildEmptyServices()
        else
          Column(
            children: topServices.map((service) =>
                ServiceSummaryCard(
                  service: service,
                  onTap: () => _showServiceDetails(service),
                ),
            ).toList(),
          ),
      ],
    );
  }

  Widget _buildLoadingServices() {
    return Column(
      children: [
        _buildServiceSkeleton(),
        _buildServiceSkeleton(),
      ],
    );
  }

  Widget _buildServiceSkeleton() {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.verticalMd),
      height: AppSpacing.height(10), // ~80px
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyServices() {
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            AppIcons.services,
            size: AppSpacing.iconLg,
            color: Colors.grey[400],
          ),
          AppSpacing.verticalSpaceMd,
          Text(
            'No services available',
            style: TextStyle(
              fontSize: AppSpacing.width(4.3), // ~16px
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionalCard() {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Boost Your Listings',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppSpacing.width(4.8), // ~18px
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.verticalSpaceXs,
          Text(
            'Get 3x more visibility',
            style: TextStyle(
              color: Colors.white70,
              fontSize: AppSpacing.width(3.7), // ~14px
            ),
          ),
          AppSpacing.verticalSpaceMd,
          SizedBox(
            height: AppSpacing.buttonSmallHeight,
            child: ElevatedButton(
              onPressed: _showPromotionOptions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
              child: Text(
                'Promote Now',
                style: TextStyle(
                  fontSize: AppSpacing.width(3.7), // ~14px
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Event handlers
  void _showCreateStory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateStoryModal(
        onStoryCreated: (story) {
          if (mounted) {
            setState(() {}); // Refresh UI
            ErrorHandler.showSuccessSnackBar(context, 'Story created successfully!');
          }
        },
      ),
    );
  }

  void _showStoryDetails() {
    if (_storyService.currentStory == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StoryDetailsModal(
        story: _storyService.currentStory!,
        onStoryUpdated: (story) {
          if (mounted) {
            setState(() {}); // Refresh UI
          }
        },
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);

    try {
      await Future.wait([
        _analyticsService.refreshAnalytics(),
        _businessService.fetchServices(),
      ]);
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  // Placeholder methods for navigation
  void _showNotifications() {
    ErrorHandler.showErrorSnackBar(context, 'Notifications will be implemented soon');
  }

  void _showMessages() {
    ErrorHandler.showErrorSnackBar(context, 'Messages will be implemented soon');
  }

  void _showOrderDetails() {
    ErrorHandler.showErrorSnackBar(context, 'Order details will be implemented soon');
  }

  void _showEarningsDetails() {
    ErrorHandler.showErrorSnackBar(context, 'Earnings details will be implemented soon');
  }

  void _showQueriesDetails() {
    ErrorHandler.showErrorSnackBar(context, 'Queries details will be implemented soon');
  }

  void _showComplaintsDetails() {
    ErrorHandler.showErrorSnackBar(context, 'Complaints details will be implemented soon');
  }

  void _showServiceDetails(service) {
    ErrorHandler.showErrorSnackBar(context, 'Service details will be implemented soon');
  }

  void _showAllServices() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllServicesPage(businessService: _businessService),
      ),
    );
  }

  void _showPromotionOptions() {
    ErrorHandler.showErrorSnackBar(context, 'Promotion options will be implemented soon');
  }
}

// All Services Page
class AllServicesPage extends StatelessWidget {
  final BusinessServicesService businessService;

  const AllServicesPage({
    Key? key,
    required this.businessService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppSpacing.initialize(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('All Services'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: businessService.isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: AppSpacing.screenPaddingHorizontal,
        itemCount: businessService.activeServices.length,
        itemBuilder: (context, index) {
          final service = businessService.activeServices[index];
          return ServiceItemCard(
            service: service,
            onTap: () {
              // Handle service tap
              ErrorHandler.showErrorSnackBar(
                context,
                'Service details will be implemented soon',
              );
            },
            isCompact: false,
          );
        },
      ),
    );
  }
}