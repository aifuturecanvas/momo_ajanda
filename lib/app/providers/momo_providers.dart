import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/features/tasks/application/task_providers.dart';

// Momo'nun ruh halini temsil eden enum.
enum MomoMood { celebrating, happy, neutral, sad }

// Momo'nun ruh halini görev istatistiklerine göre belirleyen provider.
final momoMoodProvider = Provider<MomoMood>((ref) {
  // Görev istatistiklerini dinle.
  final stats = ref.watch(taskStatsProvider);

  // Tamamlanma yüzdesine göre ruh halini belirle.
  final percentage = stats.completionPercentage;

  if (stats.totalTasks > 0 && percentage == 1.0) {
    return MomoMood.celebrating; // Tüm görevler bittiyse kutlama!
  } else if (percentage >= 0.5) {
    return MomoMood.happy; // Yarısından fazlası bittiyse mutlu.
  } else if (percentage > 0) {
    return MomoMood.neutral; // En az bir görev bittiyse normal.
  } else {
    return MomoMood.sad; // Hiç görev bitmediyse üzgün.
  }
});
