import 'package:flutter/material.dart';
import 'package:my_business_app/utils/sizing.dart';
import 'package:my_business_app/utils/app_icons.dart';
import 'package:my_business_app/services/story_service.dart';

class StoryCard extends StatelessWidget {
  final Story story;
  final VoidCallback? onTap;
  final VoidCallback? onCreateStory;
  final String userName;
  final bool isCurrentUser;

  const StoryCard({
    Key? key,
    required this.story,
    this.onTap,
    this.onCreateStory,
    this.userName = 'Your Story',
    this.isCurrentUser = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppSpacing.initialize(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[400]!, Colors.purple[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // User avatar with add story option
            GestureDetector(
              onTap: onCreateStory,
              child: Container(
                width: AppSpacing.width(16), // ~60px on 375px width
                height: AppSpacing.width(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        AppIcons.person,
                        color: Colors.grey[600],
                        size: AppSpacing.iconMd,
                      ),
                    ),
                    if (isCurrentUser)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: AppSpacing.width(5.3), // ~20px
                          height: AppSpacing.width(5.3),
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            AppIcons.add,
                            color: Colors.white,
                            size: AppSpacing.width(3.2), // ~12px
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            AppSpacing.horizontalSpaceMd,

            // Story content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with user name and timestamp
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          userName,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: AppSpacing.width(4.3), // ~16px on 375px width
                          ),
                        ),
                      ),
                      if (story.hasMedia)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                          ),
                          child: Icon(
                            story.isVideo ? AppIcons.video : AppIcons.image,
                            color: Colors.white,
                            size: AppSpacing.iconXs,
                          ),
                        ),
                    ],
                  ),

                  AppSpacing.verticalSpaceXs,

                  // Timestamp
                  Text(
                    'Posted ${_getTimeAgo(story.postedAt)}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: AppSpacing.width(3.2), // ~12px on 375px width
                    ),
                  ),

                  // Engagement stats
                  Text(
                    '${story.views} views • ${story.likes} likes',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: AppSpacing.width(3.2), // ~12px on 375px width
                    ),
                  ),

                  AppSpacing.verticalSpaceSm,

                  // Story content
                  Text(
                    story.content,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppSpacing.width(3.7), // ~14px on 375px width
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Action indicator
            if (onTap != null)
              Padding(
                padding: EdgeInsets.only(left: AppSpacing.sm),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: AppSpacing.iconXs,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'now';
  }
}

// Simple story card for lists
class SimpleStoryCard extends StatelessWidget {
  final Story story;
  final VoidCallback? onTap;
  final bool showStats;

  const SimpleStoryCard({
    Key? key,
    required this.story,
    this.onTap,
    this.showStats = true,
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: AppSpacing.width(10.7), // ~40px
                  height: AppSpacing.width(10.7),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.person,
                    color: Colors.grey[600],
                    size: AppSpacing.iconSm,
                  ),
                ),
                AppSpacing.horizontalSpaceSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Story',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppSpacing.width(3.7), // ~14px
                        ),
                      ),
                      Text(
                        _getTimeAgo(story.postedAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: AppSpacing.width(3.2), // ~12px
                        ),
                      ),
                    ],
                  ),
                ),
                if (story.hasMedia)
                  Icon(
                    story.isVideo ? AppIcons.video : AppIcons.image,
                    color: Colors.grey[600],
                    size: AppSpacing.iconSm,
                  ),
              ],
            ),

            AppSpacing.verticalSpaceMd,

            // Content
            Text(
              story.content,
              style: TextStyle(
                fontSize: AppSpacing.width(3.7), // ~14px
                height: 1.4,
                color: Colors.black87,
              ),
            ),

            if (showStats) ...[
              AppSpacing.verticalSpaceMd,

              // Stats row
              Row(
                children: [
                  _buildStatItem(
                    icon: AppIcons.views,
                    value: story.views,
                    label: 'views',
                    color: Colors.blue,
                  ),
                  AppSpacing.horizontalSpaceLg,
                  _buildStatItem(
                    icon: AppIcons.clicks,
                    value: story.clicks,
                    label: 'clicks',
                    color: Colors.green,
                  ),
                  AppSpacing.horizontalSpaceLg,
                  _buildStatItem(
                    icon: AppIcons.likes,
                    value: story.likes,
                    label: 'likes',
                    color: Colors.red,
                  ),
                  if (story.comments.isNotEmpty) ...[
                    AppSpacing.horizontalSpaceLg,
                    _buildStatItem(
                      icon: AppIcons.comments,
                      value: story.comments.length,
                      label: 'comments',
                      color: Colors.orange,
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int value,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: AppSpacing.iconXs,
          color: color,
        ),
        SizedBox(width: AppSpacing.xs),
        Text(
          '$value',
          style: TextStyle(
            fontSize: AppSpacing.width(3.2), // ~12px
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'now';
  }
}

// Story placeholder for empty state
class CreateStoryCard extends StatelessWidget {
  final VoidCallback? onTap;

  const CreateStoryCard({
    Key? key,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppSpacing.initialize(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppSpacing.width(16), // ~60px
              height: AppSpacing.width(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.addStory,
                color: Colors.blue[600],
                size: AppSpacing.iconLg,
              ),
            ),
            AppSpacing.verticalSpaceMd,
            Text(
              'Create Your First Story',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppSpacing.width(4.3), // ~16px
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceXs,
            Text(
              'Share what you\'re working on',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: AppSpacing.width(3.7), // ~14px
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}