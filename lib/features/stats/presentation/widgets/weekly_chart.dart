import 'package:flutter/material.dart';
import 'package:momo_ajanda/features/stats/models/weekly_stats.dart';

/// Haftalık bar grafiği
class WeeklyChart extends StatelessWidget {
  final List<DayStats> dailyStats;
  final double height;

  const WeeklyChart({
    super.key,
    required this.dailyStats,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final maxScore = dailyStats
        .map((d) => d.productivityScore)
        .fold(0, (a, b) => a > b ? a : b);
    final effectiveMax = maxScore > 0 ? maxScore : 100;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: dailyStats.map((day) {
          final barHeight =
              (day.productivityScore / effectiveMax) * (height - 40);
          final isToday = _isToday(day.date);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Skor
                  Text(
                    '${day.productivityScore}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    height: barHeight.clamp(4.0, height - 40),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: isToday
                            ? [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withOpacity(0.7),
                              ]
                            : [
                                Colors.grey.shade400,
                                Colors.grey.shade300,
                              ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Gün adı
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isToday
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      day.dayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                        color: isToday ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
