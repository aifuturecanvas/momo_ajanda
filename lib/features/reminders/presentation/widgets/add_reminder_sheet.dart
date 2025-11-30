import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:momo_ajanda/features/reminders/application/reminder_providers.dart';
import 'package:momo_ajanda/features/reminders/models/reminder_model.dart';

class AddReminderSheet extends ConsumerStatefulWidget {
  final Reminder? existingReminder; // Düzenleme için mevcut hatırlatıcı

  const AddReminderSheet({super.key, this.existingReminder});

  @override
  ConsumerState<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends ConsumerState<AddReminderSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late ReminderPriority _selectedPriority;
  late ReminderRepeat _selectedRepeat;
  late int _minutesBefore;
  late List<String> _tags;

  bool get isEditing => widget.existingReminder != null;

  @override
  void initState() {
    super.initState();

    final existing = widget.existingReminder;

    _titleController = TextEditingController(text: existing?.title ?? '');
    _descriptionController =
        TextEditingController(text: existing?.description ?? '');
    _tagController = TextEditingController();

    _selectedDate = existing?.dateTime ?? DateTime.now();
    _selectedTime = existing != null
        ? TimeOfDay(
            hour: existing.dateTime.hour, minute: existing.dateTime.minute)
        : TimeOfDay.now();
    _selectedPriority = existing?.priority ?? ReminderPriority.medium;
    _selectedRepeat = existing?.repeat ?? ReminderRepeat.none;
    _minutesBefore = existing?.minutesBefore ?? 15;
    _tags = existing?.tags.toList() ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag.startsWith('#') ? tag : '#$tag');
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  void _saveReminder() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir başlık girin')),
      );
      return;
    }

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (isEditing) {
      // Mevcut hatırlatıcıyı güncelle
      final updated = widget.existingReminder!.copyWith(
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        dateTime: dateTime,
        priority: _selectedPriority,
        repeat: _selectedRepeat,
        tags: _tags,
        minutesBefore: _minutesBefore,
      );
      ref.read(remindersProvider.notifier).updateReminder(updated);
    } else {
      // Yeni hatırlatıcı ekle
      ref.read(remindersProvider.notifier).addReminder(
            title: _titleController.text,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            dateTime: dateTime,
            priority: _selectedPriority,
            repeat: _selectedRepeat,
            tags: _tags,
            minutesBefore: _minutesBefore,
          );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('d MMMM yyyy, EEEE', 'tr_TR');

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
            // Başlık
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Hatırlatıcıyı Düzenle' : 'Yeni Hatırlatıcı',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Başlık girişi
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Başlık *',
                hintText: 'Örn: Toplantıya katıl',
                prefixIcon: Icon(Icons.title),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),

            // Açıklama girişi
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama (opsiyonel)',
                hintText: 'Detaylı bilgi ekleyin...',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Tarih ve Saat seçimi
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tarih',
                        prefixIcon: Icon(Icons.calendar_today),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text(dateFormatter.format(_selectedDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _selectTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Saat',
                        prefixIcon: Icon(Icons.access_time),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text(_selectedTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Öncelik seçimi
            Row(
              children: [
                const Icon(Icons.flag_outlined, color: Colors.grey),
                const SizedBox(width: 12),
                const Text('Öncelik:'),
                const SizedBox(width: 12),
                Expanded(
                  child: SegmentedButton<ReminderPriority>(
                    segments: const [
                      ButtonSegment(
                        value: ReminderPriority.low,
                        label: Text('Düşük'),
                        icon: Icon(Icons.arrow_downward, size: 16),
                      ),
                      ButtonSegment(
                        value: ReminderPriority.medium,
                        label: Text('Orta'),
                        icon: Icon(Icons.remove, size: 16),
                      ),
                      ButtonSegment(
                        value: ReminderPriority.high,
                        label: Text('Yüksek'),
                        icon: Icon(Icons.priority_high, size: 16),
                      ),
                    ],
                    selected: {_selectedPriority},
                    onSelectionChanged: (selection) {
                      setState(() => _selectedPriority = selection.first);
                    },
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tekrar seçimi
            Row(
              children: [
                const Icon(Icons.repeat, color: Colors.grey),
                const SizedBox(width: 12),
                const Text('Tekrar:'),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<ReminderRepeat>(
                    value: _selectedRepeat,
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ReminderRepeat.values.map((repeat) {
                      String text;
                      switch (repeat) {
                        case ReminderRepeat.none:
                          text = 'Tekrar yok';
                          break;
                        case ReminderRepeat.daily:
                          text = 'Her gün';
                          break;
                        case ReminderRepeat.weekly:
                          text = 'Her hafta';
                          break;
                        case ReminderRepeat.monthly:
                          text = 'Her ay';
                          break;
                        case ReminderRepeat.yearly:
                          text = 'Her yıl';
                          break;
                      }
                      return DropdownMenuItem(value: repeat, child: Text(text));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedRepeat = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ne kadar önce hatırlat
            Row(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.grey),
                const SizedBox(width: 12),
                const Text('Hatırlat:'),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _minutesBefore,
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Tam zamanında')),
                      DropdownMenuItem(value: 5, child: Text('5 dk önce')),
                      DropdownMenuItem(value: 10, child: Text('10 dk önce')),
                      DropdownMenuItem(value: 15, child: Text('15 dk önce')),
                      DropdownMenuItem(value: 30, child: Text('30 dk önce')),
                      DropdownMenuItem(value: 60, child: Text('1 saat önce')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _minutesBefore = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Etiket ekleme
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      labelText: 'Etiket ekle',
                      hintText: '#iş, #kişisel...',
                      prefixIcon: Icon(Icons.tag),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addTag,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            // Eklenen etiketler
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeTag(tag),
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 24),

            // Kaydet butonu
            ElevatedButton.icon(
              onPressed: _saveReminder,
              icon: Icon(isEditing ? Icons.save : Icons.add),
              label: Text(isEditing ? 'Güncelle' : 'Hatırlatıcı Ekle'),
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
