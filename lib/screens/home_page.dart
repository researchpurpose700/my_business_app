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
  final String? imagePath;
  final String? videoPath;

  Story({
    required this.id,
    required this.content,
    required this.postedAt,
    required this.views,
    required this.clicks,
    required this.likes,
    required this.comments,
    this.imagePath,
    this.videoPath,
  });

  bool get isVideo => videoPath != null;
}

class Comment {
  final String userName;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.userName,
    required this.content,
    required this.createdAt,
  });
}

class Service {
  final String name;
  final int orders;
  final double rating;
  final double price;
  final IconData icon;
  final Color color;

  Service({
    required this.name,
    required this.orders,
    required this.rating,
    required this.price,
    required this.icon,
    required this.color,
  });
}

// Main Home Page
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Story currentStory = Story(
    id: '1',
    content: 'Just completed a beautiful kitchen cabinet project!',
    postedAt: DateTime.now().subtract(Duration(hours: 2)),
    views: 15,
    clicks: 2,
    likes: 10,
    comments: [
      Comment(
        userName: 'Priya Sharma',
        content: 'Amazing work! Can you do something similar for my kitchen?',
        createdAt: DateTime.now().subtract(Duration(hours: 1)),
      ),
      Comment(
        userName: 'Rohit Kumar',
        content: 'What\'s the price range for this type of cabinet?',
        createdAt: DateTime.now().subtract(Duration(minutes: 45)),
      ),
    ],
  );

  List<Service> services = [
    Service(
      name: 'Kitchen Cabinet Making',
      orders: 25,
      rating: 4.8,
      price: 8500,
      icon: Icons.build,
      color: Colors.orange,
    ),
    Service(
      name: 'Plumbing Services',
      orders: 18,
      rating: 4.6,
      price: 2500,
      icon: Icons.plumbing,
      color: Colors.blue,
    ),
    Service(
      name: 'Electrical Work',
      orders: 12,
      rating: 4.7,
      price: 3200,
      icon: Icons.electrical_services,
      color: Colors.amber,
    ),
  ];

  String getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'now';
  }

  void showStoryDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Story Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close)),
              ],
            ),
            SizedBox(height: 16),
            Text(currentStory.content, style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Views', currentStory.views, Icons.visibility, Colors.blue),
                _buildStatItem('Clicks', currentStory.clicks, Icons.touch_app, Colors.green),
                _buildStatItem('Likes', currentStory.likes, Icons.favorite, Colors.red),
              ],
            ),
            SizedBox(height: 20),
            Text('Comments (${currentStory.comments.length})',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: currentStory.comments.length,
                itemBuilder: (context, index) {
                  final comment = currentStory.comments[index];
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
                        Text(comment.userName, style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(getTimeAgo(comment.createdAt), style: TextStyle(color: Colors.grey, fontSize: 12)),
                        SizedBox(height: 4),
                        Text(comment.content),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 4),
        Text(value.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  void showCreatePost() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Create Story', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _openCamera();
                  },
                  icon: Icon(Icons.camera_alt),
                  label: Text('Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showTextPost();
                  },
                  icon: Icon(Icons.edit),
                  label: Text('Text Post'),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  void _openCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraPage(
          onStoryCreated: (story) {
            setState(() {
              currentStory = story;
            });
          },
        ),
      ),
    );
  }

  void _showTextPost() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Text Story'),
        content: TextField(
          controller: textController,
          maxLines: 3,
          decoration: InputDecoration(hintText: 'What\'s happening?'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                setState(() {
                  currentStory = Story(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    content: textController.text.trim(),
                    postedAt: DateTime.now(),
                    views: 0,
                    clicks: 0,
                    likes: 0,
                    comments: [],
                  );
                });
              }
              Navigator.pop(context);
            },
            child: Text('Post'),
          ),
        ],
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
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Townzy Partners', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('Good morning, Raj', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(onPressed: () {}, icon: Icon(Icons.notifications_outlined)),
                        Stack(
                          children: [
                            IconButton(onPressed: () {}, icon: Icon(Icons.message_outlined)),
                            Positioned(
                              right: 8, top: 8,
                              child: Container(
                                width: 16, height: 16,
                                decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                child: Center(child: Text('3', style: TextStyle(color: Colors.white, fontSize: 10))),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Story Card
                GestureDetector(
                  onTap: showStoryDetails,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.blue[400]!, Colors.purple[400]!]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: showCreatePost,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: Colors.grey),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your Story', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('Posted ${getTimeAgo(currentStory.postedAt)}', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              Text('${currentStory.views} views • ${currentStory.likes} likes', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              SizedBox(height: 8),
                              Text(currentStory.content, style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Today's Overview
                Text("Today's Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),

                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatsCard('Orders Today', '12', '+3 from yesterday', Icons.shopping_bag, Colors.green),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatsCard('Earnings Today', '₹4,850', '+₹1,200 from yesterday', Icons.account_balance_wallet, Colors.blue),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatsCard('Queries', '5', '2 pending', Icons.help_outline, Colors.orange),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatsCard('Complaints', '1', 'Needs attention', Icons.warning, Colors.red),
                    ),
                  ],
                ),

                SizedBox(height: 24),

                // Services Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Most Ordered', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () => _showAllServices(), child: Text('View All')),
                  ],
                ),

                SizedBox(height: 12),

                ...services.take(2).map((service) => Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4)],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          color: service.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(service.icon, color: service.color),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(service.name, style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('${service.orders} orders • ${service.rating}⭐', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      Text('₹${service.price.toInt()}', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )).toList(),

                SizedBox(height: 20),

                // Promotional Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.green[400]!, Colors.blue[500]!]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Boost Your Listings', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Get 3x more visibility', style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue),
                        child: Text('Promote Now'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12))),
            ],
          ),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(subtitle, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  void _showAllServices() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text('All Services')),
          body: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4)],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: service.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(service.icon, color: service.color),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service.name, style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${service.orders} orders this month', style: TextStyle(color: Colors.grey)),
                          Text('${service.rating}⭐ rating', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text('₹${service.price.toInt()}', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Simplified Camera Page
class CameraPage extends StatefulWidget {
  final Function(Story) onStoryCreated;

  CameraPage({required this.onStoryCreated});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  bool isRecording = false;
  int recordingSeconds = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  void initCamera() async {
    final cameraPermission = await Permission.camera.request();
    final micPermission = await Permission.microphone.request();

    if (cameraPermission.isGranted && micPermission.isGranted) {
      cameras = await availableCameras();
      if (cameras!.isNotEmpty) {
        controller = CameraController(cameras![0], ResolutionPreset.high);
        await controller!.initialize();
        setState(() {});
      }
    } else {
      Navigator.pop(context);
    }
  }

  void startRecording() async {
    if (controller != null && !isRecording) {
      await controller!.startVideoRecording();
      setState(() {
        isRecording = true;
        recordingSeconds = 0;
      });

      timer = Timer.periodic(Duration(seconds: 1), (t) {
        setState(() {
          recordingSeconds++;
        });
        if (recordingSeconds >= 30) {
          stopRecording();
        }
      });
    }
  }

  void stopRecording() async {
    if (controller != null && isRecording) {
      timer?.cancel();
      XFile video = await controller!.stopVideoRecording();
      setState(() {
        isRecording = false;
      });

      // Create story
      final story = Story(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Shared a video story',
        postedAt: DateTime.now(),
        views: 0,
        clicks: 0,
        likes: 0,
        comments: [],
        videoPath: video.path,
      );

      widget.onStoryCreated(story);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video story created!')),
      );
    }
  }

  void takePicture() async {
    if (controller != null) {
      XFile image = await controller!.takePicture();

      final story = Story(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Shared a photo story',
        postedAt: DateTime.now(),
        views: 0,
        clicks: 0,
        likes: 0,
        comments: [],
        imagePath: image.path,
      );

      widget.onStoryCreated(story);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo story created!')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(controller!)),

          // Top controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.white),
                ),
                if (isRecording)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(15)),
                    child: Text('${recordingSeconds}s', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery placeholder
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.photo_library, color: Colors.white),
                ),

                // Record button
                GestureDetector(
                  onTap: isRecording ? stopRecording : null,
                  onLongPress: startRecording,
                  onLongPressEnd: (_) => stopRecording(),
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Center(
                      child: Container(
                        width: isRecording ? 30 : 60,
                        height: isRecording ? 30 : 60,
                        decoration: BoxDecoration(
                          color: isRecording ? Colors.red : Colors.white,
                          shape: isRecording ? BoxShape.rectangle : BoxShape.circle,
                          borderRadius: isRecording ? BorderRadius.circular(6) : null,
                        ),
                      ),
                    ),
                  ),
                ),

                // Photo button
                GestureDetector(
                  onTap: takePicture,
                  child: Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Instructions
          if (!isRecording)
            Positioned(
              bottom: 150,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: Text('Hold for video, tap photo button for image',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}