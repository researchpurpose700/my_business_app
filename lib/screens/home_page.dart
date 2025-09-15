import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_business_app/core/theme/app_theme.dart';
import 'package:my_business_app/core/theme/dim.dart';
import 'package:my_business_app/core/theme/icons.dart';
import 'package:my_business_app/core/components/components.dart';
import 'package:my_business_app/utils/accessibility.dart';

/// Merged models used by the page.
class Story {
  final String id;
  final String content;
  final DateTime postedAt;
  final int views;
  final int clicks;
  final int likes;
  final int shares;
  final List<Comment> comments;
  final DateTime? expiresAt;
  final String? imageUrl;
  final String? imagePath;
  final String? videoPath;

  Story({
    required this.id,
    required this.content,
    required this.postedAt,
    required this.views,
    required this.clicks,
    required this.likes,
    this.shares = 0,
    required this.comments,
    this.expiresAt,
    this.imageUrl,
    this.imagePath,
    this.videoPath,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

class Comment {
  final String id;
  final String userName;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userName,
    required this.content,
    required this.createdAt,
  });
}

class ViewerInteraction {
  final String userId;
  final String name;
  final String? avatarUrl;
  final DateTime viewedAt;
  final DateTime? likedAt;
  final DateTime? clickedAt;
  final DateTime? sharedAt;
  final Comment? comment;

  ViewerInteraction({
    required this.userId,
    required this.name,
    required this.viewedAt,
    this.avatarUrl,
    this.likedAt,
    this.clickedAt,
    this.sharedAt,
    this.comment,
  });
}

/// HomePage: Updated with component library integration.
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late Story currentStory;

  final List<Map<String, dynamic>> sampleMostOrdered = [
    {'name': 'Kitchen Cabinet Making', 'orders': 25, 'price': 8500, 'icon': Icons.build_circle_outlined, 'color': Colors.deepOrange},
    {'name': 'Nirma Soap Wholesale', 'orders': 18, 'price': 1200, 'icon': Icons.shopping_bag_outlined, 'color': Colors.blue},
    {'name': 'Electrician Services', 'orders': 12, 'price': 700, 'icon': Icons.electrical_services_outlined, 'color': Colors.teal}
  ];

  @override
  void initState() {
    super.initState();
    currentStory = Story(
      id: '1',
      content: 'Just completed a beautiful kitchen cabinet project! Check out my latest work...',
      postedAt: DateTime.now().subtract(const Duration(hours: 2)),
      views: 15,
      clicks: 2,
      likes: 10,
      shares: 3,
      comments: [
        Comment(id: 'c1', userName: 'Priya Sharma', content: 'Wow! This looks amazing.', createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30))),
        Comment(id: 'c2', userName: 'Rohit Kumar', content: 'Great work! What\'s the price range?', createdAt: DateTime.now().subtract(const Duration(minutes: 45))),
      ],
      expiresAt: DateTime.now().add(const Duration(hours: 22)),
      imageUrl: 'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg',
    );
  }

  Future<void> _openCamera() async {
    try {
      await Navigator.of(context).pushNamed('/camera');
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera route not registered.')));
    }
  }

  void _openStoryInsights() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => StoryInsightsPage(story: currentStory)));
  }

  void _openCreateModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Dim.radiusL))),
      builder: (context) => CreatePostModal(
        onStoryCreated: (Story s) => setState(() => currentStory = s),
        onRequestCamera: _openCamera,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(Dim.xs).copyWith(left: Dim.gutterS, right: Dim.gutterS),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              HeaderSection(onCreatePressed: _openCreateModal),
              SizedBox(height: Dim.xs),
              StoryCard(story: currentStory, onTap: _openStoryInsights, onProfileTap: _openCreateModal),
              SizedBox(height: Dim.l),
              Text("Today's Overview", style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: Dim.s),
              const StatsCardsWidget(),
              SizedBox(height: Dim.l),
              Text('Most Ordered', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: Dim.s),
              ...sampleMostOrdered.map((m) => OrderedItemPreview(
                name: m['name'] as String,
                ordersText: '${m['orders']} orders this month',
                priceText: '₹${m['price']}',
                icon: m['icon'] as IconData,
                color: m['color'] as Color,
              )),
              SizedBox(height: Dim.m),
              const PromotionalCardsWidget(),
              SizedBox(height: Dim.xl),
            ]),
          ),
        ),
      ),
    );
  }
}

/* ---------------- Header ---------------- */
class HeaderSection extends StatelessWidget {
  final VoidCallback onCreatePressed;
  const HeaderSection({super.key, required this.onCreatePressed});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AccessibleWidget(
      semanticLabel: 'Header section',
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Townzy Partners', style: textTheme.titleLarge),
          SizedBox(height: Dim.xs),
          Text('Good morning, Raj', style: textTheme.bodyMedium),
        ]),
        Row(children: [
          AppIconButton(icon: Icons.search, variant: AppIconButtonVariant.outlined, tooltip: 'Search', onPressed: () {}),
          SizedBox(width: Dim.s),
          AppIconButton(icon: Icons.notifications_outlined, variant: AppIconButtonVariant.outlined, tooltip: 'Notifications', onPressed: () {}),
          SizedBox(width: Dim.s),
          AppIconButton(icon: Icons.add_box_outlined, variant: AppIconButtonVariant.filled, tooltip: 'Create', onPressed: onCreatePressed),
          SizedBox(width: Dim.s),
        ]),
      ]),
    );
  }
}

/* ---------------- Story Card ---------------- */
class StoryCard extends StatefulWidget {
  final Story story;
  final VoidCallback onTap;
  final VoidCallback onProfileTap;
  final VoidCallback? onShareTap;

  const StoryCard({super.key, required this.story, required this.onTap, required this.onProfileTap, this.onShareTap});

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> with SingleTickerProviderStateMixin {
  late final AnimationController _avatarController;
  late final Animation<double> _avatarScale;

  @override
  void initState() {
    super.initState();
    _avatarController = AnimationController(vsync: this, duration: const Duration(milliseconds: 120), lowerBound: 0.92, upperBound: 1.0, value: 1.0);
    _avatarScale = CurvedAnimation(parent: _avatarController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  void _avatarDown(TapDownDetails _) => _avatarController.animateTo(0.92, duration: const Duration(milliseconds: 80));
  void _avatarUp(TapUpDetails _) {
    _avatarController.animateTo(1.0, duration: const Duration(milliseconds: 120));
    widget.onProfileTap();
  }

  String _timeAgo(DateTime t) {
    final Duration d = DateTime.now().difference(t);
    if (d.inDays > 0) return '${d.inDays}d ago';
    if (d.inHours > 0) return '${d.inHours}h ago';
    if (d.inMinutes > 0) return '${d.inMinutes}m ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.story;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget imageWidget() {
      if (s.imagePath != null && s.imagePath!.isNotEmpty) {
        return ClipRRect(borderRadius: BorderRadius.circular(Dim.radiusS), child: Image.file(File(s.imagePath!), height: 120, width: double.infinity, fit: BoxFit.cover));
      }
      if (s.imageUrl != null && s.imageUrl!.isNotEmpty) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(Dim.radiusS),
          child: Image.network(s.imageUrl!, height: 200, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (c, e, st) => Container(height: 200, color: Colors.grey.shade200, alignment: Alignment.center,
                  child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade400, size: 48))),
        );
      }
      return const SizedBox.shrink();
    }

    return AppCard(
      variant: AppCardVariant.elevated,
      onTap: widget.onTap,
      semanticLabel: 'Story: ${s.content}. ${s.likes} likes, ${s.comments.length} comments.',
      child: Row(children: [
        Container(
          width: 10,
          height: 100,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.7)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(Dim.radiusS), bottomLeft: Radius.circular(Dim.radiusS))
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(Dim.s),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                GestureDetector(
                  onTapDown: _avatarDown,
                  onTapUp: _avatarUp,
                  onTapCancel: () => _avatarController.animateTo(1.0, duration: const Duration(milliseconds: 80)),
                  behavior: HitTestBehavior.translucent,
                  child: ScaleTransition(
                    scale: _avatarScale,
                    child: Stack(clipBehavior: Clip.none, children: [
                      CircleAvatar(radius: 35, backgroundColor: colorScheme.primary.withOpacity(0.2), child: Icon(Icons.person_rounded, color: colorScheme.primary, size: 32)),
                      Positioned(
                        right: -8,
                        bottom: -8,
                        child: AppIconButton(icon: Icons.add_rounded, variant: AppIconButtonVariant.filled, size: AppIconButtonSize.small, onPressed: widget.onProfileTap),
                      ),
                    ]),
                  ),
                ),
                SizedBox(width: Dim.s),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Your Story', style: textTheme.titleSmall),
                    SizedBox(height: Dim.xs),
                    Text('Posted ${_timeAgo(s.postedAt)}', style: textTheme.bodySmall),
                  ]),
                ),
              ]),
              if (s.imageUrl != null || s.imagePath != null) ...[
                SizedBox(height: Dim.s),
                imageWidget(),
              ],
              SizedBox(height: Dim.s),
              Text(s.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: textTheme.bodyMedium),
              SizedBox(height: Dim.s),
              Wrap(spacing: Dim.s, runSpacing: Dim.s, children: <Widget>[
                _ActionPill(icon: Icons.favorite_border, label: '${s.likes}', semanticLabel: '${s.likes} likes', onTap: widget.onTap),
                _ActionPill(icon: Icons.chat_bubble_outline, label: '${s.comments.length}', semanticLabel: '${s.comments.length} comments', onTap: widget.onTap),
                _ActionPill(icon: Icons.visibility_outlined, label: '${s.views}', semanticLabel: '${s.views} views'),
                _ActionPill(icon: Icons.touch_app_outlined, label: '${s.clicks}', semanticLabel: '${s.clicks} clicks'),
                _ActionPill(icon: Icons.share_outlined, label: '${s.shares}', semanticLabel: '${s.shares} shares', onTap: widget.onShareTap),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String semanticLabel;

  const _ActionPill({required this.icon, required this.label, this.onTap, required this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AccessibleWidget(
      semanticLabel: semanticLabel,
      onTap: onTap,
      child: Material(
        color: colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(Dim.radiusL),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Dim.radiusL),
          child: Container(
            constraints: BoxConstraints(minHeight: Dim.buttonHeightSmall),
            padding: EdgeInsets.symmetric(horizontal: Dim.m, vertical: Dim.s),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: AppIcons.sizeS, color: colorScheme.onSurface.withOpacity(0.7)),
              SizedBox(width: Dim.s),
              Text(label, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.8))),
            ]),
          ),
        ),
      ),
    );
  }
}

/* ---------------- Story Insights Page ---------------- */
enum InsightsFilter { allViews, likes, comments, clicks, shares }

class StoryInsightsPage extends StatefulWidget {
  final Story story;
  const StoryInsightsPage({super.key, required this.story});
  @override
  State<StoryInsightsPage> createState() => _StoryInsightsPageState();
}

class _StoryInsightsPageState extends State<StoryInsightsPage> {
  late final List<ViewerInteraction> _allInteractions;
  InsightsFilter _filter = InsightsFilter.allViews;

  @override
  void initState() {
    super.initState();
    _allInteractions = _buildSampleInteractions(widget.story);
  }

  static List<ViewerInteraction> _buildSampleInteractions(Story s) {
    final now = DateTime.now();
    return <ViewerInteraction>[
      ViewerInteraction(userId: 'u1', name: 'Priya Sharma', viewedAt: now.subtract(const Duration(hours: 2, minutes: 10)),
          likedAt: now.subtract(const Duration(hours: 1, minutes: 45)),
          comment: Comment(id: 'c1', userName: 'Priya Sharma', content: 'Wow! This looks amazing.', createdAt: now.subtract(const Duration(hours: 1, minutes: 30))),
          clickedAt: now.subtract(const Duration(hours: 1, minutes: 40)), sharedAt: now.subtract(const Duration(hours: 1, minutes: 20))),
      ViewerInteraction(userId: 'u2', name: 'Rohit Kumar', viewedAt: now.subtract(const Duration(hours: 1, minutes: 10)),
          comment: Comment(id: 'c2', userName: 'Rohit Kumar', content: 'Great work! What\'s the price range?', createdAt: now.subtract(const Duration(minutes: 45)))),
      ViewerInteraction(userId: 'u3', name: 'Ankit Verma', viewedAt: now.subtract(const Duration(hours: 5)),
          likedAt: now.subtract(const Duration(hours: 4, minutes: 50)), clickedAt: now.subtract(const Duration(hours: 4, minutes: 30))),
      ViewerInteraction(userId: 'u4', name: 'Sneha Patel', viewedAt: now.subtract(const Duration(minutes: 20)),
          sharedAt: now.subtract(const Duration(minutes: 10))),
    ];
  }

  List<ViewerInteraction> get _filtered {
    switch (_filter) {
      case InsightsFilter.likes: return _allInteractions.where((v) => v.likedAt != null).toList();
      case InsightsFilter.comments: return _allInteractions.where((v) => v.comment != null).toList();
      case InsightsFilter.clicks: return _allInteractions.where((v) => v.clickedAt != null).toList();
      case InsightsFilter.shares: return _allInteractions.where((v) => v.sharedAt != null).toList();
      case InsightsFilter.allViews: return _allInteractions;
    }
  }

  void _setFilter(InsightsFilter f) => setState(() => _filter = f);

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inDays > 0) return '${d.inDays}d ago';
    if (d.inHours > 0) return '${d.inHours}h ago';
    if (d.inMinutes > 0) return '${d.inMinutes}m ago';
    return 'now';
  }

  String _getFirstName(String fullName) => fullName.split(' ').isNotEmpty ? fullName.split(' ').first : '';

  List<ViewerInteraction> get _topEngagers {
    final engagers = _allInteractions.where((v) => v.likedAt != null || v.comment != null).toList();
    engagers.sort((a, b) {
      final at = a.likedAt ?? a.comment?.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bt = b.likedAt ?? b.comment?.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bt.compareTo(at);
    });
    return engagers.take(10).toList();
  }

  void _openUserDetails(ViewerInteraction v) {
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(_getFirstName(v.name), style: Theme.of(context).textTheme.titleSmall),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Viewed: ${_timeAgo(v.viewedAt)}', style: Theme.of(context).textTheme.bodyMedium),
          if (v.likedAt != null) Text('Liked: ${_timeAgo(v.likedAt!)}', style: Theme.of(context).textTheme.bodyMedium),
          if (v.clickedAt != null) Text('Clicked: ${_timeAgo(v.clickedAt!)}', style: Theme.of(context).textTheme.bodyMedium),
          if (v.sharedAt != null) Text('Shared: ${_timeAgo(v.sharedAt!)}', style: Theme.of(context).textTheme.bodyMedium),
          if (v.comment != null) ...[
            SizedBox(height: Dim.s),
            Text('Comment:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(v.comment!.content, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ]),
        actions: [AppButton(text: 'Close', variant: AppButtonVariant.text, onPressed: () => Navigator.pop(context))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.story;
    final counts = [_allInteractions.length, _allInteractions.where((v) => v.likedAt != null).length,
      _allInteractions.where((v) => v.comment != null).length, _allInteractions.where((v) => v.clickedAt != null).length,
      _allInteractions.where((v) => v.sharedAt != null).length];
    final filterLabels = ['All Views (${counts[0]})', 'Likes (${counts[1]})', 'Comments (${counts[2]})', 'Clicks (${counts[3]})', 'Shares (${counts[4]})'];
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(title: const Text('Story Insights')),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.all(Dim.m).copyWith(left: Dim.gutterM, right: Dim.gutterM),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Story Content', style: textTheme.titleSmall),
              SizedBox(height: Dim.s),
              Text(s.content, style: textTheme.bodyMedium),
              if (s.imageUrl != null) ...[
                SizedBox(height: Dim.s),
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dim.radiusS),
                  child: Image.network(s.imageUrl!, height: 100, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (c, e, st) => Container(height: 100, color: Colors.grey.shade200, alignment: Alignment.center,
                          child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade400, size: 36))),
                ),
              ],
              SizedBox(height: Dim.m),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: List.generate(5, (i) => Padding(
                  padding: EdgeInsets.only(right: i < 4 ? Dim.s : 0),
                  child: ChoiceChip(
                    label: Text(filterLabels[i]),
                    selected: _filter.index == i,
                    onSelected: (_) => _setFilter(InsightsFilter.values[i]),
                  ),
                ))),
              ),
            ]),
          ),
          const Divider(height: 1),
          Padding(padding: EdgeInsets.fromLTRB(Dim.gutterM, Dim.m, Dim.gutterM, Dim.s), child: Text('Regular Customers', style: textTheme.titleSmall)),
          if (_topEngagers.isNotEmpty)
            SizedBox(
              height: 80,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: Dim.gutterM),
                scrollDirection: Axis.horizontal,
                itemBuilder: (c, i) {
                  final v = _topEngagers[i];
                  final firstName = _getFirstName(v.name);
                  return Column(children: [
                    InkWell(
                        onTap: () => _openUserDetails(v),
                        borderRadius: BorderRadius.circular(28),
                        child: CircleAvatar(radius: 28, backgroundColor: colorScheme.secondary.withOpacity(0.1),
                            child: Text(firstName.substring(0, 1), style: textTheme.titleSmall?.copyWith(color: colorScheme.secondary)))
                    ),
                    SizedBox(height: Dim.xs),
                    SizedBox(width: 64, child: Text(firstName, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: textTheme.bodySmall)),
                  ]);
                },
                separatorBuilder: (_, __) => SizedBox(width: Dim.m),
                itemCount: _topEngagers.length,
              ),
            )
          else
            Padding(padding: EdgeInsets.symmetric(horizontal: Dim.gutterM, vertical: Dim.s),
                child: Text('No top engagers yet.', style: textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic))),
          SizedBox(height: Dim.s),
          const Divider(height: 1),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.sentiment_dissatisfied_outlined, size: 64, color: Colors.grey.shade300),
                SizedBox(height: Dim.m),
                Text('No interactions found for this filter.', style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
              ]),
            )
                : ListView.separated(
              padding: EdgeInsets.all(Dim.m).copyWith(left: Dim.gutterM, right: Dim.gutterM),
              itemBuilder: (c, index) {
                final v = _filtered[index];
                final firstName = _getFirstName(v.name);
                return AppCard(
                  variant: AppCardVariant.outlined,
                  onTap: () => _openUserDetails(v),
                  child: AppListTileAvatar(
                    avatar: CircleAvatar(backgroundColor: colorScheme.primary.withOpacity(0.1),
                        child: Text(firstName.substring(0, 1), style: textTheme.titleSmall?.copyWith(color: colorScheme.primary))),
                    title: Text(firstName, style: textTheme.titleSmall),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Viewed ${_timeAgo(v.viewedAt)}', style: textTheme.bodySmall),
                      if (v.comment != null)
                        Padding(padding: EdgeInsets.only(top: Dim.xs),
                            child: Text('"${v.comment!.content}"', maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic))),
                    ]),
                    trailing: Wrap(spacing: Dim.s, children: <Widget>[
                      if (v.likedAt != null) Icon(Icons.favorite, color: Colors.red.shade400, size: AppIcons.sizeS),
                      if (v.comment != null) Icon(Icons.comment, color: Colors.orange.shade400, size: AppIcons.sizeS),
                      if (v.clickedAt != null) Icon(Icons.touch_app, color: Colors.green.shade400, size: AppIcons.sizeS),
                      if (v.sharedAt != null) Icon(Icons.share, color: Colors.blueGrey.shade400, size: AppIcons.sizeS),
                    ]),
                    onTap: () => _openUserDetails(v),
                  ),
                );
              },
              separatorBuilder: (_, __) => SizedBox(height: Dim.s),
              itemCount: _filtered.length,
            ),
          ),
        ]),
      ),
    );
  }
}

/* ---------------- Stats & Small Widgets ---------------- */
class StatsCardsWidget extends StatelessWidget {
  const StatsCardsWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: <Widget>[
        Expanded(child: SimpleStatCard(icon: Icons.shopping_bag_outlined, title: 'Orders Today', value: '12', subtitle: '+3 from yesterday', color: Colors.green)),
        SizedBox(width: Dim.s),
        Expanded(child: SimpleStatCard(icon: Icons.currency_rupee, title: 'Earnings Today', value: '₹4850', subtitle: '+₹1200 from yesterday', color: Colors.blue)),
      ]),
      SizedBox(height: Dim.s),
      Row(children: <Widget>[
        Expanded(child: SimpleStatCard(icon: Icons.help_outline, title: 'Queries', value: '5', subtitle: '2 pending', color: Colors.orange)),
        SizedBox(width: Dim.s),
        Expanded(child: SimpleStatCard(icon: Icons.warning_amber_outlined, title: 'Complaints', value: '1', subtitle: 'Needs attention', color: Colors.red)),
      ]),
    ]);
  }
}

class SimpleStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const SimpleStatCard({super.key, required this.icon, required this.title, required this.value, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      variant: AppCardVariant.filled,
      semanticLabel: '$title: $value. $subtitle',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              padding: EdgeInsets.all(Dim.s),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(Dim.radiusS)),
              child: Icon(icon, color: color, size: AppIcons.sizeM)
          ),
          SizedBox(width: Dim.s),
          Expanded(child: Text(title, style: textTheme.bodySmall?.copyWith(color: Colors.black54))),
        ]),
        SizedBox(height: Dim.s),
        Text(value, style: textTheme.titleMedium),
        SizedBox(height: Dim.xs),
        Text(subtitle, style: textTheme.bodySmall?.copyWith(color: color)),
      ]),
    );
  }
}

class OrderedItemPreview extends StatelessWidget {
  final String name;
  final String ordersText;
  final String priceText;
  final IconData icon;
  final Color color;

  const OrderedItemPreview({super.key, required this.name, required this.ordersText, required this.priceText, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: EdgeInsets.only(bottom: Dim.s),
      child: AppListTileIcon(
        icon: icon,
        iconColor: color,
        title: Text(name, style: textTheme.titleSmall),
        subtitle: Text(ordersText, style: textTheme.bodySmall?.copyWith(color: Colors.black54)),
        trailing: Text(priceText, style: textTheme.titleSmall?.copyWith(color: Colors.green)),
        onTap: () {},
      ),
    );
  }
}

class PromotionalCardsWidget extends StatelessWidget {
  const PromotionalCardsWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.elevated,
      semanticLabel: 'Promotional offer: Boost your listings',
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.teal.shade400, Colors.blue.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(Dim.radiusM),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Boost Your Listings', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white)),
            SizedBox(height: Dim.xs),
            Text('Get 3x more visibility', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70))
          ])),
          AppIconButton(
            icon: Icons.rocket_launch_outlined,
            variant: AppIconButtonVariant.standard,
            onPressed: () {},
            tooltip: 'Learn more',
          ),
        ]),
      ),
    );
  }
}

/* ---------------- Create Post Modal ---------------- */
class CreatePostModal extends StatefulWidget {
  final Function(Story) onStoryCreated;
  final VoidCallback onRequestCamera;

  const CreatePostModal({super.key, required this.onStoryCreated, required this.onRequestCamera});

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final TextEditingController _ctrl = TextEditingController();
  bool _loading = false;

  void _create() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final s = Story(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: _ctrl.text.trim(),
      postedAt: DateTime.now(),
      views: 0,
      clicks: 0,
      likes: 0,
      shares: 0,
      comments: <Comment>[],
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );
    widget.onStoryCreated(s);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Theme(
      data: AppTheme.lightTheme,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.all(Dim.l).copyWith(left: Dim.gutterM, right: Dim.gutterM),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(Dim.radiusL))
          ),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 60, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.5)))),
            SizedBox(height: Dim.m),
            Text('Create New Story', style: textTheme.titleMedium),
            SizedBox(height: Dim.m),
            AppTextField(
              controller: _ctrl,
              maxLines: 4,
              hint: 'Share something...',
              label: 'Story Content',
              variant: AppTextFieldVariant.outlined,
            ),
            SizedBox(height: Dim.m),
            Row(children: [
              Expanded(
                child: AppButton(
                  text: 'Camera',
                  variant: AppButtonVariant.secondary,
                  leadingIcon: Icons.camera_alt,
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onRequestCamera();
                  },
                ),
              ),
              SizedBox(width: Dim.s),
              Expanded(
                child: AppButton(
                  text: 'Share Story',
                  variant: AppButtonVariant.primary,
                  onPressed: _loading ? null : _create,
                  isLoading: _loading,
                ),
              ),
            ]),
            SizedBox(height: Dim.s),
          ]),
        ),
      ),
    );
  }
}