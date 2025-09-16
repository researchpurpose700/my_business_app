import 'package:flutter/material.dart';
import 'package:my_business_app/utils/sizing.dart';
import 'package:my_business_app/utils/app_icons.dart';
import 'package:my_business_app/utils/validators.dart';
import 'package:my_business_app/utils/error_handling.dart';
import 'package:my_business_app/components/input_field.dart';
import 'package:my_business_app/services/story_service.dart';
import 'package:my_business_app/services/analytics_service.dart';

class StoryDetailsModal extends StatefulWidget {
  final Story story;
  final Function(Story)? onStoryUpdated;

  const StoryDetailsModal({
    Key? key,
    required this.story,
    this.onStoryUpdated,
  }) : super(key: key);

  @override
  State<StoryDetailsModal> createState() => _StoryDetailsModalState();
}

class _StoryDetailsModalState extends State<StoryDetailsModal>
    with SingleTickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final StoryService _storyService = StoryService();
  final AnalyticsService _analyticsService = AnalyticsService();

  late TabController _tabController;
  bool _isLoading = false;
  bool _isAddingComment = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _trackStoryView();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _trackStoryView() {
    _storyService.incrementViews(widget.story.id);
    _analyticsService.trackStoryView(widget.story.id);
  }

  @override
  Widget build(BuildContext context) {
    AppSpacing.initialize(context);

    return Container(
      height: AppSpacing.height(80), // 80% of screen height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Tab bar
          _buildTabBar(),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildCommentsTab(),
                _buildAnalyticsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Story Details',
            style: TextStyle(
              fontSize: AppSpacing.width(5.3), // ~20px
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              AppIcons.close,
              size: AppSpacing.iconMd,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: AppSpacing.width(3.7), // ~14px
        ),
        indicatorColor: Colors.blue,
        tabs: [
          Tab(text: 'Overview'),
          Tab(text: 'Comments (${widget.story.comments.length})'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Story content
          _buildStoryContent(),

          AppSpacing.verticalSpaceLg,

          // Quick stats
          _buildQuickStats(),

          AppSpacing.verticalSpaceLg,

          // Media preview (if available)
          if (widget.story.hasMedia) _buildMediaPreview(),
        ],
      ),
    );
  }

  Widget _buildStoryContent() {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.story,
                color: Colors.blue,
                size: AppSpacing.iconSm,
              ),
              AppSpacing.horizontalSpaceSm,
              Text(
                'Story Content',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSpacing.width(4), // ~15px
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceSm,
          Text(
            widget.story.content,
            style: TextStyle(
              fontSize: AppSpacing.width(4), // ~15px
              height: 1.5,
              color: Colors.black87,
            ),
          ),
          AppSpacing.verticalSpaceSm,
          Text(
            'Posted ${_storyService.getTimeAgo(widget.story.postedAt)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: AppSpacing.width(3.2), // ~12px
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance',
          style: TextStyle(
            fontSize: AppSpacing.width(4.8), // ~18px
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.verticalSpaceMd,
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Views',
                widget.story.views,
                AppIcons.views,
                Colors.blue,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'Clicks',
                widget.story.clicks,
                AppIcons.clicks,
                Colors.green,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'Likes',
                widget.story.likes,
                AppIcons.likes,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, int value, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        if (label.toLowerCase() == 'likes') {
          _handleLike();
        }
      },
      child: Container(
        padding: AppSpacing.paddingMd,
        margin: EdgeInsets.only(right: AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: AppSpacing.iconMd),
            AppSpacing.verticalSpaceXs,
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: AppSpacing.width(5.3), // ~20px
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: AppSpacing.width(3.2), // ~12px
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    return Container(
      width: double.infinity,
      height: AppSpacing.height(25), // 25% of screen height
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.story.isVideo ? AppIcons.video : AppIcons.image,
              size: AppSpacing.iconLg,
              color: Colors.grey[600],
            ),
            AppSpacing.verticalSpaceSm,
            Text(
              widget.story.isVideo ? 'Video Content' : 'Image Content',
              style: TextStyle(
                fontSize: AppSpacing.width(4), // ~15px
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsTab() {
    return Column(
      children: [
        // Comments list
        Expanded(
          child: widget.story.comments.isEmpty
              ? _buildEmptyComments()
              : ListView.builder(
            padding: AppSpacing.paddingMd,
            itemCount: widget.story.comments.length,
            itemBuilder: (context, index) {
              final comment = widget.story.comments[index];
              return _buildCommentItem(comment);
            },
          ),
        ),

        // Add comment section
        _buildAddCommentSection(),
      ],
    );
  }

  Widget _buildEmptyComments() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.commentsOutlined,
            size: AppSpacing.iconLg,
            color: Colors.grey[400],
          ),
          AppSpacing.verticalSpaceMd,
          Text(
            'No comments yet',
            style: TextStyle(
              fontSize: AppSpacing.width(4.3), // ~16px
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          AppSpacing.verticalSpaceXs,
          Text(
            'Be the first to comment on this story',
            style: TextStyle(
              fontSize: AppSpacing.width(3.7), // ~14px
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.verticalMd),
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: AppSpacing.width(4), // ~15px
                backgroundColor: Colors.blue[100],
                child: Text(
                  comment.userName[0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: AppSpacing.width(3.2), // ~12px
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              AppSpacing.horizontalSpaceSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppSpacing.width(3.7), // ~14px
                      ),
                    ),
                    Text(
                      _storyService.getTimeAgo(comment.createdAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: AppSpacing.width(3.2), // ~12px
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceSm,
          Text(
            comment.content,
            style: TextStyle(
              fontSize: AppSpacing.width(3.7), // ~14px
              height: 1.4,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCommentSection() {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CustomInputField(
                controller: _commentController,
                labelText: 'Add a comment...',
                maxLength: 500,
                validator: StoryValidators.validateComment,
              ),
            ),
            AppSpacing.horizontalSpaceSm,
            _isAddingComment
                ? SizedBox(
              width: AppSpacing.iconMd,
              height: AppSpacing.iconMd,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : IconButton(
              onPressed: _addComment,
              icon: Icon(
                AppIcons.add,
                color: Colors.blue,
                size: AppSpacing.iconMd,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Engagement overview
          _buildEngagementOverview(),

          AppSpacing.verticalSpaceLg,

          // Detailed metrics
          _buildDetailedMetrics(),

          AppSpacing.verticalSpaceLg,

          // Performance tips
          _buildPerformanceTips(),
        ],
      ),
    );
  }

  Widget _buildEngagementOverview() {
    final totalEngagement = widget.story.clicks + widget.story.likes + widget.story.comments.length;
    final engagementRate = widget.story.views > 0
        ? (totalEngagement / widget.story.views * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.purple[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Engagement Rate',
            style: TextStyle(
              fontSize: AppSpacing.width(4.8), // ~18px
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          AppSpacing.verticalSpaceSm,
          Text(
            '$engagementRate%',
            style: TextStyle(
              fontSize: AppSpacing.width(8), // ~30px
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          AppSpacing.verticalSpaceXs,
          Text(
            'Total engagements: $totalEngagement',
            style: TextStyle(
              fontSize: AppSpacing.width(3.7), // ~14px
              color: Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Metrics',
          style: TextStyle(
            fontSize: AppSpacing.width(4.8), // ~18px
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.verticalSpaceMd,
        _buildMetricRow('Total Views', widget.story.views, AppIcons.views, Colors.blue),
        _buildMetricRow('Story Clicks', widget.story.clicks, AppIcons.clicks, Colors.green),
        _buildMetricRow('Likes Received', widget.story.likes, AppIcons.likes, Colors.red),
        _buildMetricRow('Comments', widget.story.comments.length, AppIcons.comments, Colors.orange),
      ],
    );
  }

  Widget _buildMetricRow(String label, int value, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.verticalSm),
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: AppSpacing.width(10.7), // ~40px
            height: AppSpacing.width(10.7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: AppSpacing.iconSm),
          ),
          AppSpacing.horizontalSpaceMd,
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppSpacing.width(4), // ~15px
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: AppSpacing.width(4.3), // ~16px
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTips() {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.info,
                color: Colors.green[700],
                size: AppSpacing.iconSm,
              ),
              AppSpacing.horizontalSpaceSm,
              Text(
                'Performance Tips',
                style: TextStyle(
                  fontSize: AppSpacing.width(4.3), // ~16px
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceSm,
          _buildTipItem('Post stories regularly to maintain audience engagement'),
          _buildTipItem('Use high-quality images and videos for better reach'),
          _buildTipItem('Respond to comments to build stronger relationships'),
          _buildTipItem('Share behind-the-scenes content for authenticity'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.verticalXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: AppSpacing.verticalXs),
            width: AppSpacing.width(1.3), // ~5px
            height: AppSpacing.width(1.3),
            decoration: BoxDecoration(
              color: Colors.green[600],
              shape: BoxShape.circle,
            ),
          ),
          AppSpacing.horizontalSpaceSm,
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: AppSpacing.width(3.7), // ~14px
                color: Colors.green[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLike() async {
    try {
      await _storyService.toggleLike(widget.story.id);
      await _analyticsService.trackStoryLike(widget.story.id);

      if (mounted) {
        setState(() {}); // Refresh UI
        widget.onStoryUpdated?.call(_storyService.currentStory ?? widget.story);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
    }
  }

  Future<void> _addComment() async {
    final commentText = _commentController.text.trim();

    // Validate comment
    final validationError = StoryValidators.validateComment(commentText);
    if (validationError != null) {
      ErrorHandler.showErrorSnackBar(context, ValidationException(validationError));
      return;
    }

    setState(() => _isAddingComment = true);

    try {
      final comment = Comment(
        userName: 'You', // In production, get from user service
        content: commentText,
        createdAt: DateTime.now(),
      );

      final success = await _storyService.addComment(widget.story.id, comment);

      if (success) {
        _commentController.clear();
        if (mounted) {
          setState(() {}); // Refresh UI
          widget.onStoryUpdated?.call(_storyService.currentStory ?? widget.story);
          ErrorHandler.showSuccessSnackBar(context, 'Comment added successfully!');
        }
      } else {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(
            context,
            AppException('Failed to add comment. Please try again.'),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingComment = false);
      }
    }
  }
}