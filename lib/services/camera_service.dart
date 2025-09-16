import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

// Camera related models
enum CameraMode { photo, video }
enum MediaType { image, video }

class MediaFile {
  final String path;
  final MediaType type;
  final DateTime createdAt;
  final int? durationSeconds; // For videos only

  MediaFile({
    required this.path,
    required this.type,
    required this.createdAt,
    this.durationSeconds,
  });

  bool get isVideo => type == MediaType.video;
  bool get isImage => type == MediaType.image;
  File get file => File(path);
  bool get exists => file.existsSync();
}

// Camera Service for handling all camera operations
class CameraService extends ChangeNotifier {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  // Camera controller and state
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isLoading = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  CameraMode _currentMode = CameraMode.photo;
  int _selectedCameraIndex = 0;

  // Constants
  static const int maxVideoSeconds = 30;
  static const double maxVideoSizeMB = 50.0;

  // Getters
  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isRecording => _isRecording;
  bool get isLoading => _isLoading;
  int get recordingSeconds => _recordingSeconds;
  CameraMode get currentMode => _currentMode;
  bool get hasPermissions => _checkPermissionsStatus();
  bool get canSwitchCamera => (_cameras?.length ?? 0) > 1;
  String get recordingTimeText => '${_recordingSeconds}s';

  // Initialize camera
  Future<bool> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check and request permissions
      final hasPermissions = await _requestPermissions();
      if (!hasPermissions) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Initialize camera controller
      await _initializeController();

      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isInitialized = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _initializeController() async {
    if (_cameras == null || _cameras!.isEmpty) return;

    _controller?.dispose();
    _controller = CameraController(
      _cameras![_selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: true,
    );

    await _controller!.initialize();
  }

  Future<bool> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();

    return cameraStatus.isGranted && microphoneStatus.isGranted;
  }

  bool _checkPermissionsStatus() {
    // This would check current permission status
    return true; // Simplified for demo
  }

  // Switch between cameras (front/back)
  Future<void> switchCamera() async {
    if (!canSwitchCamera || _isRecording) return;

    try {
      _isLoading = true;
      notifyListeners();

      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
      await _initializeController();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Switch camera mode
  void switchMode(CameraMode mode) {
    if (_isRecording) return;

    _currentMode = mode;
    notifyListeners();
  }

  // Take photo
  Future<MediaFile?> takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    try {
      final XFile image = await _controller!.takePicture();

      return MediaFile(
        path: image.path,
        type: MediaType.image,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  // Start video recording
  Future<bool> startVideoRecording() async {
    if (_controller == null || !_controller!.value.isInitialized || _isRecording) {
      return false;
    }

    try {
      await _controller!.startVideoRecording();
      _isRecording = true;
      _recordingSeconds = 0;

      _startRecordingTimer();
      notifyListeners();
      return true;
    } catch (e) {
      _isRecording = false;
      notifyListeners();
      return false;
    }
  }

  // Stop video recording
  Future<MediaFile?> stopVideoRecording() async {
    if (_controller == null || !_isRecording) {
      return null;
    }

    try {
      _stopRecordingTimer();
      final XFile video = await _controller!.stopVideoRecording();

      _isRecording = false;
      _recordingSeconds = 0;
      notifyListeners();

      return MediaFile(
        path: video.path,
        type: MediaType.video,
        createdAt: DateTime.now(),
        durationSeconds: _recordingSeconds,
      );
    } catch (e) {
      _isRecording = false;
      _recordingSeconds = 0;
      notifyListeners();
      return null;
    }
  }

  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _recordingSeconds++;
      notifyListeners();

      // Auto-stop at max duration
      if (_recordingSeconds >= maxVideoSeconds) {
        stopVideoRecording();
      }
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  // Validate media file
  Future<bool> validateMediaFile(MediaFile mediaFile) async {
    try {
      if (!mediaFile.exists) return false;

      final file = mediaFile.file;
      final fileSizeBytes = await file.length();
      final fileSizeMB = fileSizeBytes / (1024 * 1024);

      // Check file size
      if (fileSizeMB > maxVideoSizeMB) return false;

      // Check video duration
      if (mediaFile.isVideo && mediaFile.durationSeconds != null) {
        if (mediaFile.durationSeconds! > maxVideoSeconds) return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Clean up resources
  @override
  void dispose() {
    _stopRecordingTimer();
    _controller?.dispose();
    super.dispose();
  }

  // Reset camera state
  void reset() {
    _stopRecordingTimer();
    _isRecording = false;
    _recordingSeconds = 0;
    _currentMode = CameraMode.photo;
    notifyListeners();
  }
}