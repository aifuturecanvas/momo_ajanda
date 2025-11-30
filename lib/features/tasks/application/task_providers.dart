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

// 4. Filtrelenmiş görevleri gösteren provider.
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final filter = ref.watch(categoryFilterProvider);
  final tasksAsyncValue = ref.watch(tasksProvider);

  // Sadece veri başarıyla yüklendiğinde filtreleme yap.
  return tasksAsyncValue.maybeWhen(
    data: (tasks) {
      List<Task> filtered;
      if (filter == 'Tümü') {
        filtered = List.from(tasks);
      } else {
        filtered = tasks.where((task) => task.category == filter).toList();
      }
      filtered.sort((a, b) =>
          a.isCompleted == b.isCompleted ? 0 : (a.isCompleted ? 1 : -1));
      return filtered;
    },
    // Veri yoksa veya hata varsa boş liste göster.
    orElse: () => [],
  );
});

// 5. Görev istatistiklerini hesaplayan provider.
final taskStatsProvider = Provider<TaskStats>((ref) {
  final tasksAsyncValue = ref.watch(tasksProvider);

  return tasksAsyncValue.maybeWhen(
    data: (tasks) {
      final total = tasks.length;
      final completed = tasks.where((task) => task.isCompleted).length;
      return TaskStats(totalTasks: total, completedTasks: completed);
    },
    orElse: () =>
        TaskStats(), // Yüklenirken veya hata durumunda varsayılan değer.
  );
});

// STATE NOTIFIER
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

  Future<void> addTask(String title, String category) async {
    final newTask = Task(
      id: const Uuid().v4(),
      title: title,
      category: category,
    );
    // Mevcut durumu al ve üzerine ekle.
    final previousState = state.value ?? [];
    final updatedList = [newTask, ...previousState];
    state = AsyncData(updatedList);
    await _repository.saveTasks(updatedList);
  }

  Future<void> toggleTaskStatus(String id) async {
    final previousState = state.value ?? [];
    final updatedList = previousState.map((task) {
      if (task.id == id) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();
    state = AsyncData(updatedList);
    await _repository.saveTasks(updatedList);
  }

  Future<void> deleteTask(String id) async {
    final previousState = state.value ?? [];
    final updatedList = previousState.where((task) => task.id != id).toList();
    state = AsyncData(updatedList);
    await _repository.saveTasks(updatedList);
  }
}
