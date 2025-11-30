import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:momo_ajanda/features/tasks/application/task_providers.dart';
import 'package:momo_ajanda/features/tasks/models/task_model.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final categories = ['Tümü', 'İş', 'Kişisel', 'Alışveriş', 'Sağlık', 'Eğitim'];

  void _showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddTaskSheet(
        onAdd: (title, category, tags, dueDate) {
          ref.read(tasksProvider.notifier).addTask(
                title,
                category,
                tags: tags,
                dueDate: dueDate,
              );
          Navigator.pop(context);
        },
        categories: categories.where((c) => c != 'Tümü').toList(),
        existingTags: ref.read(allTaskTagsProvider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsyncValue = ref.watch(tasksProvider);
    final filteredTasks = ref.watch(filteredTasksProvider);
    final selectedCategory = ref.watch(categoryFilterProvider);
    final selectedTag = ref.watch(taskTagFilterProvider);
    final allTags = ref.watch(allTaskTagsProvider);
    final overdueCount = ref.watch(overdueTasksProvider).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Görevlerim'),
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

          // ETİKET FİLTRE SATIRLARI - YENİ TASARIM
          if (allTags.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.label_outline,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        'Etiketler',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      if (selectedTag != null)
                        TextButton.icon(
                          onPressed: () {
                            ref.read(taskTagFilterProvider.notifier).state =
                                null;
                          },
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text('Temizle'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: allTags.map((tag) {
                      final isSelected = selectedTag == tag;
                      // Bu etikete sahip görev sayısını hesapla
                      final tagCount = ref.watch(tasksProvider).maybeWhen(
                            data: (tasks) =>
                                tasks.where((t) => t.tags.contains(tag)).length,
                            orElse: () => 0,
                          );

                      return FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(tag),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.3)
                                    : Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$tagCount',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          ref.read(taskTagFilterProvider.notifier).state =
                              selected ? tag : null;
                        },
                        selectedColor: Theme.of(context).primaryColor,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : null,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade300,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],

          // Gecikmiş görev uyarısı
          if (overdueCount > 0)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Text(
                    '$overdueCount gecikmiş görev var',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Görev Listesi
          Expanded(
            child: tasksAsyncValue.when(
              data: (tasks) => filteredTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.task_alt,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            selectedCategory == 'Tümü' &&
                                    selectedTag == null &&
                                    tasks.isEmpty
                                ? 'Henüz hiç göreviniz yok'
                                : 'Bu filtrede görev yok',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Yeni görev eklemek için + butonuna tıklayın',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return _TaskTile(
                          task: task,
                          existingTags: allTags,
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text('Hata: ${err.toString()}')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskSheet,
        icon: const Icon(Icons.add),
        label: const Text('Görev Ekle'),
      ),
    );
  }
}

/// Görev kartı widget'ı
class _TaskTile extends ConsumerWidget {
  final Task task;
  final List<String> existingTags;

  const _TaskTile({required this.task, required this.existingTags});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormatter = DateFormat('d MMM', 'tr_TR');

    return Dismissible(
      key: Key(task.id),
      onDismissed: (direction) {
        ref.read(tasksProvider.notifier).deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${task.title} silindi')),
        );
      },
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
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: task.isOverdue
              ? BorderSide(color: Colors.red.shade300, width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showEditSheet(context, ref, task),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Checkbox
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    ref.read(tasksProvider.notifier).toggleTaskStatus(task.id);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                // İçerik
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? Colors.grey
                              : task.isOverdue
                                  ? Colors.red.shade700
                                  : null,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Alt bilgiler satırı
                      Row(
                        children: [
                          // Kategori
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              task.category,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),

                          // Son tarih
                          if (task.dueDate != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: task.isOverdue
                                  ? Colors.red.shade400
                                  : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateFormatter.format(task.dueDate!),
                              style: TextStyle(
                                fontSize: 12,
                                color: task.isOverdue
                                    ? Colors.red.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                            if (task.isOverdue) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Gecikmiş',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),

                      // Etiketler
                      if (task.tags.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 2,
                          children: task.tags.map((tag) {
                            return GestureDetector(
                              onTap: () {
                                // Etikete tıklanınca o etiketi filtrele
                                ref.read(taskTagFilterProvider.notifier).state =
                                    tag;
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditTaskSheet(
        task: task,
        existingTags: existingTags,
        onSave: (updatedTask) {
          ref.read(tasksProvider.notifier).updateTask(updatedTask);
          Navigator.pop(context);
        },
        onDelete: () {
          ref.read(tasksProvider.notifier).deleteTask(task.id);
          Navigator.pop(context);
        },
      ),
    );
  }
}

/// Yeni görev ekleme bottom sheet
class _AddTaskSheet extends StatefulWidget {
  final Function(
          String title, String category, List<String> tags, DateTime? dueDate)
      onAdd;
  final List<String> categories;
  final List<String> existingTags;

  const _AddTaskSheet({
    required this.onAdd,
    required this.categories,
    required this.existingTags,
  });

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _titleController = TextEditingController();
  final _tagController = TextEditingController();
  String _selectedCategory = 'Kişisel';
  DateTime? _selectedDueDate;
  List<String> _tags = [];

  @override
  void dispose() {
    _titleController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag([String? tagToAdd]) {
    final tag = tagToAdd ?? _tagController.text.trim();
    if (tag.isNotEmpty) {
      final formattedTag = tag.startsWith('#') ? tag : '#$tag';
      if (!_tags.contains(formattedTag)) {
        setState(() {
          _tags.add(formattedTag);
          _tagController.clear();
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('d MMMM yyyy', 'tr_TR');

    // Mevcut etiketlerden henüz eklenmemiş olanları göster
    final availableTags =
        widget.existingTags.where((t) => !_tags.contains(t)).toList();

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Yeni Görev',
                    style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Başlık
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Görev başlığı *',
                prefixIcon: Icon(Icons.task_alt),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),

            // Kategori
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: widget.categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedCategory = value);
              },
            ),
            const SizedBox(height: 12),

            // Son tarih
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Son tarih (opsiyonel)',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: _selectedDueDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () =>
                              setState(() => _selectedDueDate = null),
                        )
                      : null,
                ),
                child: Text(
                  _selectedDueDate != null
                      ? dateFormatter.format(_selectedDueDate!)
                      : 'Tarih seçin',
                  style: TextStyle(
                    color: _selectedDueDate != null ? null : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Mevcut etiketler - hızlı seçim
            if (availableTags.isNotEmpty) ...[
              Text(
                'Mevcut Etiketler (tıklayarak ekle)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: availableTags.map((tag) {
                  return ActionChip(
                    avatar: const Icon(Icons.add, size: 16),
                    label: Text(tag),
                    onPressed: () => _addTag(tag),
                    backgroundColor: Colors.grey.shade100,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Yeni etiket ekleme
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      labelText: 'Yeni etiket ekle',
                      hintText: '#iş, #acil...',
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => _addTag(),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            // Seçilen etiketler
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Seçilen Etiketler',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => setState(() => _tags.remove(tag)),
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  widget.onAdd(
                    _titleController.text,
                    _selectedCategory,
                    _tags,
                    _selectedDueDate,
                  );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Görev Ekle'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Görev düzenleme bottom sheet
class _EditTaskSheet extends StatefulWidget {
  final Task task;
  final List<String> existingTags;
  final Function(Task) onSave;
  final VoidCallback onDelete;

  const _EditTaskSheet({
    required this.task,
    required this.existingTags,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<_EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<_EditTaskSheet> {
  late final TextEditingController _titleController;
  final _tagController = TextEditingController();
  late String _selectedCategory;
  late DateTime? _selectedDueDate;
  late List<String> _tags;

  final categories = ['İş', 'Kişisel', 'Alışveriş', 'Sağlık', 'Eğitim'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _selectedCategory = widget.task.category;
    _selectedDueDate = widget.task.dueDate;
    _tags = List.from(widget.task.tags);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag([String? tagToAdd]) {
    final tag = tagToAdd ?? _tagController.text.trim();
    if (tag.isNotEmpty) {
      final formattedTag = tag.startsWith('#') ? tag : '#$tag';
      if (!_tags.contains(formattedTag)) {
        setState(() {
          _tags.add(formattedTag);
          _tagController.clear();
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('d MMMM yyyy', 'tr_TR');

    // Mevcut etiketlerden henüz eklenmemiş olanları göster
    final availableTags =
        widget.existingTags.where((t) => !_tags.contains(t)).toList();

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Görevi Düzenle',
                    style: Theme.of(context).textTheme.titleLarge),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Görevi Sil'),
                            content: const Text(
                                'Bu görevi silmek istediğinize emin misiniz?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('İptal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  widget.onDelete();
                                },
                                child: const Text('Sil',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Görev başlığı',
                prefixIcon: Icon(Icons.task_alt),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedCategory = value);
              },
            ),
            const SizedBox(height: 12),

            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Son tarih',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: _selectedDueDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () =>
                              setState(() => _selectedDueDate = null),
                        )
                      : null,
                ),
                child: Text(
                  _selectedDueDate != null
                      ? dateFormatter.format(_selectedDueDate!)
                      : 'Tarih seçin',
                  style: TextStyle(
                    color: _selectedDueDate != null ? null : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Mevcut etiketler - hızlı seçim
            if (availableTags.isNotEmpty) ...[
              Text(
                'Mevcut Etiketler',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: availableTags.map((tag) {
                  return ActionChip(
                    avatar: const Icon(Icons.add, size: 16),
                    label: Text(tag),
                    onPressed: () => _addTag(tag),
                    backgroundColor: Colors.grey.shade100,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      labelText: 'Yeni etiket ekle',
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => _addTag(),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Bu Görevin Etiketleri',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => setState(() => _tags.remove(tag)),
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  widget.onSave(widget.task.copyWith(
                    title: _titleController.text,
                    category: _selectedCategory,
                    tags: _tags,
                    dueDate: _selectedDueDate,
                  ));
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Kaydet'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
