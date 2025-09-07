import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isOpen = true;
  String timings = '10:00 AM – 9:00 PM';

  String _shopName = 'Tech Haven Electronics';
  String _phoneNumber = '+91 98765 43210';
  String _address = '456 Innovation Drive, Pune';
  String? _coverImageUrl; // null => gradient only

  void _pushFull(Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) {
          final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        },
      ),
    );
  }

  void _editAllInfo() async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController(text: _shopName);
    final phone = TextEditingController(text: _phoneNumber);
    final addr = TextEditingController(text: _address);
    final time = TextEditingController(text: timings);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Shop Info'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'Shop Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter shop name'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    final t = (v ?? '').replaceAll(RegExp(r'\s+'), '');
                    return (t.length < 10) ? 'Enter valid phone' : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addr,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter address' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: time,
                  decoration: const InputDecoration(
                    labelText: 'Shop Timings (e.g., 9:00 AM – 9:00 PM)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter timings' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (ok == true) {
      if (!mounted) return;
      setState(() {
        _shopName = name.text.trim();
        _phoneNumber = phone.text.trim();
        _address = addr.text.trim();
        timings = time.text.trim();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // -------- Banner (gradient first, optional image on top) --------
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: SizedBox(
            height: 180,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // base gradient (always visible)
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7DB2FF), Color(0xFF4A72DA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

                // optional cover image (shows if _coverImageUrl is set)
                if (_coverImageUrl != null && _coverImageUrl!.isNotEmpty)
                  Image.network(
                    _coverImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),

                // scrim for legibility
                Container(color: Colors.black.withOpacity(0.12)),

                // unified button: always shown
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 60,
                  child: Center(
                    child: Material(
                      color: Colors.white.withOpacity(0.92),
                      shape: const StadiumBorder(),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Change Banner tapped')),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.photo_camera_rounded,
                                  size: 18, color: Colors.black87),
                              SizedBox(width: 8),
                              Text(
                                'Add a cover photo',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // -------- Header card --------
        Container(
          transform: Matrix4.translationValues(0, -28, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // DP + button
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const CircleAvatar(
                          radius: 36,
                          backgroundColor: Color(0xFFE9EEF8),
                          child: Icon(
                            Icons.person_rounded,
                            size: 40,
                            color: Colors.black38,
                          ),
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: InkWell(
                            onTap: () => ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text('Change DP tapped'),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: cs.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _shopName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          _IconLine(
                            icon: Icons.phone_rounded,
                            text: _phoneNumber,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Dialer will open later'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 2),
                          _IconLine(
                            icon: Icons.location_on_rounded,
                            text: _address,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Maps will open later'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isOpen ? 'Open' : 'Closed',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isOpen ? Colors.green : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Switch.adaptive(
                              value: isOpen,
                              onChanged: (v) => setState(() => isOpen = v),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 16,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              timings,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _editAllInfo,
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Edit Info'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // -------- KPIs --------
        // -------- KPIs --------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _pushFull(const FollowersPage()),
                    child: AppCard(
                      child: Row(
                        children: [
                          Icon(Icons.group_rounded, color: cs.primary),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '3K',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Followers',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _pushFull(const RatingPage()),
                    child: AppCard(
                      child: Row(
                        children: [
                          Icon(Icons.star_rounded, color: cs.primary),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '4.9',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Rating',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // -------- Feature grid --------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
            children: [
              FeatureBox(
                icon: Icons.photo_library_rounded,
                title: 'Posts',
                onTap: () => _pushFull(const PostsPage()),
              ),
              FeatureBox(
                icon: Icons.inventory_2_rounded,
                title: 'Products',
                onTap: () => _pushFull(const ProductsPage()),
              ),
              FeatureBox(
                icon: Icons.local_offer_rounded,
                title: 'Offers',
                onTap: () => _pushFull(const OffersPage()),
              ),
              FeatureBox(
                icon: Icons.insights_rounded,
                title: 'Insights',
                onTap: () => _pushFull(const InsightsPage()),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

// ----------------- Shared UI -----------------

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFE8EAF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class FeatureBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const FeatureBox({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AppCard(
        radius: 16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, // Vertically centered
          children: [
            Icon(icon, size: 28, color: cs.primary),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  const _IconLine({required this.icon, required this.text, this.onTap});
  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        Icon(icon, size: 16, color: Colors.black45),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
    return onTap == null
        ? row
        : InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: Padding(padding: const EdgeInsets.all(2), child: row),
          );
  }
}

// ----------------- Full Pages (dummy) -----------------

class BaseSlidePage extends StatelessWidget {
  final String title;
  final Widget child;
  const BaseSlidePage({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black87,
      ),
      body: Container(color: const Color(0xFFF6F7FB), child: child),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Create $title tapped'))),
        icon: const Icon(Icons.add_rounded),
        label: Text('New $title'),
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseSlidePage(
      title: 'Posts',
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 9,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemBuilder: (_, i) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFFECEFF5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.image_rounded, color: Colors.black38),
        ),
      ),
    );
  }
}

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseSlidePage(
      title: 'Products',
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => AppCard(
          child: Row(
            children: const [
              _ThumbIcon(),
              SizedBox(width: 12),
              Expanded(child: Text('Sample Product Name')),
              SizedBox(width: 8),
              Text('₹ 249', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseSlidePage(
      title: 'Offers',
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => AppCard(
          radius: 16,
          child: Row(
            children: const [
              Icon(Icons.local_offer_rounded),
              SizedBox(width: 12),
              Expanded(child: Text('Flat 20% off • Aug 1 – Aug 31')),
            ],
          ),
        ),
      ),
    );
  }
}

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseSlidePage(
      title: 'Insights',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          AppCard(
            child: _InsightLine(label: 'Weekly Visitors', value: '120'),
          ),
          SizedBox(height: 10),
          AppCard(
            child: _InsightLine(label: 'Top Product', value: 'Milk (2L)'),
          ),
          SizedBox(height: 10),
          AppCard(
            child: _InsightLine(label: 'Repeat Customers (30d)', value: '36%'),
          ),
        ],
      ),
    );
  }
}

class FollowersPage extends StatelessWidget {
  const FollowersPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseSlidePage(
      title: 'Followers',
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 20,
        itemBuilder: (_, i) => ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text('Follower #${i + 1}'),
          subtitle: const Text('Joined recently'),
        ),
      ),
    );
  }
}

class OrdersTodayPage extends StatelessWidget {
  const OrdersTodayPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseSlidePage(
      title: 'Orders Today',
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 12,
        itemBuilder: (_, i) => AppCard(
          child: ListTile(
            leading: const Icon(Icons.receipt_long_rounded),
            title: Text('Order #${1000 + i}'),
            subtitle: const Text('2 items • COD'),
            trailing: const Text('₹ 499'),
          ),
        ),
      ),
    );
  }
}

class RatingPage extends StatelessWidget {
  const RatingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseSlidePage(
      title: 'Rating',
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => AppCard(
          radius: 16,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              child: const Icon(Icons.star_rounded, color: Colors.orange),
            ),
            title: Text('${5 - i}.0 Stars'),
            subtitle: Text('${10 - i} Reviews'),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        ),
      ),
    );
  }
}

// ----------------- Small helpers -----------------

class _ThumbIcon extends StatelessWidget {
  const _ThumbIcon();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.inventory_2_rounded, color: Colors.black38),
    );
  }
}

class _InsightLine extends StatelessWidget {
  final String label;
  final String value;
  const _InsightLine({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}
