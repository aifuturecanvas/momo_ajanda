import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/features/pomodoro/models/pomodoro_state.dart';

/// Pomodoro ayarları provider'ı
final pomodoroSettingsProvider = StateProvider<PomodoroSettings>((ref) {
  return const PomodoroSettings();
});

/// Pomodoro state provider'ı
final pomodoroProvider =
    StateNotifierProvider<PomodoroNotifier, PomodoroState>((ref) {
  final settings = ref.watch(pomodoroSettingsProvider);
  return PomodoroNotifier(settings);
});

/// Bugünkü tamamlanan oturum sayısı
final todaySessionsProvider = StateProvider<int>((ref) => 0);

/// Toplam odaklanma süresi (dakika)
final totalFocusTimeProvider = StateProvider<int>((ref) => 0);

class PomodoroNotifier extends StateNotifier<PomodoroState> {
  Timer? _timer;
  final PomodoroSettings _settings;

  PomodoroNotifier(this._settings)
      : super(PomodoroState(
          settings: _settings,
          remainingSeconds: _settings.workDuration * 60,
          totalSeconds: _settings.workDuration * 60,
        ));

  /// Zamanlayıcıyı başlat
  void start({String? taskId, String? taskTitle}) {
    if (state.status == PomodoroStatus.running) return;

    state = state.copyWith(
      status: PomodoroStatus.running,
      currentTaskId: taskId ?? state.currentTaskId,
      currentTaskTitle: taskTitle ?? state.currentTaskTitle,
      startedAt: DateTime.now(),
    );

    _startTimer();
  }

  /// Zamanlayıcıyı duraklat
  void pause() {
    if (state.status != PomodoroStatus.running) return;

    _timer?.cancel();
    state = state.copyWith(status: PomodoroStatus.paused);
  }

  /// Zamanlayıcıyı devam ettir
  void resume() {
    if (state.status != PomodoroStatus.paused) return;

    state = state.copyWith(status: PomodoroStatus.running);
    _startTimer();
  }

  /// Zamanlayıcıyı durdur ve sıfırla
  void stop() {
    _timer?.cancel();

    final duration = state.type == PomodoroType.work
        ? _settings.workDuration
        : state.type == PomodoroType.shortBreak
            ? _settings.shortBreakDuration
            : _settings.longBreakDuration;

    state = PomodoroState(
      settings: _settings,
      remainingSeconds: duration * 60,
      totalSeconds: duration * 60,
      completedSessions: state.completedSessions,
    );
  }

  /// Çalışma modunu başlat
  void startWork({String? taskId, String? taskTitle}) {
    _timer?.cancel();

    state = PomodoroState(
      settings: _settings,
      type: PomodoroType.work,
      remainingSeconds: _settings.workDuration * 60,
      totalSeconds: _settings.workDuration * 60,
      completedSessions: state.completedSessions,
      currentTaskId: taskId,
      currentTaskTitle: taskTitle,
    );
  }

  /// Kısa mola başlat
  void startShortBreak() {
    _timer?.cancel();

    state = state.copyWith(
      status: PomodoroStatus.idle,
      type: PomodoroType.shortBreak,
      remainingSeconds: _settings.shortBreakDuration * 60,
      totalSeconds: _settings.shortBreakDuration * 60,
    );

    if (_settings.autoStartBreaks) {
      start();
    }
  }

  /// Uzun mola başlat
  void startLongBreak() {
    _timer?.cancel();

    state = state.copyWith(
      status: PomodoroStatus.idle,
      type: PomodoroType.longBreak,
      remainingSeconds: _settings.longBreakDuration * 60,
      totalSeconds: _settings.longBreakDuration * 60,
    );

    if (_settings.autoStartBreaks) {
      start();
    }
  }

  /// Görev seç
  void selectTask(String taskId, String taskTitle) {
    state = state.copyWith(
      currentTaskId: taskId,
      currentTaskTitle: taskTitle,
    );
  }

  /// Görevi temizle
  void clearTask() {
    state = state.copyWith(
      currentTaskId: null,
      currentTaskTitle: null,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(
          remainingSeconds: state.remainingSeconds - 1,
        );
      } else {
        _onTimerComplete();
      }
    });
  }

  void _onTimerComplete() {
    _timer?.cancel();

    if (state.type == PomodoroType.work) {
      // Çalışma tamamlandı
      final newCompletedSessions = state.completedSessions + 1;

      state = state.copyWith(
        status: PomodoroStatus.completed,
        completedSessions: newCompletedSessions,
      );

      // Uzun mola mı kısa mola mı?
      Future.delayed(const Duration(seconds: 2), () {
        if (newCompletedSessions % _settings.sessionsUntilLongBreak == 0) {
          startLongBreak();
        } else {
          startShortBreak();
        }
      });
    } else {
      // Mola tamamlandı
      state = state.copyWith(status: PomodoroStatus.completed);

      Future.delayed(const Duration(seconds: 2), () {
        startWork(
          taskId: state.currentTaskId,
          taskTitle: state.currentTaskTitle,
        );

        if (_settings.autoStartWork) {
          start();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
