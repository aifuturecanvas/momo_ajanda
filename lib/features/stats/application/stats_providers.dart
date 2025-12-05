import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/features/stats/models/weekly_stats.dart';
import 'package:momo_ajanda/features/tasks/application/task_providers.dart';
import 'package:momo_ajanda/features/reminders/application/reminder_providers.dart';

/// Haftalık istatistikleri hesaplayan provider
final weeklyStatsProvider = Provider<WeeklyStats>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  final remindersAsync = ref.watch(remindersProvider);

  // Haftanın başlangıcını bul (Pazartesi)
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 6));

  // Her gün için istatistik hesapla
  final dailyStats = <DayStats>[];

  for (int i = 0; i < 7; i++) {
    final date = weekStart.add(Duration(days: i));

    // O güne ait görevleri filtrele
    final dayTasks = tasksAsync.maybeWhen(
      data: (tasks) => tasks.where((t) {
        if (t.dueDate == null) {
          // Son tarihi olmayan görevler oluşturulma tarihine göre
          return t.createdAt.year == date.year &&
              t.createdAt.month == date.month &&
              t.createdAt.day == date.day;
        }
        return t.dueDate!.year == date.year &&
            t.dueDate!.month == date.month &&
            t.dueDate!.day == date.day;
      }).toList(),
      orElse: () => [],
    );

    // O güne ait hatırlatıcıları filtrele
    final dayReminders = remindersAsync.maybeWhen(
      data: (reminders) => reminders.where((r) {
        return r.dateTime.year == date.year &&
            r.dateTime.month == date.month &&
            r.dateTime.day == date.day;
      }).toList(),
      orElse: () => [],
    );

    dailyStats.add(DayStats(
      date: date,
      tasksTotal: dayTasks.length,
      tasksCompleted: dayTasks.where((t) => t.isCompleted).length,
      remindersTotal: dayReminders.length,
      remindersCompleted: dayReminders.where((r) => r.isCompleted).length,
      notesCreated: 0, // TODO: Not sayısı eklenecek
      focusTime: Duration.zero, // TODO: Pomodoro ile entegre edilecek
    ));
  }

  return WeeklyStats(
    weekStart: weekStart,
    weekEnd: weekEnd,
    dailyStats: dailyStats,
  );
});

/// Bugünün istatistiklerini gösteren provider
final todayStatsProvider = Provider<DayStats>((ref) {
  final weeklyStats = ref.watch(weeklyStatsProvider);
  final now = DateTime.now();

  return weeklyStats.dailyStats.firstWhere(
    (day) =>
        day.date.year == now.year &&
        day.date.month == now.month &&
        day.date.day == now.day,
    orElse: () => DayStats(date: now),
  );
});

/// Geçmiş hafta karşılaştırması için provider
final weekComparisonProvider = Provider<WeekComparison>((ref) {
  final currentWeek = ref.watch(weeklyStatsProvider);

  // Şimdilik sadece mevcut hafta verisi var
  // TODO: Geçmiş hafta verilerini de hesapla

  return WeekComparison(
    currentWeekScore: currentWeek.averageProductivityScore,
    previousWeekScore: 0, // Henüz veri yok
    improvement: 0,
  );
});

/// Hafta karşılaştırma verisi
class WeekComparison {
  final double currentWeekScore;
  final double previousWeekScore;
  final double improvement;

  WeekComparison({
    required this.currentWeekScore,
    required this.previousWeekScore,
    required this.improvement,
  });

  bool get isImproved => improvement > 0;
  bool get hasPreviousData => previousWeekScore > 0;
}
