import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

/// Отвечает за постоянное хранение задач на устройстве.
/// Задачи сериализуются в JSON и сохраняются через shared_preferences,
/// поэтому они не теряются после закрытия приложения.
class TaskStorage {
  static const _storageKey = 'tasks_v1';

  Future<List<Task>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Task.fromJson(item as Map<String, dynamic>))
          .toList();
    } on FormatException {
      // Повреждённые данные не должны ронять приложение.
      return [];
    }
  }

  Future<void> save(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
