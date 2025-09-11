import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:my_business_app/config/save_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isOpen = true;
  String timings = '10:00 AM – 9:00 PM';
  bool _isLoading = true; // Add loading state

  // Remove default values - will be loaded from JSON
  String _fullName = '';
  String _shopName = '';
  String _phoneNumber = '';
  String _address = '';

  // Image handling
  File? _coverImage;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    setState(() => _isLoading = true);

    try {
      final json = await LocalStorage.loadProfile();

      if (json != null && mounted) {
        setState(() {
          // Load username from multiple possible keys
          _fullName = ((json['Username'] ?? json['username'] ?? json['fullName'] ?? json['name'])
                  ?.toString() ?? '')
              .trim();
          if (_fullName.isEmpty) _fullName = 'User Name'; // Correct fallback

          // Load shop name
          _shopName = (json['shopName']?.toString() ?? '').trim();
          if (_shopName.isEmpty) _shopName = 'Your Shop Name'; // Fallback

          // Load phone number
          _phoneNumber = (json['mobile']?.toString() ?? '').trim();
          if (_phoneNumber.isEmpty) _phoneNumber = '+91 00000 00000'; // Fallback

          // Load address
          _address = (json['address']?.toString() ?? '').trim();
          if (_address.isEmpty) _address = 'Add your shop address'; // Fallback

          // Load timings
          final savedTimings = (json['timings']?.toString() ?? '').trim();
          if (savedTimings.isNotEmpty) timings = savedTimings;

          // Load open/closed status
          isOpen = (json['isOpen'] as bool?) ?? true;

          // Load images
          final coverPath = json['coverImage'] as String?;
          final profilePath = json['profileImage'] as String?;

          if (coverPath != null && coverPath.isNotEmpty) {
            final coverFile = File(coverPath);
            if (coverFile.existsSync()) _coverImage = coverFile;
          }

          if (profilePath != null && profilePath.isNotEmpty) {
            final profileFile = File(profilePath);
            if (profileFile.existsSync()) _profileImage = profileFile;
          }
        });
      } else {
        // Set default values if no data found
        setState(() {
          _fullName = 'User Name';
          _shopName = 'Your Shop Name';
          _phoneNumber = '+91 00000 00000';
          _address = 'Add your shop address';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
        // Set fallback values on error
        setState(() {
          _fullName = 'User Name';
          _shopName = 'Your Shop Name';
          _phoneNumber = '+91 00000 00000';
          _address = 'Add your shop address';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _persistToStorage() async {
    try {
      await LocalStorage.upsertProfile({
        'Username': _fullName,
        'shopName': _shopName,
        'address': _address,
        'mobile': _phoneNumber,
        'timings': timings,
        'isOpen': isOpen,
        'coverImage': _coverImage?.path,
        'profileImage': _profileImage?.path,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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

  // Image selection methods
  Future<void> _pickCoverImage() async {
    await _showImageSourceDialog(true);
  }

  Future<void> _pickProfileImage() async {
    await _showImageSourceDialog(false);
  }

  Future<void> _showImageSourceDialog(bool isCoverImage) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _selectImage(ImageSource.camera, isCoverImage);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _selectImage(ImageSource.gallery, isCoverImage);
              },
            ),
            if ((isCoverImage && _coverImage != null) ||
                (!isCoverImage && _profileImage != null))
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove Image'),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() {
                    if (isCoverImage) {
                      _coverImage = null;
                    } else {
                      _profileImage = null;
                    }
                  });
                  await _persistToStorage();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImage(ImageSource source, bool isCoverImage) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: isCoverImage ? 1200 : 800,
        maxHeight: isCoverImage ? 800 : 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Automatically crop the selected image
        final croppedFile = await _cropImage(pickedFile.path, isCoverImage);

        if (croppedFile != null) {
          setState(() {
            if (isCoverImage) {
              _coverImage = File(croppedFile.path);
            } else {
              _profileImage = File(croppedFile.path);
            }
          });
          await _persistToStorage();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  isCoverImage ? 'Cover photo updated!' : 'Profile picture updated!'
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<CroppedFile?> _cropImage(String imagePath, bool isCoverImage) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: isCoverImage ? 'Crop Cover Photo' : 'Crop Profile Picture',
          toolbarColor: Theme.of(context).colorScheme.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: isCoverImage
              ? CropAspectRatioPreset.ratio16x9
              : CropAspectRatioPreset.square,
          lockAspectRatio: !isCoverImage, // Lock square for profile, flexible for cover
          aspectRatioPresets: isCoverImage ? [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio16x9,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio3x2,
          ] : [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.original,
          ],
        ),
        IOSUiSettings(
          title: isCoverImage ? 'Crop Cover Photo' : 'Crop Profile Picture',
          aspectRatioLockEnabled: !isCoverImage,
          resetAspectRatioEnabled: isCoverImage,
          aspectRatioPresets: isCoverImage ? [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio16x9,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio3x2,
          ] : [
            CropAspectRatioPreset.square,
          ],
        ),
      ],
    );
    return croppedFile;
  }

  void _editAllInfo() async {
    final formKey = GlobalKey<FormState>();
    final username = TextEditingController(text: _fullName); // ADDED: Username field
    final name = TextEditingController(text: _shopName);
    final phone = TextEditingController(text: _phoneNumber);
    final addr = TextEditingController(text: _address);
    final time = TextEditingController(text: timings);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile Info'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ADDED: Username field
                TextFormField(
                  controller: username,
                  decoration: const InputDecoration(
                    labelText: 'Your Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter your name'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'Shop Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.store),
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
                    prefixIcon: Icon(Icons.phone),
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
                    prefixIcon: Icon(Icons.location_on),
                    hintText: 'Enter your shop address',
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
                    prefixIcon: Icon(Icons.schedule),
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
        _fullName = username.text.trim(); // ADDED: Save username
        _shopName = name.text.trim();
        _phoneNumber = phone.text.trim();
        _address = addr.text.trim();
        timings = time.text.trim();
      });
      await _persistToStorage();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Show loading indicator if still loading
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

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

                // Cover image (shows if selected)
                if (_coverImage != null)
                  Image.file(
                    _coverImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),

                // scrim for legibility
                Container(color: Colors.black.withOpacity(0.12)),

                // Camera button - always shown
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
                        onTap: _pickCoverImage,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.photo_camera_rounded,
                                  size: 18, color: Colors.black87),
                              const SizedBox(width: 8),
                              Text(
                                _coverImage == null
                                    ? 'Add a cover photo'
                                    : 'Change cover photo',
                                style: const TextStyle(fontWeight: FontWeight.w600),
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
                    // Profile picture + edit button
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: const Color(0xFFE9EEF8),
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? const Icon(
                            Icons.person_rounded,
                            size: 40,
                            color: Colors.black38,
                          )
                              : null,
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: InkWell(
                            onTap: _pickProfileImage,
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
                              child: Icon(
                                _profileImage == null
                                    ? Icons.add_rounded
                                    : Icons.edit_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // UPDATED: Show both username and shop name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Show the shop name as the main title
                          Text(
                            _shopName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          // Show username as subtitle when present
                          if (_fullName.isNotEmpty && _fullName != 'User Name')
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                _fullName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
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
                            text: _address == 'Add your shop address'
                                ? 'Tap to add your address'
                                : _address,
                            onTap: () {
                              if (_address == 'Add your shop address') {
                                // Show edit dialog if address is still the default
                                _editAllInfo();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Maps will open later'),
                                  ),
                                );
                              }
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
                              onChanged: (v) async {
                                setState(() => isOpen = v);
                                await _persistToStorage();
                              },
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _editAllInfo,
                            icon: const Icon(Icons.edit_rounded, size: 14),
                            label: const Text('Edit Info'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 0),
              ],
            ),
          ),
        ),

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
                          const SizedBox(width: 10),
                          const Column(
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
              const SizedBox(width: 12),
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
                          const SizedBox(width: 10),
                          const Column(
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
          mainAxisAlignment: MainAxisAlignment.center,
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
  final bool showCreateButton;
  const BaseSlidePage({super.key, required this.title, required this.child, this.showCreateButton = true});

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
      floatingActionButton: showCreateButton
          ? FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Create $title tapped'))),
        icon: const Icon(Icons.add_rounded),
        label: Text('New $title'),
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
      )
          : null,
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
        itemBuilder: (_, i) => const AppCard(
          child: Row(
            children: [
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
        itemBuilder: (_, i) => const AppCard(
          radius: 16,
          child: Row(
            children: [
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
      showCreateButton: false,
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
      showCreateButton: false,
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

class RatingPage extends StatelessWidget {
  const RatingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseSlidePage(
      title: 'Rating',
      showCreateButton: false,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 20,
        itemBuilder: (_, i) => const AppCard(
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Customer Review'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 8),
                    Text('5.0', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 4),
                Text('Great service and quality products!'),
              ],
            ),
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