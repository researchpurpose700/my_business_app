import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_business_app/services/profile_service.dart';
import 'package:my_business_app/services/image_service.dart';
import 'package:my_business_app/utils/error_handling.dart';
import 'package:my_business_app/utils/sizing.dart';
import 'package:my_business_app/components/widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService.instance;
  final ImageService _imageService = ImageService.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Removed AppSizing.init(context) from here - this was causing the error
    _loadProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Move AppSizing.init(context) here - this is the fix
    AppSizing.init(context);
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    final result = await _profileService.loadProfile();

    if (mounted) {
      setState(() => _isLoading = false);

      if (!result.isSuccess && result.errorMessage != null) {
        ErrorHandler.showError(context, result.errorMessage!);
      }
    }
  }

  void _navigateToPage(Widget page) {
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

  Future<void> _handleCoverImageTap() async {
    await ImageSourcePicker.show(
      context: context,
      isCoverImage: true,
      currentImage: _profileService.coverImage,
      onSourceSelected: (source) => _selectImage(source, ImageType.cover),
      onRemove: () => _removeImage(ImageType.cover),
    );
  }

  Future<void> _handleProfileImageTap() async {
    await ImageSourcePicker.show(
      context: context,
      isCoverImage: false,
      currentImage: _profileService.profileImage,
      onSourceSelected: (source) => _selectImage(source, ImageType.profile),
      onRemove: () => _removeImage(ImageType.profile),
    );
  }

  Future<void> _selectImage(ImageSource source, ImageType imageType) async {
    final result = await _imageService.pickImage(
      source: source,
      imageType: imageType,
      autoCrop: true,
      context: context,
    );

    if (result.isSuccess && result.imageFile != null) {
      final saveResult = await _profileService.saveProfile(
        coverImage: imageType == ImageType.cover ? result.imageFile : null,
        profileImage: imageType == ImageType.profile ? result.imageFile : null,
      );

      if (mounted) {
        setState(() {});

        if (saveResult.isSuccess) {
          final imageTypeName = imageType == ImageType.cover ? 'Cover photo' : 'Profile picture';
          ErrorHandler.showSuccess(context, '$imageTypeName updated!');
        } else if (saveResult.errorMessage != null) {
          ErrorHandler.showError(context, saveResult.errorMessage!);
        }
      }
    } else if (!result.isCancelled && result.errorMessage != null) {
      if (mounted) {
        ErrorHandler.showError(context, result.errorMessage!);
      }
    }
  }

  Future<void> _removeImage(ImageType imageType) async {
    final confirmed = await ErrorHandler.showConfirmDialog(
      context,
      title: 'Remove Image',
      message: 'Are you sure you want to remove this image?',
      confirmText: 'Remove',
    );

    if (confirmed) {
      final saveResult = await _profileService.saveProfile(
        coverImage: imageType == ImageType.cover ? null : _profileService.coverImage,
        profileImage: imageType == ImageType.profile ? null : _profileService.profileImage,
      );

      if (mounted) {
        setState(() {});

        if (saveResult.isSuccess) {
          ErrorHandler.showSuccess(context, 'Image removed successfully!');
        } else if (saveResult.errorMessage != null) {
          ErrorHandler.showError(context, saveResult.errorMessage!);
        }
      }
    }
  }

  Future<void> _editProfileInfo() async {
    final result = await showDialog<Map<String, String>?>(
      context: context,
      builder: (context) => ProfileEditDialog(
        initialFullName: _profileService.fullName,
        initialShopName: _profileService.shopName,
        initialPhoneNumber: _profileService.phoneNumber,
        initialAddress: _profileService.address,
        initialTimings: _profileService.timings,
      ),
    );

    if (result != null) {
      final saveResult = await _profileService.saveProfile(
        fullName: result['fullName'],
        shopName: result['shopName'],
        phoneNumber: result['phoneNumber'],
        address: result['address'],
        timings: result['timings'],
      );

      if (mounted) {
        setState(() {});

        if (saveResult.isSuccess) {
          ErrorHandler.showSuccess(context, 'Profile updated successfully!');
        } else if (saveResult.errorMessage != null) {
          ErrorHandler.showError(context, saveResult.errorMessage!);
        }
      }
    }
  }

  void _handleAddressTap() {
    if (_profileService.address == ProfileService.defaultAddress) {
      _editProfileInfo();
    } else {
      ErrorHandler.showInfo(context, 'Maps will open later');
    }
  }

  void _handlePhoneTap() {
    ErrorHandler.showInfo(context, 'Dialer will open later');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LoadingOverlay(
      isLoading: _isLoading,
      loadingText: 'Loading profile...',
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Cover image section
          CoverImageSection(
            coverImage: _profileService.coverImage,
            onTap: _handleCoverImageTap,
          ),

          // Profile header card
          Container(
            transform: Matrix4.translationValues(0, -AppSizing.height(3.1), 0), // ~-28px
            padding: EdgeInsets.symmetric(horizontal: AppSizing.horizontalPadding),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile image section
                      ProfileImageSection(
                        profileImage: _profileService.profileImage,
                        onTap: _handleProfileImageTap,
                      ),
                      SizedBox(width: AppSizing.md),

                      // Profile info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Shop name as main title
                            Text(
                              _profileService.shopName,
                              style: TextStyle(
                                fontSize: AppSizing.fontSize(18),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            // Username as subtitle if different from default
                            if (_profileService.fullName.isNotEmpty &&
                                _profileService.fullName != ProfileService.defaultFullName)
                              Padding(
                                padding: EdgeInsets.only(top: AppSizing.xs / 2), // ~2px
                                child: Text(
                                  _profileService.fullName,
                                  style: TextStyle(
                                    fontSize: AppSizing.fontSize(14),
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            SizedBox(height: AppSizing.xs),
                            InfoRow(
                              icon: Icons.phone_rounded,
                              text: _profileService.phoneNumber,
                              onTap: _handlePhoneTap,
                            ),
                            SizedBox(height: AppSizing.xs / 2), // ~2px
                            InfoRow(
                              icon: Icons.location_on_rounded,
                              text: _profileService.address == ProfileService.defaultAddress
                                  ? 'Tap to add your address'
                                  : _profileService.address,
                              onTap: _handleAddressTap,
                            ),
                          ],
                        ),
                      ),

                      // Status and controls
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StatusToggle(
                            isOpen: _profileService.isOpen,
                            onChanged: (value) async {
                              _profileService.updateOpenStatus(value);
                              setState(() {});
                            },
                          ),
                          SizedBox(height: AppSizing.xs),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: AppSizing.smallIconSize,
                                color: Colors.black54,
                              ),
                              SizedBox(width: AppSizing.xs + 2), // ~6px
                              Text(
                                _profileService.timings,
                                style: TextStyle(
                                  fontSize: AppSizing.fontSize(12),
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSizing.xs),
                          TextButton.icon(
                            onPressed: _editProfileInfo,
                            icon: Icon(Icons.edit_rounded, size: AppSizing.fontSize(14)),
                            label: Text(
                              'Edit Info',
                              style: TextStyle(fontSize: AppSizing.fontSize(12)),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // KPI Cards
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizing.horizontalPadding),
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                      onTap: () => _navigateToPage(const FollowersPage()),
                      child: AppCard(
                        child: Row(
                          children: [
                            Icon(Icons.group_rounded, color: colorScheme.primary),
                            SizedBox(width: AppSizing.sm + 2), // ~10px
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '3K',
                                  style: TextStyle(
                                    fontSize: AppSizing.fontSize(16),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Followers',
                                  style: TextStyle(
                                    fontSize: AppSizing.fontSize(12),
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
                SizedBox(width: AppSizing.md),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                      onTap: () => _navigateToPage(const RatingPage()),
                      child: AppCard(
                        child: Row(
                          children: [
                            Icon(Icons.star_rounded, color: colorScheme.primary),
                            SizedBox(width: AppSizing.sm + 2), // ~10px
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '4.9',
                                  style: TextStyle(
                                    fontSize: AppSizing.fontSize(16),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Rating',
                                  style: TextStyle(
                                    fontSize: AppSizing.fontSize(12),
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

          SizedBox(height: AppSizing.md),

          // Feature grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizing.horizontalPadding),
            child: GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: AppSizing.gridColumns,
                mainAxisSpacing: AppSizing.md,
                crossAxisSpacing: AppSizing.md,
                childAspectRatio: 1.35,
              ),
              children: [
                FeatureBox(
                  icon: Icons.photo_library_rounded,
                  title: 'Posts',
                  onTap: () => _navigateToPage(const PostsPage()),
                ),
                FeatureBox(
                  icon: Icons.inventory_2_rounded,
                  title: 'Products',
                  onTap: () => _navigateToPage(const ProductsPage()),
                ),
                FeatureBox(
                  icon: Icons.local_offer_rounded,
                  title: 'Offers',
                  onTap: () => _navigateToPage(const OffersPage()),
                ),
                FeatureBox(
                  icon: Icons.insights_rounded,
                  title: 'Insights',
                  onTap: () => _navigateToPage(const InsightsPage()),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSizing.xl),
        ],
      ),
    );
  }
}

// Placeholder pages (keep existing implementations)
class BaseSlidePage extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showCreateButton;

  const BaseSlidePage({
    super.key,
    required this.title,
    required this.child,
    this.showCreateButton = true
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black87,
      ),
      body: Container(color: const Color(0xFFF6F7FB), child: child),
      floatingActionButton: showCreateButton
          ? FloatingActionButton.extended(
        onPressed: () => ErrorHandler.showInfo(context, 'Create $title tapped'),
        icon: const Icon(Icons.add_rounded),
        label: Text('New $title'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      )
          : null,
    );
  }
}

// Keep existing page implementations with minor updates for responsive design
class PostsPage extends StatelessWidget {
  const PostsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseSlidePage(
      title: 'Posts',
      child: GridView.builder(
        padding: EdgeInsets.all(AppSizing.horizontalPadding),
        itemCount: 9,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: AppSizing.xs + 2,
          crossAxisSpacing: AppSizing.xs + 2,
        ),
        itemBuilder: (_, i) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFFECEFF5),
            borderRadius: BorderRadius.circular(AppSizing.sm + 2),
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
        padding: EdgeInsets.all(AppSizing.horizontalPadding),
        itemCount: 8,
        separatorBuilder: (_, __) => SizedBox(height: AppSizing.sm),
        itemBuilder: (_, i) => AppCard(
          child: Row(
            children: [
              Container(
                width: AppSizing.width(14.4),
                height: AppSizing.width(14.4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECEFF5),
                  borderRadius: BorderRadius.circular(AppSizing.sm + 2),
                ),
                child: const Icon(Icons.inventory_2_rounded, color: Colors.black38),
              ),
              SizedBox(width: AppSizing.md),
              const Expanded(child: Text('Sample Product Name')),
              SizedBox(width: AppSizing.sm),
              Text('₹ 249', style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: AppSizing.fontSize(14),
              )),
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
        padding: EdgeInsets.all(AppSizing.horizontalPadding),
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(height: AppSizing.sm + 2),
        itemBuilder: (_, i) => AppCard(
          radius: AppSizing.radiusLg,
          child: Row(
            children: [
              const Icon(Icons.local_offer_rounded),
              SizedBox(width: AppSizing.md),
              const Expanded(child: Text('Flat 20% off • Aug 1 – Aug 31')),
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
      showCreateButton: false,
      child: ListView(
        padding: EdgeInsets.all(AppSizing.horizontalPadding),
        children: [
          AppCard(child: _InsightLine(label: 'Weekly Visitors', value: '120')),
          SizedBox(height: AppSizing.sm + 2),
          AppCard(child: _InsightLine(label: 'Top Product', value: 'Milk (2L)')),
          SizedBox(height: AppSizing.sm + 2),
          AppCard(child: _InsightLine(label: 'Repeat Customers (30d)', value: '36%')),
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
      showCreateButton: false,
      child: ListView.builder(
        padding: EdgeInsets.all(AppSizing.horizontalPadding),
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

class RatingPage extends StatelessWidget {
  const RatingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseSlidePage(
      title: 'Rating',
      showCreateButton: false,
      child: ListView.builder(
        padding: EdgeInsets.all(AppSizing.horizontalPadding),
        itemCount: 20,
        itemBuilder: (_, i) => AppCard(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('Customer Review'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ...List.generate(5, (_) => Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: AppSizing.smallIconSize
                    )),
                    SizedBox(width: AppSizing.sm),
                    Text('5.0', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizing.fontSize(12),
                    )),
                  ],
                ),
                SizedBox(height: AppSizing.xs),
                Text('Great service and quality products!',
                    style: TextStyle(fontSize: AppSizing.fontSize(12))),
              ],
            ),
          ),
        ),
      ),
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
        Text(label, style: TextStyle(
          color: Colors.black54,
          fontSize: AppSizing.fontSize(14),
        )),
        const Spacer(),
        Text(value, style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: AppSizing.fontSize(14),
        )),
      ],
    );
  }
}