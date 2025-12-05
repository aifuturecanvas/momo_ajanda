import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/core/services/notification_service.dart';
import 'package:momo_ajanda/features/reminders/application/reminder_providers.dart';
import 'package:momo_ajanda/features/reminders/presentation/widgets/add_reminder_sheet.dart';
import 'package:momo_ajanda/features/reminders/presentation/widgets/reminder_card.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(remindersProvider.notifier).processRepeatingReminders();
      _requestNotificationPermission();
    });
  }

  Future<void> _requestNotificationPermission() async {
    final granted = await NotificationService().requestPermission();
    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Hatırlatıcılar için bildirim izni gerekli'),
          action: SnackBarAction(
            label: 'Tamam',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddReminderSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddReminderSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remindersAsync = ref.watch(remindersProvider);
    final stats = ref.watch(reminderStatsProvider);
    final allTags = ref.watch(allTagsProvider);
    final selectedTag = ref.watch(reminderTagFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hatırlatıcılar'),
        actions: [
          if (allTags.isNotEmpty)
            PopupMenuButton<String?>(
              icon: Badge(
                isLabelVisible: selectedTag != null,
                child: const Icon(Icons.filter_list),
              ),
              onSelected: (tag) {
                ref.read(reminderTagFilterProvider.notifier).state = tag;
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: null,
                  child: Row(
                    children: [
                      Icon(Icons.clear_all),
                      SizedBox(width: 8),
                      Text('Tümünü Göster'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                ...allTags.map((tag) => PopupMenuItem(
                      value: tag,
                      child: Row(
                        children: [
                          Icon(
                            selectedTag == tag
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(tag),
                        ],
                      ),
                    )),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Bugün'),
                  if (stats.todayPending > 0) ...[
                    const SizedBox(width: 6),
                    _buildBadge(stats.todayPending),
                  ],
                ],
              ),
            ),
            const Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Yaklaşan'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Tümü'),
                  if (stats.overdue > 0) ...[
                    const SizedBox(width: 6),
                    _buildBadge(stats.overdue, isWarning: true),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: remindersAsync.when(
        data: (_) => TabBarView(
          controller: _tabController,
          children: [
            _TodayTab(),
            _UpcomingTab(),
            _AllRemindersTab(),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Hata: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(remindersProvider.notifier).loadReminders(),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReminderSheet,
        icon: const Icon(Icons.add_alarm),
        label: const Text('Hatırlatıcı'),
      ),
    );
  }

  Widget _buildBadge(int count, {bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isWarning ? Colors.red : Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TodayTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayReminders = ref.watch(todayRemindersProvider);
    final overdueReminders = ref.watch(overdueRemindersProvider);

    if (todayReminders.isEmpty && overdueReminders.isEmpty) {
      return _EmptyState(
        icon: Icons.today,
        title: 'Bugün için hatırlatıcı yok',
        subtitle: 'Yeni bir hatırlatıcı ekleyerek başlayın',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (overdueReminders.isNotEmpty) ...[
          _SectionHeader(
            title: 'Gecikmiş',
            count: overdueReminders.length,
            color: Colors.red,
          ),
          ...overdueReminders.map((r) => ReminderCard(reminder: r)),
          const SizedBox(height: 16),
        ],
        if (todayReminders.isNotEmpty) ...[
          _SectionHeader(
            title: 'Bugün',
            count: todayReminders.length,
          ),
          ...todayReminders.map((r) => ReminderCard(reminder: r)),
        ],
      ],
    );
  }
}

class _UpcomingTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingReminders = ref.watch(upcomingRemindersProvider);

    if (upcomingReminders.isEmpty) {
      return _EmptyState(
        icon: Icons.upcoming,
        title: 'Yaklaşan hatırlatıcı yok',
        subtitle: 'Önümüzdeki 7 gün içinde planlanmış hatırlatıcı bulunmuyor',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(
          title: 'Önümüzdeki 7 Gün',
          count: upcomingReminders.length,
        ),
        ...upcomingReminders.map((r) => ReminderCard(reminder: r)),
      ],
    );
  }
}

class _AllRemindersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredReminders = ref.watch(filteredRemindersProvider);
    final selectedTag = ref.watch(reminderTagFilterProvider);

    if (filteredReminders.isEmpty) {
      return _EmptyState(
        icon: Icons.notifications_none,
        title: selectedTag != null
            ? '"$selectedTag" etiketli hatırlatıcı yok'
            : 'Henüz hatırlatıcı yok',
        subtitle: 'Sağ alttaki butona tıklayarak yeni hatırlatıcı ekleyin',
      );
    }

    final activeReminders =
        filteredReminders.where((r) => !r.isCompleted).toList();
    final completedReminders =
        filteredReminders.where((r) => r.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (selectedTag != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Chip(
              label: Text('Filtre: $selectedTag'),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                ref.read(reminderTagFilterProvider.notifier).state = null;
              },
            ),
          ),
        if (activeReminders.isNotEmpty) ...[
          _SectionHeader(
            title: 'Aktif',
            count: activeReminders.length,
          ),
          ...activeReminders.map((r) => ReminderCard(reminder: r)),
        ],
        if (completedReminders.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionHeader(
            title: 'Tamamlanan',
            count: completedReminders.length,
            color: Colors.grey,
          ),
          ...completedReminders.map((r) => ReminderCard(reminder: r)),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color? color;

  const _SectionHeader({
    required this.title,
    required this.count,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color ?? Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
