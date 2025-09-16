import 'package:flutter/material.dart';
import 'package:my_business_app/utils/sizing.dart';
import 'package:my_business_app/utils/app_icons.dart';
import 'package:my_business_app/services/business_services_service.dart';

class ServiceItemCard extends StatelessWidget {
  final BusinessService service;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;
  final bool showActions;
  final bool isCompact;

  const ServiceItemCard({
    Key? key,
    required this.service,
    this.onTap,
    this.onEdit,
    this.onToggleStatus,
    this.showActions = false,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppSpacing.initialize(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.verticalMd),
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
          border: service.isActive ? null : Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Service icon
            Container(
              width: AppSpacing.containerSmall,
              height: AppSpacing.containerSmall,
              decoration: BoxDecoration(
                color: service.isActive
                    ? service.color.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                service.icon,
                color: service.isActive ? service.color : Colors.grey,
                size: AppSpacing.iconMd,
              ),
            ),

            AppSpacing.horizontalSpaceMd,

            // Service details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service name with status indicator
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppSpacing.width(4.3), // ~16px on 375px width
                            color: service.isActive ? Colors.black87 : Colors.grey[600],
                          ),
                        ),
                      ),
                      if (!service.isActive)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                          ),
                          child: Text(
                            'Inactive',
                            style: TextStyle(
                              fontSize: AppSpacing.width(2.7), // ~10px
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),

                  AppSpacing.verticalSpaceXs,

                  // Service stats
                  if (isCompact)
                    _buildCompactStats()
                  else
                    _buildDetailedStats(),
                ],
              ),
            ),

            AppSpacing.horizontalSpaceMd,

            // Price and actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Price
                Text(
                  '₹${_formatPrice(service.price)}',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: AppSpacing.width(4), // ~15px on 375px width
                  ),
                ),

                if (showActions) ...[
                  AppSpacing.verticalSpaceXs,
                  _buildActionButtons(context),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStats() {
    return Text(
      '${service.orders} orders • ${service.rating}⭐',
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: AppSpacing.width(3.5), // ~13px on 375px width
      ),
    );
  }

  Widget _buildDetailedStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${service.orders} orders this month',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: AppSpacing.width(3.5), // ~13px on 375px width
          ),
        ),
        AppSpacing.verticalSpaceXs,
        Row(
          children: [
            Icon(
              AppIcons.star,
              color: Colors.amber,
              size: AppSpacing.width(4), // ~15px
            ),
            AppSpacing.horizontalSpaceXs,
            Text(
              '${service.rating} rating',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: AppSpacing.width(3.5), // ~13px on 375px width
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit button
        if (onEdit != null)
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
              child: Icon(
                AppIcons.edit,
                size: AppSpacing.iconXs,
                color: Colors.blue,
              ),
            ),
          ),

        if (onEdit != null && onToggleStatus != null)
          AppSpacing.horizontalSpaceXs,

        // Toggle status button
        if (onToggleStatus != null)
          GestureDetector(
            onTap: onToggleStatus,
            child: Container(
              padding: EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: service.isActive ? Colors.red[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
              child: Icon(
                service.isActive ? Icons.pause : Icons.play_arrow,
                size: AppSpacing.iconXs,
                color: service.isActive ? Colors.red : Colors.green,
              ),
            ),
          ),
      ],
    );
  }

  String _formatPrice(double price) {
    if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(1)}L';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}K';
    }
    return price.toInt().toString();
  }
}

// Specialized service cards for different layouts
class ServiceSummaryCard extends ServiceItemCard {
  const ServiceSummaryCard({
    Key? key,
    required BusinessService service,
    VoidCallback? onTap,
  }) : super(
    key: key,
    service: service,
    onTap: onTap,
    isCompact: true,
  );
}

class ServiceManagementCard extends ServiceItemCard {
  const ServiceManagementCard({
    Key? key,
    required BusinessService service,
    VoidCallback? onTap,
    VoidCallback? onEdit,
    VoidCallback? onToggleStatus,
  }) : super(
    key: key,
    service: service,
    onTap: onTap,
    onEdit: onEdit,
    onToggleStatus: onToggleStatus,
    showActions: true,
    isCompact: false,
  );
}