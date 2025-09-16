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
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.isLoading = false,
  }) : super(key: key);

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
    Key? key,
    required int ordersToday,
    required int ordersChange,
    VoidCallback? onTap,
    bool isLoading = false,
  }) : super(
    key: key,
    title: 'Orders Today',
    value: ordersToday.toString(),
    subtitle: '${ordersChange >= 0 ? '+' : ''}$ordersChange from yesterday',
    icon: AppIcons.orders,
    color: Colors.green,
    onTap: onTap,
    isLoading: isLoading,
  );
}

class EarningsStatsCard extends StatsCard {
  EarningsStatsCard({
    Key? key,
    required double earningsToday,
    required double earningsChange,
    VoidCallback? onTap,
    bool isLoading = false,
  }) : super(
    key: key,
    title: 'Earnings Today',
    value: '₹${_formatAmount(earningsToday)}',
    subtitle: '${earningsChange >= 0 ? '+' : ''}₹${_formatAmount(earningsChange)} from yesterday',
    icon: AppIcons.earnings,
    color: Colors.blue,
    onTap: onTap,
    isLoading: isLoading,
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
    Key? key,
    required int totalQueries,
    required int pendingQueries,
    VoidCallback? onTap,
    bool isLoading = false,
  }) : super(
    key: key,
    title: 'Queries',
    value: totalQueries.toString(),
    subtitle: '$pendingQueries pending',
    icon: AppIcons.queries,
    color: Colors.orange,
    onTap: onTap,
    isLoading: isLoading,
  );
}

class ComplaintsStatsCard extends StatsCard {
  ComplaintsStatsCard({
    Key? key,
    required int totalComplaints,
    required bool hasUrgent,
    VoidCallback? onTap,
    bool isLoading = false,
  }) : super(
    key: key,
    title: 'Complaints',
    value: totalComplaints.toString(),
    subtitle: hasUrgent ? 'Needs attention' : 'All resolved',
    icon: AppIcons.complaints,
    color: hasUrgent ? Colors.red : Colors.green,
    onTap: onTap,
    isLoading: isLoading,
  );
}

// Engagement stats card for story analytics
class EngagementStatsCard extends StatsCard {
  EngagementStatsCard({
    Key? key,
    required String type,
    required int value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) : super(
    key: key,
    title: type,
    value: value.toString(),
    subtitle: 'Total $type',
    icon: icon,
    color: color,
    onTap: onTap,
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