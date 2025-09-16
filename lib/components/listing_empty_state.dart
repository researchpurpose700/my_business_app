import 'package:flutter/material.dart';
import 'package:my_business_app/utils/sizing.dart';

class ListingEmptyState extends StatelessWidget {
  final VoidCallback? onAddPressed;

  const ListingEmptyState({
    super.key,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizing.width(6.4)),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: AppSizing.width(5.3),
                  offset: Offset(0, AppSizing.width(2.7)),
                ),
              ],
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: AppSizing.width(17),
              color: Colors.blue.shade300,
            ),
          ),
          SizedBox(height: AppSizing.width(6.4)),
          Text(
            "No listings yet",
            style: TextStyle(
              fontSize: AppSizing.fontSize(20),
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: AppSizing.sm),
          Text(
            "Tap + to add your first listing",
            style: TextStyle(
              fontSize: AppSizing.fontSize(14),
              color: Colors.grey.shade500,
            ),
          ),
          if (onAddPressed != null) ...[
            SizedBox(height: AppSizing.lg),
            ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text("Add Listing"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizing.lg,
                  vertical: AppSizing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}