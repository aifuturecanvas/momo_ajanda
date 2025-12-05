import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/features/assistant/models/momo_state.dart';
import 'package:momo_ajanda/features/tasks/application/task_providers.dart';
import 'package:momo_ajanda/features/reminders/application/reminder_providers.dart';

/// Momo'nun mevcut durumunu yöneten provider
final momoStateProvider =
    StateNotifierProvider<MomoStateNotifier, MomoState>((ref) {
  return MomoStateNotifier(ref);
});

/// Günlük özet provider'ı
final dailySummaryProvider = Provider<DailySummary>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  final remindersAsync = ref.watch(remindersProvider);

  return tasksAsync.maybeWhen(
    data: (tasks) {
      final todayReminders = remindersAsync.maybeWhen(
        data: (reminders) {
          final now = DateTime.now();
          return reminders
              .where((r) =>
                  r.dateTime.year == now.year &&
                  r.dateTime.month == now.month &&
                  r.dateTime.day == now.day &&
                  !r.isCompleted)
              .length;
        },
        orElse: () => 0,
      );

      final completedReminders = remindersAsync.maybeWhen(
        data: (reminders) {
          final now = DateTime.now();
          return reminders
              .where((r) =>
                  r.dateTime.year == now.year &&
                  r.dateTime.month == now.month &&
                  r.dateTime.day == now.day &&
                  r.isCompleted)
              .length;
        },
        orElse: () => 0,
      );

      final totalTasks = tasks.length;
      final completedTasks = tasks.where((t) => t.isCompleted).length;
      final pendingTasks = tasks.where((t) => !t.isCompleted).length;
      final overdueTasks = tasks.where((t) => t.isOverdue).length;

      return DailySummary(
        totalTasks: totalTasks,
        completedTasks: completedTasks,
        pendingTasks: pendingTasks,
        overdueTasks: overdueTasks,
        todayReminders: todayReminders,
        completedReminders: completedReminders,
      );
    },
    orElse: () => DailySummary(),
  );
});

/// Motivasyon mesajları provider'ı
final motivationMessageProvider = Provider<String>((ref) {
  final summary = ref.watch(dailySummaryProvider);
  final hour = DateTime.now().hour;

  // Tüm görevler tamamlandıysa
  if (summary.totalTasks > 0 && summary.pendingTasks == 0) {
    return _celebrationMessages[
        DateTime.now().millisecond % _celebrationMessages.length];
  }

  // Gecikmiş görev varsa
  if (summary.overdueTasks > 0) {
    return _warningMessages[
        DateTime.now().millisecond % _warningMessages.length];
  }

  // Sabah motivasyonu
  if (hour >= 5 && hour < 12) {
    return _morningMessages[
        DateTime.now().millisecond % _morningMessages.length];
  }

  // Öğleden sonra
  if (hour >= 12 && hour < 18) {
    return _afternoonMessages[
        DateTime.now().millisecond % _afternoonMessages.length];
  }

  // Akşam
  return _eveningMessages[DateTime.now().millisecond % _eveningMessages.length];
});

// Motivasyon mesajları
const _celebrationMessages = [
  'Harikasın! Tüm görevlerini tamamladın! 🎉',
  'Bugün çok üretken oldun! Gurur duyuyorum! 🌟',
  'Süpersin! Kendine bir ödül hak ettin! 🏆',
  'Tebrikler! Bugünün şampiyonu sensin! 🥇',
  'Muhteşem! Hedeflerine ulaştın! ✨',
];

const _warningMessages = [
  'Bazı görevlerin gecikmiş görünüyor. Birlikte halledelim! 💪',
  'Gecikmiş görevlerin var. Önce onlara odaklanalım mı? 🎯',
  'Hey! Birkaç görev seni bekliyor. Hadi başlayalım! 🚀',
];

const _morningMessages = [
  'Günaydın! Bugün harika şeyler başaracağız! ☀️',
  'Yeni bir gün, yeni fırsatlar! Hazır mısın? 🌅',
  'Güne enerjik başla! Seni destekliyorum! 💪',
  'Sabahın güzelliğiyle birlikte üretken bir gün olsun! 🌸',
];

const _afternoonMessages = [
  'Öğleden sonra enerjin nasıl? Devam edelim! ⚡',
  'Günün yarısı geçti, harika gidiyorsun! 🎯',
  'Biraz mola verip devam etmeye ne dersin? ☕',
  'Odaklanmaya devam! Başarıyorsun! 🏃',
];

const _eveningMessages = [
  'Akşam oldu, günü değerlendirelim mi? 🌆',
  'Bugün neler başardın? Birlikte bakalım! 📝',
  'Yorucu bir gün mü oldu? Biraz dinlen! 🌙',
  'Yarın için plan yapmaya ne dersin? 📅',
];

/// Momo State Notifier
class MomoStateNotifier extends StateNotifier<MomoState> {
  final Ref _ref;

  MomoStateNotifier(this._ref) : super(MomoState.greeting()) {
    // İlk yüklemede durumu güncelle
    Future.microtask(() => updateMoodBasedOnContext());
  }

  /// Bağlama göre ruh halini güncelle
  void updateMoodBasedOnContext() {
    final summary = _ref.read(dailySummaryProvider);
    final hour = DateTime.now().hour;

    MomoMood newMood;
    String message;

    // Gece saatlerinde
    if (hour >= 23 || hour < 5) {
      newMood = MomoMood.sleeping;
      message = 'Geç saatlere kadar çalışıyorsun! Biraz dinlenmeyi unutma. 🌙';
    }
    // Tüm görevler tamamlandıysa
    else if (summary.totalTasks > 0 && summary.pendingTasks == 0) {
      newMood = MomoMood.proud;
      message = 'Tebrikler! Tüm görevlerini tamamladın! 🏆';
    }
    // Gecikmiş görev varsa
    else if (summary.overdueTasks > 0) {
      newMood = MomoMood.worried;
      message =
          '${summary.overdueTasks} gecikmiş görevin var. Birlikte halledelim! 💪';
    }
    // Normal durum
    else {
      newMood = MomoMood.happy;
      message = summary.summaryMessage;
    }

    state = MomoState(mood: newMood, message: message);
  }

  /// Görev tamamlandığında kutlama
  void celebrateTaskCompletion(String taskTitle) {
    state = MomoState(
      mood: MomoMood.excited,
      message: '"$taskTitle" tamamlandı! Harika iş! 🎉',
    );

    // 3 saniye sonra normal duruma dön
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) updateMoodBasedOnContext();
    });
  }

  /// Yeni görev eklendiğinde
  void onTaskAdded(String taskTitle) {
    state = MomoState(
      mood: MomoMood.happy,
      message: '"$taskTitle" eklendi! Başarılar! ✨',
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) updateMoodBasedOnContext();
    });
  }

  /// Hatırlatıcı zamanı geldiğinde
  void onReminderDue(String reminderTitle) {
    state = MomoState(
      mood: MomoMood.thinking,
      message: '⏰ Hatırlatma: $reminderTitle',
      actionLabel: 'Tamam',
      onAction: () => updateMoodBasedOnContext(),
    );
  }

  /// Özel mesaj göster
  void showMessage(String message, {MomoMood mood = MomoMood.happy}) {
    state = MomoState(mood: mood, message: message);
  }

  /// Düşünme moduna geç (öneri verirken)
  void startThinking() {
    state = MomoState(
      mood: MomoMood.thinking,
      message: 'Düşünüyorum... 🤔',
    );
  }
}
