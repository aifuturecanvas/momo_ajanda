import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/app/providers/momo_providers.dart';
import 'package:momo_ajanda/features/tasks/application/task_providers.dart';

// Widget'ı StatelessWidget'tan ConsumerWidget'a dönüştürüyoruz.
class DailySummaryCard extends ConsumerWidget {
  // Artık dışarıdan parametre almadığı için constructor'ı basitleştiriyoruz.
  const DailySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gerekli verileri provider'lardan dinliyoruz.
    final mood = ref.watch(momoMoodProvider);
    final stats = ref.watch(taskStatsProvider);

    // Ruh haline göre ikon, mesaj ve rengi belirliyoruz.
    final IconData icon;
    final String message;
    final Color color;

    switch (mood) {
      case MomoMood.celebrating:
        icon = Icons.celebration;
        message = 'Harika! Bütün görevlerini tamamladın!';
        color = Colors.orange;
        break;
      case MomoMood.happy:
        icon = Icons.sentiment_very_satisfied;
        message =
            'Çok iyi gidiyorsun! Bugün ${stats.completedTasks}/${stats.totalTasks} görev tamamlandı.';
        color = Colors.green;
        break;
      case MomoMood.neutral:
        icon = Icons.sentiment_neutral;
        message =
            'Haydi başlayalım! Seni bekleyen ${stats.totalTasks - stats.completedTasks} görev var.';
        color = Theme.of(context).primaryColor;
        break;
      case MomoMood.sad:
        icon = Icons.sentiment_dissatisfied;
        message =
            'Biraz mola mı? Sadece ${stats.completedTasks} görev tamamlandı.';
        color = Colors.grey;
        break;
    }

    return Card(
      color: color.withOpacity(0.1),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Merhaba!',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
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

