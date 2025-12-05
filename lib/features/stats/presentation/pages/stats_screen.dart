import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:momo_ajanda/features/stats/application/stats_providers.dart';
import 'package:momo_ajanda/features/stats/presentation/widgets/weekly_chart.dart';
import 'package:momo_ajanda/features/stats/presentation/widgets/stat_card.dart';
import 'package:momo_ajanda/features/stats/presentation/widgets/performance_summary.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyStats = ref.watch(weeklyStatsProvider);
    final dateFormatter = DateFormat('d MMM', 'tr_TR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Haftalık Rapor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Paylaşım özelliği yakında!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarih aralığı
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${dateFormatter.format(weeklyStats.weekStart)} - ${dateFormatter.format(weeklyStats.weekEnd)}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Performans özeti
            PerformanceSummary(stats: weeklyStats),
            const SizedBox(height: 24),

            // Haftalık grafik
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Günlük Performans',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    WeeklyChart(dailyStats: weeklyStats.dailyStats),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // İstatistik kartları
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Tamamlanan',
                    value: '${weeklyStats.totalTasksCompleted}',
                    subtitle: 'görev',
                    icon: Icons.task_alt,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Bekleyen',
                    value:
                        '${weeklyStats.totalTasks - weeklyStats.totalTasksCompleted}',
                    subtitle: 'görev',
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // İlerleme kartları
            ProgressStatCard(
              title: 'Görev Tamamlama',
              completed: weeklyStats.totalTasksCompleted,
              total: weeklyStats.totalTasks,
              icon: Icons.check_circle_outline,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            ProgressStatCard(
              title: 'Hatırlatıcılar',
              completed: weeklyStats.totalRemindersCompleted,
              total: weeklyStats.totalReminders,
              icon: Icons.notifications_active,
              color: Colors.purple,
            ),
            const SizedBox(height: 24),

            // En verimli gün
            if (weeklyStats.mostProductiveDay != null) ...[
              _InsightCard(
                icon: Icons.emoji_events,
                iconColor: Colors.amber,
                title: 'En Verimli Gün',
                content: _formatDayName(weeklyStats.mostProductiveDay!.date),
                subtitle:
                    '${weeklyStats.mostProductiveDay!.productivityScore} puan',
              ),
              const SizedBox(height: 12),
            ],

            // Motivasyon mesajı
            _MotivationCard(stats: weeklyStats),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatDayName(DateTime date) {
    final formatter = DateFormat('EEEE', 'tr_TR');
    return formatter.format(date);
  }
}

/// İçgörü kartı
class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;
  final String? subtitle;

  const _InsightCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: iconColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Motivasyon kartı
class _MotivationCard extends StatelessWidget {
  final dynamic stats;

  const _MotivationCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    String message;
    String emoji;

    final completionRate = stats.weeklyCompletionRate;

    if (completionRate >= 0.8) {
      message = 'Bu hafta muhteşem bir performans sergidin! Böyle devam! 🚀';
      emoji = '🏆';
    } else if (completionRate >= 0.6) {
      message =
          'Harika gidiyorsun! Biraz daha gayret ile zirveye ulaşabilirsin!';
      emoji = '💪';
    } else if (completionRate >= 0.4) {
      message = 'İyi bir başlangıç! Her gün biraz daha ilerleyebilirsin.';
      emoji = '🌱';
    } else if (completionRate > 0) {
      message = 'Adım adım ilerliyorsun. Küçük adımlar büyük sonuçlar doğurur!';
      emoji = '👣';
    } else {
      message = 'Yeni bir hafta, yeni fırsatlar! Haydi başlayalım!';
      emoji = '🌟';
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
