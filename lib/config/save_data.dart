import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalStorage {
  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/business_registration.json');
  }

  /// Save JSON (Profile or Business Registration)
  static Future<void> saveProfile(Map<String, dynamic> data) async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(data));
  }

  /// Merge incoming data with existing JSON and save
  static Future<void> upsertProfile(Map<String, dynamic> data) async {
    final file = await _getFile();
    Map<String, dynamic> merged = {};
    if (await file.exists()) {
      try {
        final raw = await file.readAsString();
        final jsonMap = jsonDecode(raw);
        if (jsonMap is Map<String, dynamic>) {
          merged = Map<String, dynamic>.from(jsonMap);
        }
      } catch (_) {
        // If file is corrupted, start fresh
      }
    }
    merged.addAll(data);
    await file.writeAsString(jsonEncode(merged));
  }

  /// Load JSON
  static Future<Map<String, dynamic>?> loadProfile() async {
    final file = await _getFile();
    if (await file.exists()) {
      final raw = await file.readAsString();
      final jsonMap = jsonDecode(raw);
      return jsonMap is Map<String, dynamic> ? jsonMap : null;
    }
    return null;
  }
}
