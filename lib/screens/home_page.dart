import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';

// Data Models
class Story {
  final String id;
  final String content;
  final DateTime postedAt;
  final int views;
  final int clicks;
  final int likes;
  final List<Comment> comments;
  final DateTime expiresAt;
  final String? imageUrl;
  final String? videoUrl;
  final int? videoDuration;

  Story({
    required this.id,
    required this.content,
    required this.postedAt,
    required this.views,
    required this.clicks,
    required this.likes,
    required this.comments,
    required this.expiresAt,
    this.imageUrl,
    this.videoUrl,
    this.videoDuration,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isVideo => videoUrl != null;
}

class Comment {
  final String id;
  final String userName;
  final String content;
  final DateTime createdAt;
  final String? userAvatar;

  Comment({
    required this.id,
    required this.userName,
    required this.content,
    required this.createdAt,
    this.userAvatar,
  });
}

class OrderedItem {
  final String name;
  final int orders;
  final double rating;
  final int reviews;
  final double price;
  final IconData icon;
  final Color color;

  OrderedItem({
    required this.name,
    required this.orders,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.icon,
    required this.color,
  });
}

// Main HomePage
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Sample data
  Story currentStory = Story(
    id: '1',
    content: 'Just completed a beautiful kitchen cabinet project! Check out my latest work...',
    postedAt: DateTime.now().subtract(Duration(hours: 2)),
    views: 15,
    clicks: 2,
    likes: 10,
    expiresAt: DateTime.now().add(Duration(hours: 22)),
    comments: [
      Comment(
        id: '1',
        userName: 'Priya Sharma',
        content: 'Wow! This looks amazing. Can you do something similar for my kitchen?',
        createdAt: DateTime.now().subtract(Duration(hours: 1, minutes: 30)),
        userAvatar: null,
      ),
      Comment(
        id: '2',
        userName: 'Rohit Kumar',
        content: 'Great work! What\'s the price range for this type of cabinet?',
        createdAt: DateTime.now().subtract(Duration(minutes: 45)),
        userAvatar: null,
      ),
      Comment(
        id: '3',
        userName: 'Anita Singh',
        content: 'Beautiful craftsmanship! How long does it take to complete?',
        createdAt: DateTime.now().subtract(Duration(minutes: 20)),
        userAvatar: null,
      ),
    ],
  );

  List<OrderedItem> mostOrderedItems = [
    OrderedItem(
      name: 'Kitchen Cabinet Making',
      orders: 25,
      rating: 4.8,
      reviews: 120,
      price: 8500,
      icon: Icons.build,
      color: Colors.orange,
    ),
    OrderedItem(
      name: 'Nirma Soap Wholesale',
      orders: 18,
      rating: 4.6,
      reviews: 89,
      price: 1200,
      icon: Icons.soap,
      color: Colors.blue,
    ),
    OrderedItem(
      name: 'Wardrobe Design & Installation',
      orders: 15,
      rating: 4.9,
      reviews: 76,
      price: 12000,
      icon: Icons.add_box,
      color: Colors.purple,
    ),
    OrderedItem(
      name: 'Plumbing Services',
      orders: 12,
      rating: 4.7,
      reviews: 54,
      price: 2500,
      icon: Icons.plumbing,
      color: Colors.cyan,
    ),
    OrderedItem(
      name: 'Electrical Work',
      orders: 10,
      rating: 4.5,
      reviews: 43,
      price: 3200,
      icon: Icons.electrical_services,
      color: Colors.amber,
    ),
  ];

  void _showStoryDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StoryDetailsModal(story: currentStory),
    );
  }

  void _showCreatePostOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => CreatePostModal(
        onStoryCreated: (Story newStory) {
          setState(() {
            currentStory = newStory;
          });
        },
      ),
    );
  }

  void _showMostOrderedList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MostOrderedListPage(items: mostOrderedItems),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                HeaderWidget(),
                SizedBox(height: 20),

                // Story Card
                StoryCard(
                  story: currentStory,
                  onTap: _showStoryDetails,
                  onProfileTap: _showCreatePostOptions,
                ),

                SizedBox(height: 24),

                // Today's Overview
                Text(
                  "Today's Overview",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: 16),

                // Stats Cards
                StatsCardsWidget(),

                SizedBox(height: 24),

                // Most Ordered Section
                MostOrderedHeader(onViewAll: _showMostOrderedList),

                SizedBox(height: 16),

                // Service Items
                MostOrderedPreview(items: mostOrderedItems.take(2).toList()),

                SizedBox(height: 20),

                // Promotional Cards
                PromotionalCardsWidget(),

                SizedBox(height: 80), // Extra space for bottom navigation
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StoryCameraPage extends StatefulWidget {
  final Function(Story) onStoryCreated;

  const StoryCameraPage({super.key, required this.onStoryCreated});

  @override
  State<StoryCameraPage> createState() => _StoryCameraPageState();
}

class _StoryCameraPageState extends State<StoryCameraPage> with TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isRecording = false;
  bool _isRearCamera = true;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  late AnimationController _progressController;
  String? _videoPath;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: Duration(seconds: 30),
      vsync: this,
    );
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Request permissions
    var status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera permission required')),
      );
      Navigator.pop(context);
      return;
    }

    status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Microphone permission required')),
      );
      Navigator.pop(context);
      return;
    }

    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _controller = CameraController(
          cameras![_isRearCamera ? 0 : 1],
          ResolutionPreset.high,
          enableAudio: true,
        );
        await _controller!.initialize();
        setState(() {});
      }
    } catch (e) {
      print('Error initializing camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing camera')),
      );
    }
  }

  Future<void> _switchCamera() async {
    if (cameras == null || cameras!.length < 2) return;

    setState(() {
      _isRearCamera = !_isRearCamera;
    });

    await _controller?.dispose();
    _controller = CameraController(
      cameras![_isRearCamera ? 0 : 1],
      ResolutionPreset.high,
      enableAudio: true,
    );
    await _controller!.initialize();
    setState(() {});
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });

      _progressController.reset();
      _progressController.forward();

      _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _recordingSeconds++;
        });

        // Auto stop at 30 seconds
        if (_recordingSeconds >= 30) {
          _stopRecording();
        }
      });
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_isRecording) return;

    try {
      _recordingTimer?.cancel();
      _progressController.stop();

      XFile videoFile = await _controller!.stopVideoRecording();

      setState(() {
        _isRecording = false;
        _videoPath = videoFile.path;
      });

      // Navigate to preview page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoryPreviewPage(
            videoPath: _videoPath!,
            duration: _recordingSeconds,
            onStoryCreated: widget.onStoryCreated,
          ),
        ),
      );
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      XFile imageFile = await _controller!.takePicture();

      // Navigate to preview page for image
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoryPreviewPage(
            imagePath: imageFile.path,
            duration: 0,
            onStoryCreated: widget.onStoryCreated,
          ),
        ),
      );
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _controller?.dispose();
    _recordingTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),

          // Top Controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ),

                  // Recording Timer
                  if (_isRecording)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            _formatDuration(_recordingSeconds),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Switch Camera
                  GestureDetector(
                    onTap: _switchCamera,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.flip_camera_ios, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Progress Bar (when recording)
          if (_isRecording)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 20,
              right: 20,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _progressController.value,
                    backgroundColor: Colors.white30,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 3,
                  );
                },
              ),
            ),

          // Bottom Controls
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 30,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery Button
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gallery selection coming soon!')),
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(Icons.photo_library, color: Colors.white, size: 24),
                    ),
                  ),

                  // Record/Capture Button
                  GestureDetector(
                    onTap: _isRecording ? _stopRecording : null,
                    onLongPressStart: (_) => _startRecording(),
                    onLongPressEnd: (_) => _stopRecording(),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Center(
                        child: Container(
                          width: _isRecording ? 30 : 60,
                          height: _isRecording ? 30 : 60,
                          decoration: BoxDecoration(
                            color: _isRecording ? Colors.red : Colors.white,
                            shape: _isRecording ? BoxShape.rectangle : BoxShape.circle,
                            borderRadius: _isRecording ? BorderRadius.circular(6) : null,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Photo Button
                  GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Instructions
          if (!_isRecording)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 150,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Hold for video, tap for photo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class StoryPreviewPage extends StatefulWidget {
  final String? videoPath;
  final String? imagePath;
  final int duration;
  final Function(Story) onStoryCreated;

  const StoryPreviewPage({
    super.key,
    this.videoPath,
    this.imagePath,
    required this.duration,
    required this.onStoryCreated,
  });

  @override
  State<StoryPreviewPage> createState() => _StoryPreviewPageState();
}

class _StoryPreviewPageState extends State<StoryPreviewPage> {
  VideoPlayerController? _videoController;
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoPath != null) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.file(File(widget.videoPath!));
    await _videoController!.initialize();
    _videoController!.setLooping(true);
    _videoController!.play();
    setState(() {});
  }

  Future<void> _shareStory() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));

    final newStory = Story(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: _textController.text.trim().isNotEmpty
          ? _textController.text.trim()
          : (widget.videoPath != null ? 'Shared a video story' : 'Shared a photo story'),
      postedAt: DateTime.now(),
      views: 0,
      clicks: 0,
      likes: 0,
      comments: [],
      expiresAt: DateTime.now().add(Duration(hours: 24)),
      videoUrl: widget.videoPath,
      imageUrl: widget.imagePath,
      videoDuration: widget.duration > 0 ? widget.duration : null,
    );

    widget.onStoryCreated(newStory);

    // Navigate back to home
    Navigator.of(context).popUntil((route) => route.isFirst);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Story shared successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Media Preview
          Positioned.fill(
            child: widget.videoPath != null
                ? _videoController != null && _videoController!.value.isInitialized
                ? VideoPlayer(_videoController!)
                : Center(child: CircularProgressIndicator(color: Colors.white))
                : widget.imagePath != null
                ? Image.file(
              File(widget.imagePath!),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
                : Container(),
          ),

          // Top Controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    ),
                  ),
                  if (widget.duration > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '${widget.duration}s',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Text Input
                    TextField(
                      controller: _textController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add a caption...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        filled: true,
                        fillColor: Colors.black26,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),

                    SizedBox(height: 16),

                    // Share Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _shareStory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : Text(
                          'Share to Your Story',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Header Widget
class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Townzy Partners',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Good morning, Raj',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Row(
          children: [
            Stack(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.notifications_outlined, size: 28),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            Stack(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.message_outlined, size: 28),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// Story Card Widget
class StoryCard extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;
  final VoidCallback onProfileTap;

  const StoryCard({
    super.key,
    required this.story,
    required this.onTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[400]!, Colors.purple[400]!],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: onProfileTap,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.grey),
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Story',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Posted ${_getTimeAgo(story.postedAt)}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Views: ${story.views}, Clicks: ${story.clicks}, Likes: ${story.likes}, Comments: ${story.comments.length}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              story.content,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

// Stats Cards Widget
class StatsCardsWidget extends StatelessWidget {
  const StatsCardsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: StatsCard(
              icon: Icons.shopping_bag,
              iconColor: Colors.green,
              title: 'Orders Today',
              value: '12',
              subtitle: '+3 from yesterday',
              subtitleColor: Colors.green,
            )),
            SizedBox(width: 12),
            Expanded(child: StatsCard(
              icon: null,
              iconColor: Colors.blue,
              title: 'Earnings Today',
              value: '₹4,850',
              subtitle: '+₹1,200 from yesterday',
              subtitleColor: Colors.green,
              customIcon: Text('₹', style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold)),
            )),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: StatsCard(
              icon: Icons.help_outline,
              iconColor: Colors.orange,
              title: 'Queries',
              value: '5',
              subtitle: '2 pending response',
              subtitleColor: Colors.orange,
            )),
            SizedBox(width: 12),
            Expanded(child: StatsCard(
              icon: Icons.warning,
              iconColor: Colors.red,
              title: 'Complaints',
              value: '1',
              subtitle: 'Needs attention',
              subtitleColor: Colors.red,
            )),
          ],
        ),
      ],
    );
  }
}

// Individual Stats Card
class StatsCard extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final Color subtitleColor;

  const StatsCard({
    super.key,
    this.icon,
    this.customIcon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              customIcon ?? Icon(icon, color: iconColor, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Most Ordered Header
class MostOrderedHeader extends StatelessWidget {
  final VoidCallback onViewAll;

  const MostOrderedHeader({super.key, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Most Ordered',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: Text(
            'View All',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// Most Ordered Preview
class MostOrderedPreview extends StatelessWidget {
  final List<OrderedItem> items;

  const MostOrderedPreview({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) => OrderedItemCard(item: item)).toList(),
    );
  }
}

// Ordered Item Card
class OrderedItemCard extends StatelessWidget {
  final OrderedItem item;

  const OrderedItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${item.orders} orders this month',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '${item.rating} (${item.reviews} reviews)',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '₹${item.price.toStringAsFixed(0)}',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// Promotional Cards Widget
class PromotionalCardsWidget extends StatelessWidget {
  const PromotionalCardsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Boost Your Listings Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[400]!, Colors.blue[500]!],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Boost Your Listings',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Get 3x more visibility',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.rocket_launch,
                    color: Colors.white,
                    size: 30,
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Promote Now',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Festival Special Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[100]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.card_giftcard, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'Festival Special',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'Diwali is coming! Create special offers to attract more customers.',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'Create Offer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Help Us Improve Section
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amber),
                  SizedBox(width: 8),
                  Text(
                    'Help Us Improve',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Share your feedback and suggestions with our development team.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'Send Feedback',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Story Details Modal
class StoryDetailsModal extends StatelessWidget {
  final Story story;

  const StoryDetailsModal({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Story Insights',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Story Content
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Story Content',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              story.content,
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Posted ${_getTimeAgo(story.postedAt)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // Insights
                      Text(
                        'Insights',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: InsightCard(
                              icon: Icons.visibility,
                              color: Colors.blue,
                              title: 'Views',
                              value: story.views.toString(),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: InsightCard(
                              icon: Icons.touch_app,
                              color: Colors.green,
                              title: 'Clicks',
                              value: story.clicks.toString(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: InsightCard(
                              icon: Icons.favorite,
                              color: Colors.red,
                              title: 'Likes',
                              value: story.likes.toString(),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: InsightCard(
                              icon: Icons.comment,
                              color: Colors.orange,
                              title: 'Comments',
                              value: story.comments.length.toString(),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Comments Section
                      if (story.comments.isNotEmpty) ...[
                        Text(
                          'Comments (${story.comments.length})',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),

                        ...story.comments.map((comment) => CommentCard(comment: comment)),
                      ],

                      // Expiry Notice
                      if (!story.isExpired) ...[
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.schedule, color: Colors.amber[700], size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Story expires in ${_getTimeRemaining(story.expiresAt)}',
                                  style: TextStyle(
                                    color: Colors.amber[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  String _getTimeRemaining(DateTime expiryTime) {
    final now = DateTime.now();
    final difference = expiryTime.difference(now);

    if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'less than a minute';
    }
  }
}

// Insight Card Widget
class InsightCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  const InsightCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// Comment Card Widget
class CommentCard extends StatelessWidget {
  final Comment comment;

  const CommentCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                child: Text(
                  comment.userName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _getTimeAgo(comment.createdAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            comment.content,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}

// Create Post Modal
class CreatePostModal extends StatefulWidget {
  final Function(Story) onStoryCreated;

  const CreatePostModal({super.key, required this.onStoryCreated});

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final TextEditingController _textController = TextEditingController();
  bool _isCreating = false;

  void _openCamera() {
    Navigator.pop(context); // Close modal first
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryCameraPage(
          onStoryCreated: widget.onStoryCreated,
        ),
      ),
    );
  }

  
  void _createStory() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _isCreating = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 1));

    final newStory = Story(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: _textController.text.trim(),
      postedAt: DateTime.now(),
      views: 0,
      clicks: 0,
      likes: 0,
      comments: [],
      expiresAt: DateTime.now().add(Duration(hours: 24)),
    );

    widget.onStoryCreated(newStory);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 20),

          Text(
            'Create New Story',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),

          TextField(
            controller: _textController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share something about your work, services, or achievements...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          SizedBox(height: 16),

          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  // Handle image upload
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Image upload feature coming soon!')),
                  );
                },
                icon: Icon(Icons.photo_library),
                label: Text('Add Photo'),
              ),
              SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  // Handle location
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Location feature coming soon!')),
                  );
                },
                icon: Icon(Icons.location_on),
                label: Text('Location'),
              ),
            ],
          ),
          SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCreating ? null : _createStory,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isCreating
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                'Share Story',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

// Most Ordered List Page
class MostOrderedListPage extends StatelessWidget {
  final List<OrderedItem> items;

  const MostOrderedListPage({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Most Ordered Services',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            margin: EdgeInsets.only(bottom: 16),
            child: OrderedItemCard(item: item),
          );
        },
      ),
    );
  }
}