import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_business_app/core/theme/dim.dart';
 // adjust path if your package structure differs

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
  final String? imageUrl; // remote
  final String? imagePath; // local file
  final String? videoPath; // local file

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

/// HomePage: drop-in replacement.
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late Story currentStory;

  final List<Map<String, dynamic>> sampleMostOrdered = [
    {
      'name': 'Kitchen Cabinet Making',
      'orders': 25,
      'price': 8500,
      'icon': Icons.build_circle_outlined,
      'color': Colors.deepOrange
    },
    {
      'name': 'Nirma Soap Wholesale',
      'orders': 18,
      'price': 1200,
      'icon': Icons.shopping_bag_outlined,
      'color': Colors.blue
    },
    {
      'name': 'Electrician Services',
      'orders': 12,
      'price': 700,
      'icon': Icons.electrical_services_outlined,
      'color': Colors.teal
    }
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => CreatePostModal(
        onStoryCreated: (Story s) => setState(() => currentStory = s),
        onRequestCamera: _openCamera,
      ),
    );
  }

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inDays > 0) return '${d.inDays}d ago';
    if (d.inHours > 0) return '${d.inHours}h ago';
    if (d.inMinutes > 0) return '${d.inMinutes}m ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    // theme + typography identical to your DartPad snippet
    final Color primaryColor = Colors.deepPurple;
    final colorScheme = ColorScheme.fromSeed(seedColor: primaryColor, primary: primaryColor, onPrimary: Colors.white);
    final appTextTheme = GoogleFonts.montserratTextTheme(ThemeData.light().textTheme).copyWith(
      titleLarge: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black87),
      titleMedium: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
      titleSmall: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
    );

    final theme = Theme.of(context).copyWith(
      colorScheme: colorScheme,
      textTheme: appTextTheme,
      useMaterial3: true,
    );

    return Theme(
      data: theme,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding:  EdgeInsets.all(16).copyWith(left: Dim.gutter, right: Dim.gutter),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              HeaderSection(onCreatePressed: _openCreateModal),
               SizedBox(height: Dim.m),
              StoryCard(story: currentStory, onTap: _openStoryInsights, onProfileTap: _openCreateModal),
               SizedBox(height: Dim.l),
              Text("Today's Overview", style: theme.textTheme.titleMedium),
               SizedBox(height: Dim.s),
              const StatsCardsWidget(),
               SizedBox(height: Dim.l),
              Text('Most Ordered', style: theme.textTheme.titleMedium),
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
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Townzy Partners', style: textTheme.titleLarge),
         SizedBox(height: Dim.xs),
        Text('Good morning, Raj', style: textTheme.bodyMedium),
      ]),
      Row(children: [
        _HeaderActionButton(tooltip: 'Search', onPressed: () {}, icon: Icons.search),
         SizedBox(width: Dim.s),
        _HeaderActionButton(tooltip: 'Notifications', onPressed: () {}, icon: Icons.notifications_outlined),
         SizedBox(width: Dim.s),
        _HeaderActionButton(tooltip: 'Create', onPressed: onCreatePressed, icon: Icons.add_box_outlined),
      ]),
    ]);
  }
}

class _HeaderActionButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;
  const _HeaderActionButton({required this.tooltip, required this.onPressed, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 1,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(tooltip: tooltip, onPressed: onPressed, icon: Icon(icon, color: Theme.of(context).colorScheme.onSurface)),
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
        return ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(s.imagePath!), height: 120, width: double.infinity, fit: BoxFit.cover));
      }
      if (s.imageUrl != null && s.imageUrl!.isNotEmpty) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(s.imageUrl!, height: 120, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, st) => Container(height: 120, color: Colors.grey.shade200, alignment: Alignment.center, child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade400, size: 48))),
        );
      }
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: s.isExpired ? Colors.grey.shade100 : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 6))],
        ),
        child: Row(children: [
          Container(
            width: 8,
            height: 140,
            decoration: BoxDecoration(gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.7)], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16))),
          ),
          Expanded(
            child: Padding(
              padding:  EdgeInsets.all(16).copyWith(left: Dim.cardPadding, right: Dim.cardPadding),
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
                        CircleAvatar(radius: 28, backgroundColor: colorScheme.primary.withOpacity(0.2), child: Icon(Icons.person_rounded, color: colorScheme.primary, size: 32)),
                        Positioned(
                          right: -8,
                          bottom: -8,
                          child: Material(
                            color: colorScheme.primary,
                            shape: const CircleBorder(),
                            elevation: 4,
                            child: InkWell(onTap: widget.onProfileTap, customBorder: const CircleBorder(), child: const SizedBox(width: 36, height: 36, child: Icon(Icons.add_rounded, size: 20, color: Colors.white)))),
                        ),
                      ]),
                    ),
                  ),
                   SizedBox(width: Dim.m),
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
                  _ActionPill(icon: Icons.favorite_border, label: '${s.likes}', semanticLabel: 'Likes', onTap: widget.onTap),
                  _ActionPill(icon: Icons.chat_bubble_outline, label: '${s.comments.length}', semanticLabel: 'Comments', onTap: widget.onTap),
                  _ActionPill(icon: Icons.visibility_outlined, label: '${s.views}', semanticLabel: 'Views'),
                  _ActionPill(icon: Icons.touch_app_outlined, label: '${s.clicks}', semanticLabel: 'Clicks'),
                  _ActionPill(icon: Icons.share_outlined, label: '${s.shares}', semanticLabel: 'Shares', onTap: widget.onShareTap),
                ]),
              ]),
            ),
          ),
        ]),
      ),
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
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: Material(
        color: colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 18, color: colorScheme.onSurface.withOpacity(0.7)),
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
      ViewerInteraction(userId: 'u1', name: 'Priya Sharma', viewedAt: now.subtract(const Duration(hours: 2, minutes: 10)), likedAt: now.subtract(const Duration(hours: 1, minutes: 45)), comment: Comment(id: 'c1', userName: 'Priya Sharma', content: 'Wow! This looks amazing.', createdAt: now.subtract(const Duration(hours: 1, minutes: 30))), clickedAt: now.subtract(const Duration(hours: 1, minutes: 40)), sharedAt: now.subtract(const Duration(hours: 1, minutes: 20))),
      ViewerInteraction(userId: 'u2', name: 'Rohit Kumar', viewedAt: now.subtract(const Duration(hours: 1, minutes: 10)), likedAt: null, comment: Comment(id: 'c2', userName: 'Rohit Kumar', content: 'Great work! What\'s the price range?', createdAt: now.subtract(const Duration(minutes: 45))), clickedAt: null, sharedAt: null),
      ViewerInteraction(userId: 'u3', name: 'Ankit Verma', viewedAt: now.subtract(const Duration(hours: 5)), likedAt: now.subtract(const Duration(hours: 4, minutes: 50)), comment: null, clickedAt: now.subtract(const Duration(hours: 4, minutes: 30)), sharedAt: null),
      ViewerInteraction(userId: 'u4', name: 'Sneha Patel', viewedAt: now.subtract(const Duration(minutes: 20)), likedAt: null, comment: null, clickedAt: null, sharedAt: now.subtract(const Duration(minutes: 10))),
    ];
  }

  List<ViewerInteraction> get _filtered {
    switch (_filter) {
      case InsightsFilter.likes:
        return _allInteractions.where((v) => v.likedAt != null).toList();
      case InsightsFilter.comments:
        return _allInteractions.where((v) => v.comment != null).toList();
      case InsightsFilter.clicks:
        return _allInteractions.where((v) => v.clickedAt != null).toList();
      case InsightsFilter.shares:
        return _allInteractions.where((v) => v.sharedAt != null).toList();
      case InsightsFilter.allViews:
        return _allInteractions;
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

  String _getFirstName(String fullName) {
    final parts = fullName.split(' ');
    return parts.isNotEmpty ? parts.first : '';
  }

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
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.story;
    final allViewsCount = _allInteractions.length;
    final likesCount = _allInteractions.where((v) => v.likedAt != null).length;
    final commentsCount = _allInteractions.where((v) => v.comment != null).length;
    final clicksCount = _allInteractions.where((v) => v.clickedAt != null).length;
    final sharesCount = _allInteractions.where((v) => v.sharedAt != null).length;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Story Insights')),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding:  EdgeInsets.all(16).copyWith(left: Dim.gutter, right: Dim.gutter),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Story Content', style: textTheme.titleSmall),
             SizedBox(height: Dim.s),
            Text(s.content, style: textTheme.bodyMedium),
            if (s.imageUrl != null) ...[
               SizedBox(height: Dim.s),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(s.imageUrl!, height: 100, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, st) => Container(height: 100, color: Colors.grey.shade200, alignment: Alignment.center, child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade400, size: 36))),
              ),
            ],
             SizedBox(height: Dim.m),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: <Widget>[
                ChoiceChip(label: Text('All Views ($allViewsCount)'), selected: _filter == InsightsFilter.allViews, onSelected: (_) => _setFilter(InsightsFilter.allViews), selectedColor: colorScheme.primary.withOpacity(0.1), labelStyle: _filter == InsightsFilter.allViews ? textTheme.labelMedium?.copyWith(color: colorScheme.primary) : textTheme.labelMedium, side: BorderSide(color: _filter == InsightsFilter.allViews ? colorScheme.primary : Colors.grey.shade300, width: 1)),
                 SizedBox(width: Dim.s),
                ChoiceChip(label: Text('Likes ($likesCount)'), selected: _filter == InsightsFilter.likes, onSelected: (_) => _setFilter(InsightsFilter.likes), selectedColor: colorScheme.primary.withOpacity(0.1), labelStyle: _filter == InsightsFilter.likes ? textTheme.labelMedium?.copyWith(color: colorScheme.primary) : textTheme.labelMedium, side: BorderSide(color: _filter == InsightsFilter.likes ? colorScheme.primary : Colors.grey.shade300, width: 1)),
                 SizedBox(width: Dim.s),
                ChoiceChip(label: Text('Comments ($commentsCount)'), selected: _filter == InsightsFilter.comments, onSelected: (_) => _setFilter(InsightsFilter.comments), selectedColor: colorScheme.primary.withOpacity(0.1), labelStyle: _filter == InsightsFilter.comments ? textTheme.labelMedium?.copyWith(color: colorScheme.primary) : textTheme.labelMedium, side: BorderSide(color: _filter == InsightsFilter.comments ? colorScheme.primary : Colors.grey.shade300, width: 1)),
                 SizedBox(width: Dim.s),
                ChoiceChip(label: Text('Clicks ($clicksCount)'), selected: _filter == InsightsFilter.clicks, onSelected: (_) => _setFilter(InsightsFilter.clicks), selectedColor: colorScheme.primary.withOpacity(0.1), labelStyle: _filter == InsightsFilter.clicks ? textTheme.labelMedium?.copyWith(color: colorScheme.primary) : textTheme.labelMedium, side: BorderSide(color: _filter == InsightsFilter.clicks ? colorScheme.primary : Colors.grey.shade300, width: 1)),
                 SizedBox(width: Dim.s),
                ChoiceChip(label: Text('Shares ($sharesCount)'), selected: _filter == InsightsFilter.shares, onSelected: (_) => _setFilter(InsightsFilter.shares), selectedColor: colorScheme.primary.withOpacity(0.1), labelStyle: _filter == InsightsFilter.shares ? textTheme.labelMedium?.copyWith(color: colorScheme.primary) : textTheme.labelMedium, side: BorderSide(color: _filter == InsightsFilter.shares ? colorScheme.primary : Colors.grey.shade300, width: 1)),
              ]),
            ),
          ]),
        ),
        const Divider(height: 1),
        Padding(padding:  EdgeInsets.fromLTRB(16, Dim.m, 16, Dim.s), child: Text('Regular Customers', style: textTheme.titleSmall)),
        if (_topEngagers.isNotEmpty)
          SizedBox(
            height: 80,
            child: ListView.separated(
              padding:  EdgeInsets.symmetric(horizontal: Dim.gutter),
              scrollDirection: Axis.horizontal,
              itemBuilder: (c, i) {
                final v = _topEngagers[i];
                final firstName = _getFirstName(v.name);
                return Column(children: [
                  InkWell(onTap: () => _openUserDetails(v), borderRadius: BorderRadius.circular(28), child: CircleAvatar(radius: 28, backgroundColor: colorScheme.secondary.withOpacity(0.1), child: Text(firstName.substring(0, 1), style: textTheme.titleSmall?.copyWith(color: colorScheme.secondary)))),
                   SizedBox(height: Dim.xs),
                  SizedBox(width: 64, child: Text(firstName, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: textTheme.bodySmall)),
                ]);
              },
              separatorBuilder: (_, __) =>  SizedBox(width: Dim.m),
              itemCount: _topEngagers.length,
            ),
          )
        else
          Padding(padding:  EdgeInsets.symmetric(horizontal: Dim.gutter, vertical: Dim.s), child: Text('No top engagers yet.', style: textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic))),
         SizedBox(height: Dim.s),
        const Divider(height: 1),
        Expanded(
          child: _filtered.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.sentiment_dissatisfied_outlined, size: 64, color: Colors.grey.shade300),
                     SizedBox(height: Dim.m),
                    Text('No interactions found for this filter.', style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
                     SizedBox(height: Dim.xs),
                    Text('Try a different filter or check back later.', style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade500)),
                  ]),
                )
              : ListView.separated(
                  padding:  EdgeInsets.all(16).copyWith(left: Dim.gutter, right: Dim.gutter),
                  itemBuilder: (c, index) {
                    final v = _filtered[index];
                    final firstName = _getFirstName(v.name);
                    return Card(
                      elevation: 1,
                      margin: EdgeInsets.zero,
                      child: InkWell(
                        onTap: () => _openUserDetails(v),
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding:  EdgeInsets.symmetric(vertical: Dim.s),
                          child: ListTile(
                            leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1), child: Text(firstName.substring(0, 1), style: textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary))),
                            title: Text(firstName, style: textTheme.titleSmall),
                            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Viewed ${_timeAgo(v.viewedAt)}', style: textTheme.bodySmall),
                              if (v.comment != null) Padding(padding:  EdgeInsets.only(top: Dim.s), child: Text('\"${v.comment!.content}\"', maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic))),
                            ]),
                            trailing: Wrap(spacing: Dim.s, children: <Widget>[
                              if (v.likedAt != null) Icon(Icons.favorite, color: Colors.red.shade400, size: 18),
                              if (v.comment != null) Icon(Icons.comment, color: Colors.orange.shade400, size: 18),
                              if (v.clickedAt != null) Icon(Icons.touch_app, color: Colors.green.shade400, size: 18),
                              if (v.sharedAt != null) Icon(Icons.share, color: Colors.blueGrey.shade400, size: 18),
                            ]),
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) =>  SizedBox(height: Dim.s),
                  itemCount: _filtered.length,
                ),
        ),
      ]),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding:  EdgeInsets.all(Dim.cardPadding),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 10),
          Text(title, style: textTheme.bodySmall?.copyWith(color: Colors.black54)),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin:  EdgeInsets.only(bottom: Dim.m),
      padding:  EdgeInsets.all(Dim.cardPadding),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))]),
      child: Row(children: [
        Container(width: 56, height: 56, decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 28)),
         SizedBox(width: Dim.m),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: textTheme.titleSmall),  SizedBox(height: Dim.xs), Text(ordersText, style: textTheme.bodySmall?.copyWith(color: Colors.black54))])),
        Text(priceText, style: textTheme.titleSmall?.copyWith(color: Colors.green)),
      ]),
    );
  }
}

class PromotionalCardsWidget extends StatelessWidget {
  const PromotionalCardsWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  EdgeInsets.only(top: Dim.s),
      padding: const EdgeInsets.all(18), // kept 18 for gradient card density, change to Dim.m if preferred
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.teal.shade400, Colors.blue.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 8))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Boost Your Listings', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white)),  SizedBox(height: Dim.xs), Text('Get 3x more visibility', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70))])),
        IconButton(onPressed: () {}, icon: const Icon(Icons.rocket_launch_outlined, color: Colors.white, size: 30)),
      ]),
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
      imageUrl: null,
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
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding:  EdgeInsets.all(20).copyWith(left: Dim.gutter, right: Dim.gutter),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 60, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.5)))),
           SizedBox(height: Dim.m),
          Text('Create New Story', style: textTheme.titleMedium),
           SizedBox(height: Dim.m),
          TextField(controller: _ctrl, maxLines: 4, decoration: const InputDecoration(hintText: 'Share something...')),
           SizedBox(height: Dim.m),
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onRequestCamera();
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
              ),
            ),
             SizedBox(width: Dim.s),
            Expanded(
              child: ElevatedButton(
                onPressed: _loading ? null : _create,
                child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Share Story'),
              ),
            ),
          ]),
           SizedBox(height: Dim.s),
        ]),
      ),
    );
  }
}
