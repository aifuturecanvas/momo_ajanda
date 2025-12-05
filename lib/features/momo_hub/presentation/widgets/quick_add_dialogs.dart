import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/features/tasks/domain/task_model.dart';

/// Hızlı Görev Ekleme Dialog
class QuickTaskDialog extends ConsumerStatefulWidget {
  final String? initialContent;

  const QuickTaskDialog({super.key, this.initialContent});

  @override
  ConsumerState<QuickTaskDialog> createState() => _QuickTaskDialogState();
}

class _QuickTaskDialogState extends ConsumerState<QuickTaskDialog> {
  late TextEditingController _controller;
  DateTime? _selectedDate;
  TaskPriority _priority = TaskPriority.medium;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent ?? '');
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.add_task, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Hızlı Görev Ekle'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Görev açıklaması...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.edit),
              ),
              maxLines: 2,
              autofocus: true,
            ),
            const SizedBox(height: 16),

            // Tarih seçimi
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(_selectedDate == null
                  ? 'Tarih seç'
                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
              trailing: const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
            const SizedBox(height: 12),

            // Öncelik seçimi
            Wrap(
              spacing: 8,
              children: [
                const Text('Öncelik: '),
                ChoiceChip(
                  label: const Text('Düşük'),
                  selected: _priority == TaskPriority.low,
                  selectedColor: Colors.green.shade100,
                  onSelected: (_) =>
                      setState(() => _priority = TaskPriority.low),
                ),
                ChoiceChip(
                  label: const Text('Orta'),
                  selected: _priority == TaskPriority.medium,
                  selectedColor: Colors.orange.shade100,
                  onSelected: (_) =>
                      setState(() => _priority = TaskPriority.medium),
                ),
                ChoiceChip(
                  label: const Text('Yüksek'),
                  selected: _priority == TaskPriority.high,
                  selectedColor: Colors.red.shade100,
                  onSelected: (_) =>
                      setState(() => _priority = TaskPriority.high),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        FilledButton.icon(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              Navigator.pop(context, {
                'title': _controller.text.trim(),
                'due_date': _selectedDate?.toIso8601String(),
                'priority': _priority.name,
              });
            }
          },
          icon: const Icon(Icons.check),
          label: const Text('Ekle'),
        ),
      ],
    );
  }
}

/// Hızlı Hatırlatıcı Ekleme Dialog
class QuickReminderDialog extends ConsumerStatefulWidget {
  final String? initialContent;
  final String? initialTime;

  const QuickReminderDialog({
    super.key,
    this.initialContent,
    this.initialTime,
  });

  @override
  ConsumerState<QuickReminderDialog> createState() =>
      _QuickReminderDialogState();
}

class _QuickReminderDialogState extends ConsumerState<QuickReminderDialog> {
  late TextEditingController _controller;
  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent ?? '');

    if (widget.initialTime != null) {
      final parts = widget.initialTime!.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]) ?? DateTime.now().hour;
        final minute = int.tryParse(parts[1]) ?? 0;
        _selectedDateTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          hour,
          minute,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.alarm_add, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Hızlı Hatırlatıcı'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ne hatırlatayım?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.notification_important),
              ),
              maxLines: 2,
              autofocus: true,
            ),
            const SizedBox(height: 16),

            // Tarih seçimi
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year}',
              ),
              trailing: const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDateTime,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _selectedDateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      _selectedDateTime.hour,
                      _selectedDateTime.minute,
                    );
                  });
                }
              },
            ),
            const SizedBox(height: 8),

            // Saat seçimi
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(
                '${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                );
                if (time != null) {
                  setState(() {
                    _selectedDateTime = DateTime(
                      _selectedDateTime.year,
                      _selectedDateTime.month,
                      _selectedDateTime.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        FilledButton.icon(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              Navigator.pop(context, {
                'title': _controller.text.trim(),
                'reminder_time': _selectedDateTime.toIso8601String(),
              });
            }
          },
          icon: const Icon(Icons.check),
          label: const Text('Ekle'),
        ),
      ],
    );
  }
}

/// Hızlı Not Ekleme Dialog
class QuickNoteDialog extends StatefulWidget {
  final String? initialContent;

  const QuickNoteDialog({super.key, this.initialContent});

  @override
  State<QuickNoteDialog> createState() => _QuickNoteDialogState();
}

class _QuickNoteDialogState extends State<QuickNoteDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController =
        TextEditingController(text: widget.initialContent ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.note_add, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Hızlı Not'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Başlık',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: 'Not içeriği...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.edit_note),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        FilledButton.icon(
          onPressed: () {
            if (_contentController.text.trim().isNotEmpty) {
              Navigator.pop(context, {
                'title': _titleController.text.trim(),
                'content': _contentController.text.trim(),
              });
            }
          },
          icon: const Icon(Icons.check),
          label: const Text('Kaydet'),
        ),
      ],
    );
  }
}
