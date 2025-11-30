import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/features/tasks/application/task_providers.dart';
import 'package:momo_ajanda/features/tasks/models/task_model.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsyncValue = ref.watch(tasksProvider);
    final filteredTasks = ref.watch(filteredTasksProvider);
    final selectedCategory = ref.watch(categoryFilterProvider);
    final taskController = TextEditingController();

    final categories = ['Tümü', 'İş', 'Kişisel', 'Alışveriş'];

    void addTask() {
      if (taskController.text.isNotEmpty) {
        final categoryForNewTask =
            selectedCategory == 'Tümü' ? 'Kişisel' : selectedCategory;
        ref
            .read(tasksProvider.notifier)
            .addTask(taskController.text, categoryForNewTask);
        taskController.clear();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Görevlerim'),
        elevation: 1,
      ),
      body: Column(
        children: [
          // Kategori Filtre Butonları
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: category == selectedCategory,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(categoryFilterProvider.notifier).state =
                            category;
                      }
                    },
                  ),
                );
              },
            ),
          ),

          // Görev Listesi
          Expanded(
            child: tasksAsyncValue.when(
              data: (tasks) => filteredTasks.isEmpty
                  ? Center(
                      child: Text(
                        selectedCategory == 'Tümü' && tasks.isEmpty
                            ? 'Henüz hiç göreviniz yok.'
                            : 'Bu kategoride görev yok.',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return _buildTaskTile(context, ref, task);
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text('Hata: ${err.toString()}')),
            ),
          ),

          // Yeni Görev Ekleme Alanı
          _buildAddTaskBar(taskController, addTask),
        ],
      ),
    );
  }

  Widget _buildTaskTile(BuildContext context, WidgetRef ref, Task task) {
    return Dismissible(
      key: Key(task.id),
      onDismissed: (direction) =>
          ref.read(tasksProvider.notifier).deleteTask(task.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        child: ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (value) =>
                ref.read(tasksProvider.notifier).toggleTaskStatus(task.id),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: task.isCompleted ? Colors.grey : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddTaskBar(
      TextEditingController controller, VoidCallback onAdd) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Yeni bir görev ekle...',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => onAdd(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            icon: const Icon(Icons.add),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}
