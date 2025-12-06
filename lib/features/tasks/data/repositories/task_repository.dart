import 'package:flutter/foundation.dart';
import 'package:momo_ajanda/core/services/supabase_service.dart';
import 'package:momo_ajanda/features/tasks/models/task_model.dart';

/// Bu sınıf, görev verilerini Supabase'de kaydetme ve yükleme işlerinden sorumludur.
class TaskRepository {
  final SupabaseService _supabase = SupabaseService();

  /// Kullanıcının tüm görevlerini Supabase'den yükler
  Future<List<Task>> loadTasks() async {
    try {
      final data = await _supabase.getTasks();
      return data.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      debugPrint('TaskRepository.loadTasks hatası: $e');
      return [];
    }
  }

  /// Yeni görev ekler (tek task için)
  Future<void> addTask(Task task) async {
    try {
      await _supabase.addTask(task.toJson());
    } catch (e) {
      debugPrint('TaskRepository.addTask hatası: $e');
      rethrow;
    }
  }

  /// Görevi günceller
  Future<void> updateTask(Task task) async {
    try {
      await _supabase.updateTask(task.id, task.toJson());
    } catch (e) {
      debugPrint('TaskRepository.updateTask hatası: $e');
      rethrow;
    }
  }

  /// Görevi siler
  Future<void> deleteTask(String id) async {
    try {
      await _supabase.deleteTask(id);
    } catch (e) {
      debugPrint('TaskRepository.deleteTask hatası: $e');
      rethrow;
    }
  }

  /// DEPRECATED: Artık kullanılmıyor - Supabase ile tek tek işlemler yapılıyor
  @Deprecated('Supabase ile direkt işlem yapıldığı için gerekli değil')
  Future<void> saveTasks(List<Task> tasks) async {
    // Bu method artık kullanılmıyor
    debugPrint('⚠️ saveTasks() deprecated - Supabase kullanın');
  }
}
