import 'package:flutter/material.dart';

/// Momo'nun ruh halleri
enum MomoMood {
  happy, // Mutlu - varsayılan
  excited, // Heyecanlı - görev tamamlandığında
  thinking, // Düşünceli - öneri verirken
  sleeping, // Uyuyor - gece saatlerinde
  proud, // Gururlu - hedef tamamlandığında
  worried, // Endişeli - gecikmiş görev varken
  greeting, // Selamlama - uygulama açılışında
}

/// Momo'nun durumunu temsil eden sınıf
class MomoState {
  final MomoMood mood;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final DateTime timestamp;

  MomoState({
    required this.mood,
    required this.message,
    this.actionLabel,
    this.onAction,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Ruh haline göre emoji döndürür
  String get moodEmoji {
    switch (mood) {
      case MomoMood.happy:
        return '😊';
      case MomoMood.excited:
        return '🎉';
      case MomoMood.thinking:
        return '🤔';
      case MomoMood.sleeping:
        return '😴';
      case MomoMood.proud:
        return '🌟';
      case MomoMood.worried:
        return '😟';
      case MomoMood.greeting:
        return '👋';
    }
  }

  /// Ruh haline göre avatar rengi
  Color get moodColor {
    switch (mood) {
      case MomoMood.happy:
        return Colors.amber;
      case MomoMood.excited:
        return Colors.orange;
      case MomoMood.thinking:
        return Colors.blue;
      case MomoMood.sleeping:
        return Colors.indigo;
      case MomoMood.proud:
        return Colors.purple;
      case MomoMood.worried:
        return Colors.red.shade300;
      case MomoMood.greeting:
        return Colors.teal;
    }
  }

  /// Ruh haline göre avatar arka plan gradienti
  List<Color> get moodGradient {
    switch (mood) {
      case MomoMood.happy:
        return [Colors.amber.shade300, Colors.orange.shade400];
      case MomoMood.excited:
        return [Colors.orange.shade300, Colors.deepOrange.shade400];
      case MomoMood.thinking:
        return [Colors.blue.shade300, Colors.indigo.shade400];
      case MomoMood.sleeping:
        return [Colors.indigo.shade300, Colors.purple.shade400];
      case MomoMood.proud:
        return [Colors.purple.shade300, Colors.pink.shade400];
      case MomoMood.worried:
        return [Colors.red.shade200, Colors.orange.shade300];
      case MomoMood.greeting:
        return [Colors.teal.shade300, Colors.green.shade400];
    }
  }

  /// Varsayılan karşılama durumu
  factory MomoState.greeting() {
    final hour = DateTime.now().hour;
    String greeting;
    MomoMood mood;

    if (hour >= 5 && hour < 12) {
      greeting = 'Günaydın! ☀️ Bugün harika şeyler başaracağız!';
      mood = MomoMood.greeting;
    } else if (hour >= 12 && hour < 18) {
      greeting = 'İyi günler! 🌤️ Enerjin yerinde mi?';
      mood = MomoMood.happy;
    } else if (hour >= 18 && hour < 22) {
      greeting = 'İyi akşamlar! 🌆 Günü nasıl geçirdin?';
      mood = MomoMood.thinking;
    } else {
      greeting = 'Geç saatlere kadar çalışıyorsun! 🌙 Biraz dinlenmeyi unutma.';
      mood = MomoMood.sleeping;
    }

    return MomoState(mood: mood, message: greeting);
  }

  /// Kopyalama metodu
  MomoState copyWith({
    MomoMood? mood,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return MomoState(
      mood: mood ?? this.mood,
      message: message ?? this.message,
      actionLabel: actionLabel ?? this.actionLabel,
      onAction: onAction ?? this.onAction,
    );
  }
}

/// Günlük özet bilgileri
class DailySummary {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int overdueTasks;
  final int todayReminders;
  final int completedReminders;

  DailySummary({
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.pendingTasks = 0,
    this.overdueTasks = 0,
    this.todayReminders = 0,
    this.completedReminders = 0,
  });

  /// Tamamlanma yüzdesi
  double get completionRate {
    if (totalTasks == 0) return 0;
    return completedTasks / totalTasks;
  }

  /// Bugün yapılacak toplam iş
  int get todayTotal => pendingTasks + todayReminders;

  /// Özet mesajı oluştur
  String get summaryMessage {
    if (totalTasks == 0 && todayReminders == 0) {
      return 'Bugün için planlanmış bir şey yok. Yeni görev eklemek ister misin?';
    }

    final buffer = StringBuffer();

    if (pendingTasks > 0) {
      buffer.write('$pendingTasks bekleyen görevin');
    }

    if (todayReminders > 0) {
      if (buffer.isNotEmpty) buffer.write(' ve ');
      buffer.write('$todayReminders hatırlatıcın');
    }

    buffer.write(' var.');

    if (overdueTasks > 0) {
      buffer.write(' ⚠️ $overdueTasks görev gecikmiş!');
    }

    if (completedTasks > 0) {
      buffer.write(' 🎯 Bugün $completedTasks görevi tamamladın!');
    }

    return buffer.toString();
  }
}
