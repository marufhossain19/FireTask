import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class LocalStorageService {
  static String _keyForUser(String userId) => 'local_stored_tasks_$userId';

  static Future<List<TaskModel>> loadTasks([String? userId]) async {
    final uid = (userId != null && userId.isNotEmpty) ? userId : 'guest';
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyForUser(uid));
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList
          .map((item) => TaskModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveTasks(List<TaskModel> tasks, [String? userId]) async {
    final uid = (userId != null && userId.isNotEmpty) ? userId : 'guest';
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedList = tasks.map((t) => t.toJsonMap()).toList();
      final jsonString = jsonEncode(encodedList);
      await prefs.setString(_keyForUser(uid), jsonString);
    } catch (_) {}
  }

  static Future<void> clearTasks([String? userId]) async {
    final uid = (userId != null && userId.isNotEmpty) ? userId : 'guest';
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyForUser(uid));
    } catch (_) {}
  }
}
