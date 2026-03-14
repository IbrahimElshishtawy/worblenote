import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:writdle/domain/entities/task_model.dart';

class TaskLocalCache {
  static const _tasksPrefix = 'tasks_cache_';
  static const _queuePrefix = 'tasks_queue_';

  Future<List<TaskModel>> readTasks(String userId, String date) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString('$_tasksPrefix$userId\_$date');
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTasks(String userId, String date, List<TaskModel> tasks) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      '$_tasksPrefix$userId\_$date',
      jsonEncode(tasks.map((task) => task.toJson()).toList()),
    );
  }

  Future<List<TaskModel>> readAllTasks(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    final keys = preferences.getKeys();
    final allTasks = <TaskModel>[];

    for (final key in keys) {
      if (!key.startsWith('$_tasksPrefix$userId\_')) {
        continue;
      }

      final raw = preferences.getString(key);
      if (raw == null || raw.isEmpty) {
        continue;
      }

      final decoded = jsonDecode(raw) as List<dynamic>;
      allTasks.addAll(
        decoded
            .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    }

    return allTasks;
  }

  Future<List<Map<String, dynamic>>> readQueue(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString('$_queuePrefix$userId');
    if (raw == null || raw.isEmpty) {
      return [];
    }
    return List<Map<String, dynamic>>.from(jsonDecode(raw) as List<dynamic>);
  }

  Future<void> saveQueue(String userId, List<Map<String, dynamic>> queue) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('$_queuePrefix$userId', jsonEncode(queue));
  }
}
