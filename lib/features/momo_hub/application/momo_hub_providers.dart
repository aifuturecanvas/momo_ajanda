import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/features/momo_hub/models/momo_suggestion.dart';
import 'package:momo_ajanda/features/tasks/application/task_providers.dart';
import 'package:momo_ajanda/features/reminders/application/reminder_providers.dart';
import 'package:momo_ajanda/features/stats/application/stats_providers.dart';
import 'package:momo_ajanda/features/assistant/presentation/widgets/momo/momo_enums.dart';

/// Momo Hub durumu
class MomoHubState {
  final MomoMood mood;
  final double intensity;
  final String message;
  final List<MomoSuggestion> suggestions;
  final bool isListening;
  final String lastCommand;

  MomoHubState({
    this.mood = MomoMood.idle,
    this.intensity = 0.5,
    this.message = '',
    this.suggestions = const [],
    this.isListening = false,
    this.lastCommand = '',
  });

  MomoHubState copyWith({
    MomoMood? mood,
    double? intensity,
    String? message,
    List<MomoSuggestion>? suggestions,
    bool? isListening,
    String? lastCommand,
  }) {
    return MomoHubState(
      mood: mood ?? this.mood,
      intensity: intensity ?? this.intensity,
      message: message ?? this.message,
      suggestions: suggestions ?? this.suggestions,
      isListening: isListening ?? this.isListening,
      lastCommand: lastCommand ?? this.lastCommand,
    );
  }
}

/// Momo Hub provider
final momoHubProvider =
    StateNotifierProvider<MomoHubNotifier, MomoHubState>((ref) {
  return MomoHubNotifier(ref);
});

class MomoHubNotifier extends StateNotifier<MomoHubState> {
  final Ref _ref;

  MomoHubNotifier(this._ref) : super(MomoHubState()) {
    _initialize();
  }

  void _initialize() {
    updateMomoState();
  }

  /// Momo durumunu güncelle
  void updateMomoState() {
    final hour = DateTime.now().hour;
    final tasksAsync = _ref.read(tasksProvider);
    final remindersAsync = _ref.read(remindersProvider);

    // İstatistikleri hesapla
    int totalTasks = 0;
    int completedTasks = 0;
    int pendingTasks = 0;
    int overdueReminders = 0;
    int todayReminders = 0;

    tasksAsync.whenData((tasks) {
      totalTasks = tasks.length;
      completedTasks = tasks.where((t) => t.isCompleted).length;
      pendingTasks = totalTasks - completedTasks;
    });

    remindersAsync.whenData((reminders) {
      overdueReminders = reminders.where((r) => r.isOverdue).length;
      final now = DateTime.now();
      todayReminders = reminders
          .where((r) =>
              r.dateTime.year == now.year &&
              r.dateTime.month == now.month &&
              r.dateTime.day == now.day &&
              !r.isCompleted)
          .length;
    });

    // Mood ve mesaj belirle
    MomoMood mood;
    double intensity;
    String message;

    if (hour >= 23 || hour < 6) {
      mood = MomoMood.idle;
      intensity = 0.3;
      message = 'Geç saatlerde çalışıyorsun, dinlenmeyi unutma! 🌙';
    } else if (overdueReminders > 0) {
      mood = MomoMood.sad;
      intensity = 0.7;
      message = '$overdueReminders gecikmiş hatırlatıcın var 😟';
    } else if (totalTasks > 0 && completedTasks == totalTasks) {
      mood = MomoMood.celebrate;
      intensity = 1.0;
      message = 'Tebrikler! Tüm görevlerini tamamladın! 🎉';
    } else if (hour >= 6 && hour < 12) {
      mood = MomoMood.happy;
      intensity = 0.6;
      message = _getMorningMessage(pendingTasks, todayReminders);
    } else if (hour >= 12 && hour < 18) {
      mood = MomoMood.idle;
      intensity = 0.5;
      message = _getAfternoonMessage(pendingTasks, completedTasks);
    } else {
      mood = MomoMood.thinking;
      intensity = 0.5;
      message = _getEveningMessage(pendingTasks);
    }

    // Önerileri oluştur
    final suggestions = _generateSuggestions(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      pendingTasks: pendingTasks,
      overdueReminders: overdueReminders,
      todayReminders: todayReminders,
    );

    state = state.copyWith(
      mood: mood,
      intensity: intensity,
      message: message,
      suggestions: suggestions,
    );
  }

  String _getMorningMessage(int pendingTasks, int todayReminders) {
    if (pendingTasks == 0 && todayReminders == 0) {
      return 'Günaydın! Bugün için plan yapmaya ne dersin? ☀️';
    } else if (pendingTasks > 0) {
      return 'Günaydın! Bugün $pendingTasks görev seni bekliyor! 💪';
    } else {
      return 'Günaydın! $todayReminders hatırlatıcın var bugün! 📅';
    }
  }

  String _getAfternoonMessage(int pendingTasks, int completedTasks) {
    if (completedTasks > 0 && pendingTasks == 0) {
      return 'Harika gidiyorsun! Tüm işler tamam! ✨';
    } else if (completedTasks > 0) {
      return '$completedTasks görev tamamlandı, $pendingTasks kaldı! 🎯';
    } else if (pendingTasks > 0) {
      return 'Henüz başlamadın, hadi biraz çalışalım! 💼';
    }
    return 'Öğleden sonra nasıl geçiyor? 😊';
  }

  String _getEveningMessage(int pendingTasks) {
    if (pendingTasks == 0) {
      return 'Günü başarıyla tamamladın! İyi akşamlar! 🌆';
    } else if (pendingTasks <= 2) {
      return 'Neredeyse bitti! Son $pendingTasks görevi de halledelim! 💪';
    }
    return '$pendingTasks görev kaldı. Yarına erteleyelim mi? 🤔';
  }

  List<MomoSuggestion> _generateSuggestions({
    required int totalTasks,
    required int completedTasks,
    required int pendingTasks,
    required int overdueReminders,
    required int todayReminders,
  }) {
    final suggestions = <MomoSuggestion>[];
    final now = DateTime.now();

    // Gecikmiş hatırlatıcı varsa
    if (overdueReminders > 0) {
      suggestions.add(MomoSuggestion(
        id: 'overdue_reminders',
        message: '$overdueReminders gecikmiş hatırlatıcın var!',
        actionLabel: 'Göster',
        type: SuggestionType.warning,
        priority: SuggestionPriority.high,
      ));
    }

    // Bugün görev yoksa
    if (totalTasks == 0 && now.hour < 20) {
      suggestions.add(MomoSuggestion(
        id: 'no_tasks',
        message: 'Bugün için görev eklememişsin, başlayalım mı?',
        actionLabel: 'Görev Ekle',
        type: SuggestionType.tip,
        priority: SuggestionPriority.medium,
      ));
    }

    // Tüm görevler tamamlandıysa
    if (totalTasks > 0 && completedTasks == totalTasks) {
      suggestions.add(MomoSuggestion(
        id: 'all_completed',
        message: 'Muhteşem! Tüm görevlerini tamamladın! 🎉',
        type: SuggestionType.celebration,
        priority: SuggestionPriority.high,
      ));
    }

    // Çok fazla bekleyen görev varsa
    if (pendingTasks > 5) {
      suggestions.add(MomoSuggestion(
        id: 'many_pending',
        message:
            '$pendingTasks bekleyen görev var, önceliklendirmeni öneriyorum.',
        actionLabel: 'Önceliklendir',
        type: SuggestionType.task,
        priority: SuggestionPriority.medium,
      ));
    }

    // Akşam saati ve bekleyen görev varsa
    if (now.hour >= 20 && pendingTasks > 0) {
      suggestions.add(MomoSuggestion(
        id: 'late_pending',
        message: 'Geç oldu, $pendingTasks görevi yarına erteleyelim mi?',
        actionLabel: 'Ertele',
        type: SuggestionType.tip,
        priority: SuggestionPriority.low,
      ));
    }

    // Motivasyon mesajı
    if (completedTasks > 0 && completedTasks < totalTasks) {
      final percentage = ((completedTasks / totalTasks) * 100).toInt();
      suggestions.add(MomoSuggestion(
        id: 'progress',
        message: '%$percentage tamamlandı, devam et! 💪',
        type: SuggestionType.motivation,
        priority: SuggestionPriority.low,
      ));
    }

    return suggestions;
  }

  void setMood(MomoMood mood) {
    state = state.copyWith(mood: mood);
  }

  void setIntensity(double intensity) {
    state = state.copyWith(intensity: intensity);
  }

  void setListening(bool isListening) {
    state = state.copyWith(isListening: isListening);
  }

  void setLastCommand(String command) {
    state = state.copyWith(lastCommand: command);
  }

  void dismissSuggestion(String id) {
    final updated = state.suggestions
        .map((s) {
          if (s.id == id) {
            s.isDismissed = true;
          }
          return s;
        })
        .where((s) => !s.isDismissed)
        .toList();
    state = state.copyWith(suggestions: updated);
  }
}

/// Günlük istatistikler provider
final dailyStatsProvider = Provider<DailyStats>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  final remindersAsync = ref.watch(remindersProvider);

  int totalTasks = 0;
  int completedTasks = 0;
  int totalReminders = 0;
  int completedReminders = 0;

  tasksAsync.whenData((tasks) {
    final today = DateTime.now();
    final todayTasks = tasks
        .where((t) =>
            t.dueDate?.year == today.year &&
            t.dueDate?.month == today.month &&
            t.dueDate?.day == today.day)
        .toList();
    totalTasks = todayTasks.length;
    completedTasks = todayTasks.where((t) => t.isCompleted).length;
  });

  remindersAsync.whenData((reminders) {
    final today = DateTime.now();
    final todayReminders = reminders
        .where((r) =>
            r.dateTime.year == today.year &&
            r.dateTime.month == today.month &&
            r.dateTime.day == today.day)
        .toList();
    totalReminders = todayReminders.length;
    completedReminders = todayReminders.where((r) => r.isCompleted).length;
  });

  return DailyStats(
    totalTasks: totalTasks,
    completedTasks: completedTasks,
    totalReminders: totalReminders,
    completedReminders: completedReminders,
  );
});

class DailyStats {
  final int totalTasks;
  final int completedTasks;
  final int totalReminders;
  final int completedReminders;

  DailyStats({
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.totalReminders = 0,
    this.completedReminders = 0,
  });

  int get pendingTasks => totalTasks - completedTasks;
  int get pendingReminders => totalReminders - completedReminders;
  double get completionRate =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;
}
