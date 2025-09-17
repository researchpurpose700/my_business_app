import 'dart:async';
import 'package:flutter/material.dart';

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
  bool get hasMedia => imagePath != null || videoPath != null;

  Story copyWith({
    String? id,
    String? content,
    DateTime? postedAt,
    int? views,
    int? clicks,
    int? likes,
    List<Comment>? comments,
    String? imagePath,
    String? videoPath,
  }) {
    return Story(
      id: id ?? this.id,
      content: content ?? this.content,
      postedAt: postedAt ?? this.postedAt,
      views: views ?? this.views,
      clicks: clicks ?? this.clicks,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      imagePath: imagePath ?? this.imagePath,
      videoPath: videoPath ?? this.videoPath,
    );
  }
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

// Global Story Service (Singleton)
class StoryService extends ChangeNotifier {
  static final StoryService _instance = StoryService._internal();
  factory StoryService() => _instance;
  StoryService._internal() {
    _initializeDummyData();
  }

  Story? _currentStory;
  final List<Story> _allStories = [];
  bool _isLoading = false;

  // Getters
  Story? get currentStory => _currentStory;
  List<Story> get allStories => List.unmodifiable(_allStories);
  bool get isLoading => _isLoading;
  bool get hasStory => _currentStory != null;

  void _initializeDummyData() {
    _currentStory = Story(
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
    _allStories.add(_currentStory!);
  }

  // Create new story
  Future<bool> createStory({
    required String content,
    String? imagePath,
    String? videoPath,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call delay
      await Future.delayed(Duration(milliseconds: 500));

      final story = Story(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content.trim(),
        postedAt: DateTime.now(),
        views: 0,
        clicks: 0,
        likes: 0,
        comments: [],
        imagePath: imagePath,
        videoPath: videoPath,
      );

      _currentStory = story;
      _allStories.insert(0, story);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update story engagement
  Future<void> incrementViews(String storyId) async {
    final story = _findStoryById(storyId);
    if (story != null) {
      final updatedStory = story.copyWith(views: story.views + 1);
      _updateStoryInList(updatedStory);
      if (_currentStory?.id == storyId) {
        _currentStory = updatedStory;
      }
      notifyListeners();

      // TODO: Send to API
    }
  }

  Future<void> incrementClicks(String storyId) async {
    final story = _findStoryById(storyId);
    if (story != null) {
      final updatedStory = story.copyWith(clicks: story.clicks + 1);
      _updateStoryInList(updatedStory);
      if (_currentStory?.id == storyId) {
        _currentStory = updatedStory;
      }
      notifyListeners();

      // TODO: Send to API
    }
  }

  Future<void> toggleLike(String storyId) async {
    final story = _findStoryById(storyId);
    if (story != null) {
      // Simple like toggle - in production, track user's like status
      final updatedStory = story.copyWith(likes: story.likes + 1);
      _updateStoryInList(updatedStory);
      if (_currentStory?.id == storyId) {
        _currentStory = updatedStory;
      }
      notifyListeners();

      // TODO: Send to API
    }
  }

  // Add comment to story
  Future<bool> addComment(String storyId, Comment comment) async {
    try {
      final story = _findStoryById(storyId);
      if (story != null) {
        final updatedComments = [...story.comments, comment];
        final updatedStory = story.copyWith(comments: updatedComments);
        _updateStoryInList(updatedStory);
        if (_currentStory?.id == storyId) {
          _currentStory = updatedStory;
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Helper methods
  Story? _findStoryById(String id) {
    try {
      return _allStories.firstWhere((story) => story.id == id);
    } catch (e) {
      return null;
    }
  }

  void _updateStoryInList(Story updatedStory) {
    final index = _allStories.indexWhere((story) => story.id == updatedStory.id);
    if (index != -1) {
      _allStories[index] = updatedStory;
    }
  }

  // Utility method for time formatting
  String getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'now';
  }
}