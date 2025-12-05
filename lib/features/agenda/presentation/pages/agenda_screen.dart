import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/core/theme/app_colors.dart';
import 'package:momo_ajanda/features/agenda/presentation/widgets/notebook/notebook_page.dart';
import 'package:momo_ajanda/features/agenda/presentation/widgets/notebook/page_flip_view.dart';
import 'package:momo_ajanda/features/agenda/presentation/widgets/notebook/date_header.dart';
import 'package:momo_ajanda/features/tasks/application/task_providers.dart';
import 'package:momo_ajanda/features/reminders/application/reminder_providers.dart';

/// Seçili tarihi yöneten provider
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Seçili defter temasını yöneten provider
final notebookThemeProvider =
    StateProvider<NotebookTheme>((ref) => NotebookTheme.classic);

class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  late PageController _pageController;
  final int _initialPageIndex = 500; // Ortadan başla (geçmiş ve gelecek için)

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getDateForIndex(int index) {
    final difference = index - _initialPageIndex;
    return DateTime.now().add(Duration(days: difference));
  }

  int _getIndexForDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    return _initialPageIndex + targetDate.difference(today).inDays;
  }

  void _goToDate(DateTime date) {
    final index = _getIndexForDate(date);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToToday() {
    _pageController.animateToPage(
      _initialPageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _showDatePicker() async {
    final selectedDate = ref.read(selectedDateProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      _goToDate(picked);
    }
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ThemePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final theme = ref.watch(notebookThemeProvider);

    return Scaffold(
      backgroundColor: theme.paperColor.withOpacity(0.5),
      appBar: AppBar(
        title: const Text('Ajanda'),
        backgroundColor: theme.bindingColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Bugüne Git',
            onPressed: _goToToday,
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Tema Seç',
            onPressed: _showThemePicker,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tarih başlığı
          Container(
            color: theme.paperColor,
            child: DateHeader(
              date: selectedDate,
              textColor: theme.textColor,
              onPreviousDay: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              onNextDay: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              onDateTap: _showDatePicker,
            ),
          ),

          // Sayfa çevirme görünümü
          Expanded(
            child: PageFlipView(
              controller: _pageController,
              itemCount: 1000, // 500 gün geçmiş, 500 gün gelecek
              onPageChanged: (index) {
                final date = _getDateForIndex(index);
                ref.read(selectedDateProvider.notifier).state = date;
              },
              itemBuilder: (context, index) {
                final date = _getDateForIndex(index);
                return _DayPage(date: date, theme: theme);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_agenda',
        onPressed: () => _showAddEntrySheet(selectedDate),
        backgroundColor: theme.bindingColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddEntrySheet(DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddEntrySheet(date: date),
    );
  }
}

/// Gün sayfası
class _DayPage extends ConsumerWidget {
  final DateTime date;
  final NotebookTheme theme;

  const _DayPage({required this.date, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final remindersAsync = ref.watch(remindersProvider);

    // Bu güne ait görevleri ve hatırlatıcıları filtrele
    final dayTasks = tasksAsync.maybeWhen(
      data: (tasks) => tasks.where((t) {
        if (t.dueDate == null) return false;
        return t.dueDate!.year == date.year &&
            t.dueDate!.month == date.month &&
            t.dueDate!.day == date.day;
      }).toList(),
      orElse: () => [],
    );

    final dayReminders = remindersAsync.maybeWhen(
      data: (reminders) => reminders.where((r) {
        return r.dateTime.year == date.year &&
            r.dateTime.month == date.month &&
            r.dateTime.day == date.day;
      }).toList(),
      orElse: () => [],
    );

    // TimeSlotEntry widget'ları oluştur
    final entries = <Widget>[];

    for (final task in dayTasks) {
      entries.add(TimeSlotEntry(
        hour: 9, // Varsayılan saat
        title: '📋 ${task.title}',
        color: task.isCompleted ? Colors.green : Colors.orange,
      ));
    }

    for (final reminder in dayReminders) {
      entries.add(TimeSlotEntry(
        hour: reminder.dateTime.hour,
        title: '🔔 ${reminder.title}',
        color: reminder.isCompleted ? Colors.green : Colors.blue,
      ));
    }

    return NotebookPage(
      date: date,
      theme: theme,
      showTimeSlots: true,
      children: entries,
    );
  }
}

/// Tema seçici
class _ThemePickerSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(notebookThemeProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Defter Teması',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...NotebookTheme.all.map((theme) {
            final isSelected = theme.name == currentTheme.name;
            return ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.paperColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.lineColor, width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 4,
                    height: 32,
                    color: theme.bindingColor,
                  ),
                ),
              ),
              title: Text(theme.name),
              trailing: isSelected
                  ? Icon(Icons.check_circle,
                      color: Theme.of(context).primaryColor)
                  : null,
              onTap: () {
                ref.read(notebookThemeProvider.notifier).state = theme;
                Navigator.pop(context);
              },
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Giriş ekleme sheet'i
class _AddEntrySheet extends StatelessWidget {
  final DateTime date;

  const _AddEntrySheet({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ne eklemek istersin?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _EntryTypeButton(
                  icon: Icons.task_alt,
                  label: 'Görev',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Görev ekleme ekranına yönlendir
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Görevler sekmesinden ekleyebilirsiniz')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _EntryTypeButton(
                  icon: Icons.notifications,
                  label: 'Hatırlatıcı',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Hatırlatıcı ekleme ekranına yönlendir
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Hatırlatıcılar sekmesinden ekleyebilirsiniz')),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _EntryTypeButton(
                  icon: Icons.note_add,
                  label: 'Not',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Not ekleme ekranına yönlendir
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Notlar sekmesinden ekleyebilirsiniz')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _EntryTypeButton(
                  icon: Icons.event,
                  label: 'Etkinlik',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Etkinlik özelliği yakında!')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EntryTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _EntryTypeButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
