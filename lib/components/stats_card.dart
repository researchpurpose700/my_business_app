import 'package:flutter/material.dart';
import 'package:my_business_app/utils/sizing.dart';
import 'package:my_business_app/utils/app_icons.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isLoading;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    AppSpacing.initialize(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row with icon and title
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: AppSpacing.iconSm,
                ),
                AppSpacing.horizontalSpaceSm,
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: AppSpacing.width(3.2), // ~12px on 375px width
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            AppSpacing.verticalSpaceSm,

            // Main value
            if (isLoading)
              SizedBox(
                height: AppSpacing.height(3), // ~24px
                width: AppSpacing.width(15), // ~60px
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            else
              Text(
                value,
                style: TextStyle(
                  fontSize: AppSpacing.width(6.4), // ~24px on 375px width
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

            AppSpacing.verticalSpaceXs,

            // Subtitle with change indicator
            Text(
              subtitle,
              style: TextStyle(
                color: color,
                fontSize: AppSpacing.width(3.2), // ~12px on 375px width
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Specialized stats cards for different data types
class OrderStatsCard extends StatsCard {
  OrderStatsCard({
    super.key,
    required int ordersToday,
    required int ordersChange,
    super.onTap,
    super.isLoading,
  }) : super(
    title: 'Orders Today',
    value: ordersToday.toString(),
    subtitle: '${ordersChange >= 0 ? '+' : ''}$ordersChange from yesterday',
    icon: AppIcons.orders,
    color: Colors.green,
  );
}

class EarningsStatsCard extends StatsCard {
  EarningsStatsCard({
    super.key,
    required double earningsToday,
    required double earningsChange,
    super.onTap,
    super.isLoading,
  }) : super(
    title: 'Earnings Today',
    value: '₹${_formatAmount(earningsToday)}',
    subtitle: '${earningsChange >= 0 ? '+' : ''}₹${_formatAmount(earningsChange)} from yesterday',
    icon: AppIcons.earnings,
    color: Colors.blue,
  );

  static String _formatAmount(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toInt().toString();
  }
}

class QueriesStatsCard extends StatsCard {
  QueriesStatsCard({
    super.key,
    required int totalQueries,
    required int pendingQueries,
    super.onTap,
    super.isLoading,
  }) : super(
    title: 'Queries',
    value: totalQueries.toString(),
    subtitle: '$pendingQueries pending',
    icon: AppIcons.queries,
    color: Colors.orange,
  );
}

class ComplaintsStatsCard extends StatsCard {
  ComplaintsStatsCard({
    super.key,
    required int totalComplaints,
    required bool hasUrgent,
    super.onTap,
    super.isLoading,
  }) : super(
    title: 'Complaints',
    value: totalComplaints.toString(),
    subtitle: hasUrgent ? 'Needs attention' : 'All resolved',
    icon: AppIcons.complaints,
    color: hasUrgent ? Colors.red : Colors.green,
  );
}

// Engagement stats card for story analytics
class EngagementStatsCard extends StatsCard {
  EngagementStatsCard({
    super.key,
    required String type,
    required int value,
    required super.icon,
    required super.color,
    super.onTap,
  }) : super(
    title: type,
    value: value.toString(),
    subtitle: 'Total $type',
  );

  factory EngagementStatsCard.views({
    required int views,
    VoidCallback? onTap,
  }) {
    return EngagementStatsCard(
      type: 'Views',
      value: views,
      icon: AppIcons.views,
      color: Colors.blue,
      onTap: onTap,
    );
  }

  factory EngagementStatsCard.clicks({
    required int clicks,
    VoidCallback? onTap,
  }) {
    return EngagementStatsCard(
      type: 'Clicks',
      value: clicks,
      icon: AppIcons.clicks,
      color: Colors.green,
      onTap: onTap,
    );
  }

  factory EngagementStatsCard.likes({
    required int likes,
    VoidCallback? onTap,
  }) {
    return EngagementStatsCard(
      type: 'Likes',
      value: likes,
      icon: AppIcons.likes,
      color: Colors.red,
      onTap: onTap,
    );
  }
}