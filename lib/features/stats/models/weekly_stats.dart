import 'package:flutter/material.dart';

/// Günlük istatistik verisi
class DayStats {
  final DateTime date;
  final int tasksCompleted;
  final int tasksTotal;
  final int remindersCompleted;
  final int remindersTotal;
  final int notesCreated;
  final Duration focusTime;

  DayStats({
    required this.date,
    this.tasksCompleted = 0,
    this.tasksTotal = 0,
    this.remindersCompleted = 0,
    this.remindersTotal = 0,
    this.notesCreated = 0,
    this.focusTime = Duration.zero,
  });

  /// Toplam tamamlanan iş
  int get totalCompleted => tasksCompleted + remindersCompleted;

  /// Toplam iş
  int get totalItems => tasksTotal + remindersTotal;

  /// Tamamlanma oranı
  double get completionRate {
    if (totalItems == 0) return 0;
    return totalCompleted / totalItems;
  }

  /// Gün adı (kısa)
  String get dayName {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[date.weekday - 1];
  }

  /// Verimlilik skoru (0-100)
  int get productivityScore {
    double score = 0;

    // Görev tamamlama (%50)
    if (tasksTotal > 0) {
      score += (tasksCompleted / tasksTotal) * 50;
    }

    // Hatırlatıcı tamamlama (%30)
    if (remindersTotal > 0) {
      score += (remindersCompleted / remindersTotal) * 30;
    }

    // Not oluşturma (%10)
    score += (notesCreated.clamp(0, 5) / 5) * 10;

    // Odaklanma süresi (%10)
    final focusMinutes = focusTime.inMinutes;
    score += (focusMinutes.clamp(0, 120) / 120) * 10;

    return score.round();
  }
}

/// Haftalık istatistik özeti
class WeeklyStats {
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<DayStats> dailyStats;

  WeeklyStats({
    required this.weekStart,
    required this.weekEnd,
    required this.dailyStats,
  });

  /// Toplam tamamlanan görev
  int get totalTasksCompleted =>
      dailyStats.fold(0, (sum, day) => sum + day.tasksCompleted);

  /// Toplam görev
  int get totalTasks => dailyStats.fold(0, (sum, day) => sum + day.tasksTotal);

  /// Toplam tamamlanan hatırlatıcı
  int get totalRemindersCompleted =>
      dailyStats.fold(0, (sum, day) => sum + day.remindersCompleted);

  /// Toplam hatırlatıcı
  int get totalReminders =>
      dailyStats.fold(0, (sum, day) => sum + day.remindersTotal);

  /// Toplam oluşturulan not
  int get totalNotesCreated =>
      dailyStats.fold(0, (sum, day) => sum + day.notesCreated);

  /// Toplam odaklanma süresi
  Duration get totalFocusTime =>
      dailyStats.fold(Duration.zero, (sum, day) => sum + day.focusTime);

  /// Haftalık tamamlanma oranı
  double get weeklyCompletionRate {
    final total = totalTasks + totalReminders;
    if (total == 0) return 0;
    return (totalTasksCompleted + totalRemindersCompleted) / total;
  }

  /// Ortalama günlük verimlilik skoru
  double get averageProductivityScore {
    if (dailyStats.isEmpty) return 0;
    return dailyStats.fold(0, (sum, day) => sum + day.productivityScore) /
        dailyStats.length;
  }

  /// En verimli gün
  DayStats? get mostProductiveDay {
    if (dailyStats.isEmpty) return null;
    return dailyStats
        .reduce((a, b) => a.productivityScore > b.productivityScore ? a : b);
  }

  /// En az verimli gün
  DayStats? get leastProductiveDay {
    if (dailyStats.isEmpty) return null;
    final activeDays = dailyStats.where((d) => d.totalItems > 0).toList();
    if (activeDays.isEmpty) return null;
    return activeDays
        .reduce((a, b) => a.productivityScore < b.productivityScore ? a : b);
  }

  /// Haftalık streak (üst üste aktif gün sayısı)
  int get currentStreak {
    int streak = 0;
    for (int i = dailyStats.length - 1; i >= 0; i--) {
      if (dailyStats[i].totalCompleted > 0) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Performans seviyesi
  PerformanceLevel get performanceLevel {
    final score = averageProductivityScore;
    if (score >= 80) return PerformanceLevel.excellent;
    if (score >= 60) return PerformanceLevel.good;
    if (score >= 40) return PerformanceLevel.average;
    if (score >= 20) return PerformanceLevel.needsImprovement;
    return PerformanceLevel.poor;
  }
}

/// Performans seviyesi
enum PerformanceLevel {
  excellent,
  good,
  average,
  needsImprovement,
  poor,
}

extension PerformanceLevelExtension on PerformanceLevel {
  String get label {
    switch (this) {
      case PerformanceLevel.excellent:
        return 'Mükemmel!';
      case PerformanceLevel.good:
        return 'Çok İyi!';
      case PerformanceLevel.average:
        return 'İyi Gidiyor';
      case PerformanceLevel.needsImprovement:
        return 'Geliştirebilirsin';
      case PerformanceLevel.poor:
        return 'Hadi Başlayalım!';
    }
  }

  String get emoji {
    switch (this) {
      case PerformanceLevel.excellent:
        return '🏆';
      case PerformanceLevel.good:
        return '🌟';
      case PerformanceLevel.average:
        return '👍';
      case PerformanceLevel.needsImprovement:
        return '💪';
      case PerformanceLevel.poor:
        return '🚀';
    }
  }

  Color get color {
    switch (this) {
      case PerformanceLevel.excellent:
        return Colors.amber;
      case PerformanceLevel.good:
        return Colors.green;
      case PerformanceLevel.average:
        return Colors.blue;
      case PerformanceLevel.needsImprovement:
        return Colors.orange;
      case PerformanceLevel.poor:
        return Colors.grey;
    }
  }
}
