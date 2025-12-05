import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

/// Haftalık istatistik provider (basitleştirilmiş)
final simpleWeeklyStatsProvider = Provider<SimpleWeeklyStats>((ref) {
  // Örnek veri - gerçek uygulamada veritabanından çekilecek
  return SimpleWeeklyStats(
    dailyScores: [65, 80, 45, 90, 70, 30, 50],
    mostProductiveDay: 'Perşembe',
    averageScore: 61,
  );
});

class SimpleWeeklyStats {
  final List<double> dailyScores;
  final String mostProductiveDay;
  final int averageScore;

  SimpleWeeklyStats({
    required this.dailyScores,
    required this.mostProductiveDay,
    required this.averageScore,
  });
}

class WeeklyChartCard extends ConsumerWidget {
  const WeeklyChartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyStats = ref.watch(simpleWeeklyStatsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Haftalık Trend',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: isDark ? Colors.grey[800]! : Colors.white,
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '%${rod.toY.toInt()}',
                          TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = [
                            'Pzt',
                            'Sal',
                            'Çar',
                            'Per',
                            'Cum',
                            'Cmt',
                            'Paz'
                          ];
                          if (value.toInt() >= 0 &&
                              value.toInt() < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                days[value.toInt()],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  barGroups: _getBarGroups(weeklyStats, theme, isDark),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Özet bilgi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryItem(
                  label: 'En Verimli',
                  value: weeklyStats.mostProductiveDay,
                  icon: Icons.emoji_events,
                  color: Colors.amber,
                ),
                _SummaryItem(
                  label: 'Ortalama',
                  value: '%${weeklyStats.averageScore}',
                  icon: Icons.analytics,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups(
      SimpleWeeklyStats weeklyStats, ThemeData theme, bool isDark) {
    final today = DateTime.now().weekday - 1; // 0-6

    return List.generate(7, (index) {
      double score = 0;
      if (index < weeklyStats.dailyScores.length) {
        score = weeklyStats.dailyScores[index];
      }

      final isToday = index == today;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: score,
            width: 24,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: isToday
                  ? [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.7)
                    ]
                  : [Colors.grey[400]!, Colors.grey[300]!],
            ),
          ),
        ],
      );
    });
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
