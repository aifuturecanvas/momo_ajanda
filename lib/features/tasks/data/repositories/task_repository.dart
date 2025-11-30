import 'dart:convert';
import 'package:momo_ajanda/features/tasks/models/task_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Bu sınıf, görev verilerini kaydetme ve yükleme işlerinden sorumludur.
class TaskRepository {
  final _storageKey = 'tasks_data';

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> tasksAsMap =
        tasks.map((task) => task.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(tasksAsMap));
  }

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString(_storageKey);
    if (tasksString != null && tasksString.isNotEmpty) {
      final List<dynamic> decodedData = jsonDecode(tasksString);
      return decodedData.map((item) => Task.fromJson(item)).toList();
    }
    return []; // Veri yoksa boş liste döndür.
  }
}
