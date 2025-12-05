import 'package:flutter/material.dart';

/// Pomodoro durumları
enum PomodoroStatus {
  idle, // Başlamadı
  running, // Çalışıyor
  paused, // Duraklatıldı
  breakTime, // Mola zamanı
  completed, // Tamamlandı
}

/// Pomodoro tipi
enum PomodoroType {
  work, // Çalışma
  shortBreak, // Kısa mola
  longBreak, // Uzun mola
}

extension PomodoroTypeExtension on PomodoroType {
  String get label {
    switch (this) {
      case PomodoroType.work:
        return 'Odaklanma';
      case PomodoroType.shortBreak:
        return 'Kısa Mola';
      case PomodoroType.longBreak:
        return 'Uzun Mola';
    }
  }

  Color get color {
    switch (this) {
      case PomodoroType.work:
        return const Color(0xFFE57373); // Kırmızı
      case PomodoroType.shortBreak:
        return const Color(0xFF81C784); // Yeşil
      case PomodoroType.longBreak:
        return const Color(0xFF64B5F6); // Mavi
    }
  }

  IconData get icon {
    switch (this) {
      case PomodoroType.work:
        return Icons.work_outline;
      case PomodoroType.shortBreak:
        return Icons.coffee_outlined;
      case PomodoroType.longBreak:
        return Icons.self_improvement;
    }
  }
}

/// Pomodoro ayarları
class PomodoroSettings {
  final int workDuration; // Dakika
  final int shortBreakDuration;
  final int longBreakDuration;
  final int sessionsUntilLongBreak;
  final bool autoStartBreaks;
  final bool autoStartWork;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const PomodoroSettings({
    this.workDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.sessionsUntilLongBreak = 4,
    this.autoStartBreaks = false,
    this.autoStartWork = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  PomodoroSettings copyWith({
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? sessionsUntilLongBreak,
    bool? autoStartBreaks,
    bool? autoStartWork,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return PomodoroSettings(
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      sessionsUntilLongBreak:
          sessionsUntilLongBreak ?? this.sessionsUntilLongBreak,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartWork: autoStartWork ?? this.autoStartWork,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}

/// Pomodoro durumu
class PomodoroState {
  final PomodoroStatus status;
  final PomodoroType type;
  final int remainingSeconds;
  final int totalSeconds;
  final int completedSessions;
  final String? currentTaskId;
  final String? currentTaskTitle;
  final DateTime? startedAt;
  final PomodoroSettings settings;

  const PomodoroState({
    this.status = PomodoroStatus.idle,
    this.type = PomodoroType.work,
    this.remainingSeconds = 25 * 60,
    this.totalSeconds = 25 * 60,
    this.completedSessions = 0,
    this.currentTaskId,
    this.currentTaskTitle,
    this.startedAt,
    this.settings = const PomodoroSettings(),
  });

  /// İlerleme yüzdesi (0.0 - 1.0)
  double get progress {
    if (totalSeconds == 0) return 0;
    return 1 - (remainingSeconds / totalSeconds);
  }

  /// Kalan süre formatı (MM:SS)
  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Durum metni
  String get statusText {
    switch (status) {
      case PomodoroStatus.idle:
        return 'Başlamak için hazır';
      case PomodoroStatus.running:
        return type == PomodoroType.work ? 'Odaklan!' : 'Mola zamanı';
      case PomodoroStatus.paused:
        return 'Duraklatıldı';
      case PomodoroStatus.breakTime:
        return 'Mola zamanı!';
      case PomodoroStatus.completed:
        return 'Tebrikler! 🎉';
    }
  }

  PomodoroState copyWith({
    PomodoroStatus? status,
    PomodoroType? type,
    int? remainingSeconds,
    int? totalSeconds,
    int? completedSessions,
    String? currentTaskId,
    String? currentTaskTitle,
    DateTime? startedAt,
    PomodoroSettings? settings,
  }) {
    return PomodoroState(
      status: status ?? this.status,
      type: type ?? this.type,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      completedSessions: completedSessions ?? this.completedSessions,
      currentTaskId: currentTaskId ?? this.currentTaskId,
      currentTaskTitle: currentTaskTitle ?? this.currentTaskTitle,
      startedAt: startedAt ?? this.startedAt,
      settings: settings ?? this.settings,
    );
  }
}

/// Pomodoro oturum kaydı
class PomodoroSession {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final PomodoroType type;
  final int durationMinutes;
  final String? taskId;
  final String? taskTitle;
  final bool completed;

  PomodoroSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.durationMinutes,
    this.taskId,
    this.taskTitle,
    this.completed = true,
  });
}
