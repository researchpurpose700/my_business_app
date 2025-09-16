import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_business_app/services/listing_service.dart';
import 'package:my_business_app/utils/sizing.dart';
import 'package:my_business_app/utils/listing_constants.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ListingCard({
    super.key,
    required this.listing,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: AppSizing.width(3),
            offset: Offset(0, AppSizing.width(1)),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
        child: Padding(
          padding: EdgeInsets.all(AppSizing.sm),
          child: Row(
            children: [
              // Product Image
              _buildImageWidget(),
              SizedBox(width: AppSizing.xs + 2),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      listing.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                        fontSize: AppSizing.fontSize(18),
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Price
                    Text(
                      "₹${listing.price}",
                      style: TextStyle(
                        fontSize: AppSizing.fontSize(20),
                        fontWeight: FontWeight.w400,
                        color: Colors.green.shade600,
                      ),
                    ),

                    // ID and Status Row
                    Row(
                      children: [
                        _buildUidBadge(),
                        SizedBox(width: AppSizing.xs),
                        _buildStatusBadge(),
                      ],
                    ),
                    SizedBox(height: AppSizing.xs / 2),

                    // Description
                    if (listing.description.isNotEmpty)
                      Text(
                        listing.description,
                        style: TextStyle(
                          fontSize: AppSizing.fontSize(14),
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    // Experience for services
                    if (listing.type == "Service" && listing.experience.isNotEmpty)
                      Text(
                        "Experience: ${listing.experience}",
                        style: TextStyle(
                          fontSize: AppSizing.fontSize(13),
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),

              // Menu
              _buildPopupMenu(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    final imageSize = AppSizing.width(32); // ~120px

    return Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: listing.imagePaths.isEmpty
          ? Icon(
        Icons.image_outlined,
        size: imageSize * 0.8,
        color: Colors.grey.shade400,
      )
          : ClipRRect(
        borderRadius: BorderRadius.circular(AppSizing.radiusMd - 1),
        child: Stack(
          children: [
            Image.file(
              File(listing.imagePaths.first),
              fit: BoxFit.cover,
              width: imageSize,
              height: imageSize,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade100,
                child: Icon(
                  Icons.broken_image_outlined,
                  size: imageSize * 0.8,
                  color: Colors.red.shade300,
                ),
              ),
            ),
            if (listing.imagePaths.length > 1)
              Positioned(
                bottom: AppSizing.xs,
                right: AppSizing.xs,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizing.xs,
                    vertical: AppSizing.xs / 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(AppSizing.radiusXs + 2),
                  ),
                  child: Text(
                    '+${listing.imagePaths.length - 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppSizing.fontSize(10),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUidBadge() {
    return GestureDetector(
      onTap: () => _copyUID(listing.id),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizing.sm,
          vertical: AppSizing.xs / 2,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(AppSizing.radiusXs + 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fingerprint,
              size: AppSizing.fontSize(12),
              color: Colors.grey.shade600,
            ),
            SizedBox(width: AppSizing.xs),
            Text(
              'ID: ${listing.id.substring(0, 8)}...',
              style: TextStyle(
                fontSize: AppSizing.fontSize(10),
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final statusColor = ListingConstants.getStatusColor(listing.status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizing.xs,
        vertical: AppSizing.xs,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizing.sm),
      ),
      child: Text(
        listing.status,
        style: TextStyle(
          fontSize: AppSizing.fontSize(12),
          fontWeight: FontWeight.w200,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: EdgeInsets.all(AppSizing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) => Container(
            width: AppSizing.xs,
            height: AppSizing.xs,
            margin: EdgeInsets.symmetric(vertical: AppSizing.xs / 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              shape: BoxShape.circle,
            ),
          )),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
      ),
      position: PopupMenuPosition.under,
      onSelected: (String value) {
        if (value == "edit") {
          onEdit?.call();
        } else if (value == "delete") {
          onDelete?.call();
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: "edit",
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: AppSizing.fontSize(18)),
              SizedBox(width: AppSizing.md),
              const Text("Edit"),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: "delete",
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: AppSizing.fontSize(18),
                color: Colors.red,
              ),
              SizedBox(width: AppSizing.md),
              const Text("Delete", style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _copyUID(String uid) {
    Clipboard.setData(ClipboardData(text: uid));
  }
}