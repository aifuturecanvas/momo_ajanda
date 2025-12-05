import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/features/pomodoro/application/pomodoro_providers.dart';
import 'package:momo_ajanda/features/pomodoro/models/pomodoro_state.dart';
import 'package:momo_ajanda/features/pomodoro/presentation/widgets/timer_display.dart';
import 'package:momo_ajanda/features/pomodoro/presentation/widgets/session_indicator.dart';
import 'package:momo_ajanda/features/tasks/application/task_providers.dart';

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoroState = ref.watch(pomodoroProvider);
    final settings = ref.watch(pomodoroSettingsProvider);
    final todaySessions = ref.watch(todaySessionsProvider);
    final totalFocusTime = ref.watch(totalFocusTimeProvider);

    return Scaffold(
      backgroundColor: pomodoroState.type.color.withOpacity(0.05),
      appBar: AppBar(
        title: const Text('Odaklanma Modu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: pomodoroState.type.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsSheet(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Oturum göstergesi
            SessionIndicator(
              completedSessions: pomodoroState.completedSessions,
              sessionsUntilLongBreak: settings.sessionsUntilLongBreak,
            ),
            const SizedBox(height: 8),
            Text(
              '${pomodoroState.completedSessions} oturum tamamlandı',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),

            const Spacer(),

            // Zamanlayıcı
            TimerDisplay(state: pomodoroState),

            const SizedBox(height: 24),

            // Görev bilgisi
            if (pomodoroState.currentTaskTitle != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.task_alt,
                      color: pomodoroState.type.color,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        pomodoroState.currentTaskTitle!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        ref.read(pomodoroProvider.notifier).clearTask();
                      },
                    ),
                  ],
                ),
              )
            else
              TextButton.icon(
                onPressed: () => _showTaskSelector(context, ref),
                icon: const Icon(Icons.add_task),
                label: const Text('Görev Seç'),
              ),

            const Spacer(),

            // Kontrol butonları
            _ControlButtons(state: pomodoroState),

            const SizedBox(height: 24),

            // Özet kartı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SessionSummaryCard(
                todaySessions: todaySessions,
                totalFocusMinutes: totalFocusTime,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showTaskSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TaskSelectorSheet(),
    );
  }

  void _showSettingsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SettingsSheet(),
    );
  }
}

/// Kontrol butonları
class _ControlButtons extends ConsumerWidget {
  final PomodoroState state;

  const _ControlButtons({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(pomodoroProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Durdur butonu
        if (state.status != PomodoroStatus.idle)
          _CircleButton(
            icon: Icons.stop,
            color: Colors.grey,
            onPressed: notifier.stop,
            size: 56,
          ),

        const SizedBox(width: 16),

        // Ana buton (Başlat/Duraklat/Devam)
        _CircleButton(
          icon: _getMainButtonIcon(),
          color: state.type.color,
          onPressed: () => _onMainButtonPressed(notifier),
          size: 80,
          isPrimary: true,
        ),

        const SizedBox(width: 16),

        // Atla butonu
        if (state.status == PomodoroStatus.running ||
            state.status == PomodoroStatus.paused)
          _CircleButton(
            icon: Icons.skip_next,
            color: Colors.grey,
            onPressed: () => _skipCurrent(notifier),
            size: 56,
          ),
      ],
    );
  }

  IconData _getMainButtonIcon() {
    switch (state.status) {
      case PomodoroStatus.idle:
      case PomodoroStatus.completed:
        return Icons.play_arrow;
      case PomodoroStatus.running:
        return Icons.pause;
      case PomodoroStatus.paused:
        return Icons.play_arrow;
      case PomodoroStatus.breakTime:
        return Icons.play_arrow;
    }
  }

  void _onMainButtonPressed(PomodoroNotifier notifier) {
    switch (state.status) {
      case PomodoroStatus.idle:
      case PomodoroStatus.completed:
        notifier.start();
        break;
      case PomodoroStatus.running:
        notifier.pause();
        break;
      case PomodoroStatus.paused:
        notifier.resume();
        break;
      case PomodoroStatus.breakTime:
        notifier.start();
        break;
    }
  }

  void _skipCurrent(PomodoroNotifier notifier) {
    if (state.type == PomodoroType.work) {
      notifier.startShortBreak();
    } else {
      notifier.startWork(
        taskId: state.currentTaskId,
        taskTitle: state.currentTaskTitle,
      );
    }
  }
}

/// Dairesel buton
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final double size;
  final bool isPrimary;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.size,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? color : color.withOpacity(0.1),
      shape: const CircleBorder(),
      elevation: isPrimary ? 4 : 0,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            color: isPrimary ? Colors.white : color,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}

/// Görev seçici
class _TaskSelectorSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Görev Seç',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          tasksAsync.when(
            data: (tasks) {
              final pendingTasks = tasks.where((t) => !t.isCompleted).toList();

              if (pendingTasks.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('Bekleyen görev yok'),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: pendingTasks.length,
                itemBuilder: (context, index) {
                  final task = pendingTasks[index];
                  return ListTile(
                    leading: const Icon(Icons.task_alt),
                    title: Text(task.title),
                    subtitle: Text(task.category),
                    onTap: () {
                      ref.read(pomodoroProvider.notifier).selectTask(
                            task.id,
                            task.title,
                          );
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Hata oluştu')),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Ayarlar sheet'i
class _SettingsSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends ConsumerState<_SettingsSheet> {
  late int _workDuration;
  late int _shortBreakDuration;
  late int _longBreakDuration;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(pomodoroSettingsProvider);
    _workDuration = settings.workDuration;
    _shortBreakDuration = settings.shortBreakDuration;
    _longBreakDuration = settings.longBreakDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zamanlayıcı Ayarları',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          _DurationSlider(
            label: 'Odaklanma Süresi',
            value: _workDuration,
            min: 5,
            max: 60,
            color: Colors.red.shade400,
            onChanged: (value) => setState(() => _workDuration = value),
          ),
          _DurationSlider(
            label: 'Kısa Mola',
            value: _shortBreakDuration,
            min: 1,
            max: 15,
            color: Colors.green.shade400,
            onChanged: (value) => setState(() => _shortBreakDuration = value),
          ),
          _DurationSlider(
            label: 'Uzun Mola',
            value: _longBreakDuration,
            min: 5,
            max: 30,
            color: Colors.blue.shade400,
            onChanged: (value) => setState(() => _longBreakDuration = value),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(pomodoroSettingsProvider.notifier).state =
                    PomodoroSettings(
                  workDuration: _workDuration,
                  shortBreakDuration: _shortBreakDuration,
                  longBreakDuration: _longBreakDuration,
                );
                ref.read(pomodoroProvider.notifier).stop();
                Navigator.pop(context);
              },
              child: const Text('Kaydet'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationSlider extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final Color color;
  final ValueChanged<int> onChanged;

  const _DurationSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              '$value dk',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          activeColor: color,
          onChanged: (v) => onChanged(v.toInt()),
        ),
      ],
    );
  }
}
