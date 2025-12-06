import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/features/tasks/data/repositories/task_repository.dart';
import 'package:momo_ajanda/features/tasks/models/task_model.dart';
import 'package:momo_ajanda/features/tasks/models/task_stats_model.dart';
import 'package:uuid/uuid.dart';

// 1. TaskRepository için provider.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

// 2. Görev listesini yöneten StateNotifierProvider.
final tasksProvider =
    StateNotifierProvider<TasksNotifier, AsyncValue<List<Task>>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TasksNotifier(repository);
});

// 3. Kategori filtresini yöneten StateProvider.
final categoryFilterProvider = StateProvider<String>((ref) => 'Tümü');

// 4. YENİ: Etiket filtresini yöneten StateProvider.
final taskTagFilterProvider = StateProvider<String?>((ref) => null);

// 5. Filtrelenmiş görevleri gösteren provider (kategori + etiket).
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final categoryFilter = ref.watch(categoryFilterProvider);
  final tagFilter = ref.watch(taskTagFilterProvider);
  final tasksAsyncValue = ref.watch(tasksProvider);

  return tasksAsyncValue.maybeWhen(
    data: (tasks) {
      List<Task> filtered = List.from(tasks);

      // Kategori filtresi
      if (categoryFilter != 'Tümü') {
        filtered =
            filtered.where((task) => task.category == categoryFilter).toList();
      }

      // Etiket filtresi
      if (tagFilter != null && tagFilter.isNotEmpty) {
        filtered =
            filtered.where((task) => task.tags.contains(tagFilter)).toList();
      }

      // Sıralama: Tamamlanmamışlar üstte, sonra tarihe göre
      filtered.sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        // Son tarihi olanlar önce
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        if (a.dueDate != null) return -1;
        if (b.dueDate != null) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

      return filtered;
    },
    orElse: () => [],
  );
});

// 6. Görev istatistiklerini hesaplayan provider.
final taskStatsProvider = Provider<TaskStats>((ref) {
  final tasksAsyncValue = ref.watch(tasksProvider);

  return tasksAsyncValue.maybeWhen(
    data: (tasks) {
      final total = tasks.length;
      final completed = tasks.where((task) => task.isCompleted).length;
      return TaskStats(totalTasks: total, completedTasks: completed);
    },
    orElse: () => TaskStats(),
  );
});

// 7. YENİ: Tüm benzersiz etiketleri gösteren provider.
final allTaskTagsProvider = Provider<List<String>>((ref) {
  final tasksAsyncValue = ref.watch(tasksProvider);

  return tasksAsyncValue.maybeWhen(
    data: (tasks) {
      final tags = <String>{};
      for (final task in tasks) {
        tags.addAll(task.tags);
      }
      return tags.toList()..sort();
    },
    orElse: () => [],
  );
});

// 8. YENİ: Bugünün görevlerini gösteren provider.
final todayTasksProvider = Provider<List<Task>>((ref) {
  final tasksAsyncValue = ref.watch(tasksProvider);

  return tasksAsyncValue.maybeWhen(
    data: (tasks) {
      return tasks
          .where((task) => task.isDueToday && !task.isCompleted)
          .toList();
    },
    orElse: () => [],
  );
});

// 9. YENİ: Gecikmiş görevleri gösteren provider.
final overdueTasksProvider = Provider<List<Task>>((ref) {
  final tasksAsyncValue = ref.watch(tasksProvider);

  return tasksAsyncValue.maybeWhen(
    data: (tasks) {
      return tasks.where((task) => task.isOverdue).toList();
    },
    orElse: () => [],
  );
});

// STATE NOTIFIER - Supabase entegre edilmiş versiyon
class TasksNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository _repository;

  TasksNotifier(this._repository) : super(const AsyncLoading()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      state = const AsyncLoading();
      final tasks = await _repository.loadTasks();
      state = AsyncData(tasks);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> addTask(
    String title,
    String category, {
    List<String> tags = const [],
    DateTime? dueDate,
  }) async {
    try {
      final newTask = Task(
        id: const Uuid().v4(),
        title: title,
        category: category,
        tags: tags,
        dueDate: dueDate,
      );

      // Önce Supabase'e ekle
      await _repository.addTask(newTask);

      // Başarılı olursa state'i güncelle
      final previousState = state.value ?? [];
      final updatedList = [newTask, ...previousState];
      state = AsyncData(updatedList);
    } catch (e) {
      // Hata olursa state'i tekrar yükle
      await loadTasks();
      rethrow;
    }
  }

  Future<void> updateTask(Task updatedTask) async {
    try {
      // Önce Supabase'de güncelle
      await _repository.updateTask(updatedTask);

      // Başarılı olursa state'i güncelle
      final previousState = state.value ?? [];
      final updatedList = previousState.map((task) {
        if (task.id == updatedTask.id) {
          return updatedTask;
        }
        return task;
      }).toList();
      state = AsyncData(updatedList);
    } catch (e) {
      // Hata olursa state'i tekrar yükle
      await loadTasks();
      rethrow;
    }
  }

  Future<void> toggleTaskStatus(String id) async {
    try {
      final previousState = state.value ?? [];
      final task = previousState.firstWhere((t) => t.id == id);
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);

      // Önce Supabase'de güncelle
      await _repository.updateTask(updatedTask);

      // Başarılı olursa state'i güncelle
      final updatedList = previousState.map((task) {
        if (task.id == id) {
          return updatedTask;
        }
        return task;
      }).toList();
      state = AsyncData(updatedList);
    } catch (e) {
      // Hata olursa state'i tekrar yükle
      await loadTasks();
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      // Önce Supabase'den sil
      await _repository.deleteTask(id);

      // Başarılı olursa state'i güncelle
      final previousState = state.value ?? [];
      final updatedList = previousState.where((task) => task.id != id).toList();
      state = AsyncData(updatedList);
    } catch (e) {
      // Hata olursa state'i tekrar yükle
      await loadTasks();
      rethrow;
    }
  }

  // YENİ: Göreve etiket ekleme
  Future<void> addTagToTask(String taskId, String tag) async {
    try {
      final previousState = state.value ?? [];
      final task = previousState.firstWhere((t) => t.id == taskId);

      if (!task.tags.contains(tag)) {
        final newTag = tag.startsWith('#') ? tag : '#$tag';
        final updatedTask = task.copyWith(tags: [...task.tags, newTag]);

        // Önce Supabase'de güncelle
        await _repository.updateTask(updatedTask);

        // Başarılı olursa state'i güncelle
        final updatedList = previousState.map((t) {
          if (t.id == taskId) {
            return updatedTask;
          }
          return t;
        }).toList();
        state = AsyncData(updatedList);
      }
    } catch (e) {
      // Hata olursa state'i tekrar yükle
      await loadTasks();
      rethrow;
    }
  }

  // YENİ: Görevden etiket kaldırma
  Future<void> removeTagFromTask(String taskId, String tag) async {
    try {
      final previousState = state.value ?? [];
      final task = previousState.firstWhere((t) => t.id == taskId);
      final updatedTask = task.copyWith(
        tags: task.tags.where((t) => t != tag).toList(),
      );

      // Önce Supabase'de güncelle
      await _repository.updateTask(updatedTask);

      // Başarılı olursa state'i güncelle
      final updatedList = previousState.map((t) {
        if (t.id == taskId) {
          return updatedTask;
        }
        return t;
      }).toList();
      state = AsyncData(updatedList);
    } catch (e) {
      // Hata olursa state'i tekrar yükle
      await loadTasks();
      rethrow;
    }
  }
}
