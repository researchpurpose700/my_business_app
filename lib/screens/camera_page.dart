import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../screens/home_page.dart'; // imports Story model from the page you added

class CameraPage extends StatefulWidget {
  final Function(Story) onStoryCreated;
  const CameraPage({super.key, required this.onStoryCreated});

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

  Future<void> initCamera() async {
    final cameraPermission = await Permission.camera.request();
    final micPermission = await Permission.microphone.request();

    if (cameraPermission.isGranted && micPermission.isGranted) {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        controller = CameraController(cameras![0], ResolutionPreset.high);
        await controller!.initialize();
        if (mounted) setState(() {});
      }
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  void startRecording() async {
    if (controller != null && !isRecording) {
      await controller!.startVideoRecording();
      setState(() {
        isRecording = true;
        recordingSeconds = 0;
      });
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() => recordingSeconds++);
        if (recordingSeconds >= 30) stopRecording();
      });
    }
  }

  void stopRecording() async {
    if (controller != null && isRecording) {
      timer?.cancel();
      XFile video = await controller!.stopVideoRecording();
      setState(() => isRecording = false);

      final story = Story(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Shared a video story',
        postedAt: DateTime.now(),
        views: 0,
        clicks: 0,
        likes: 0,
        shares: 0,
        comments: <Comment>[],
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        imageUrl: null,
        imagePath: null,
        videoPath: video.path,
      );

      widget.onStoryCreated(story);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video story created!')));
      }
    }
  }

  void takePicture() async {
    if (controller != null && controller!.value.isInitialized) {
      XFile img = await controller!.takePicture();
      final story = Story(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Shared a photo story',
        postedAt: DateTime.now(),
        views: 0,
        clicks: 0,
        likes: 0,
        shares: 0,
        comments: <Comment>[],
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        imagePath: img.path,
      );
      widget.onStoryCreated(story);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo story created!')));
      }
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(controller!)),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
              if (isRecording)
                Container(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(15)), child: Text('${recordingSeconds}s', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ]),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              GestureDetector(onTap: takePicture, child: Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.camera_alt, color: Colors.white))),
              GestureDetector(onLongPress: startRecording, onLongPressEnd: (_) => stopRecording(), child: Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)), child: Center(child: Container(width: isRecording ? 30 : 60, height: isRecording ? 30 : 60, decoration: BoxDecoration(color: isRecording ? Colors.red : Colors.white, shape: isRecording ? BoxShape.rectangle : BoxShape.circle, borderRadius: isRecording ? BorderRadius.circular(6) : null))))),
            ]),
          ),
        ],
      ),
    );
  }
}

