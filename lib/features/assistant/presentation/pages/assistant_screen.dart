import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:momo_ajanda/features/assistant/presentation/widgets/momo/momo_enums.dart';
import 'package:momo_ajanda/features/assistant/presentation/widgets/momo/momo_actor.dart';
import 'package:momo_ajanda/features/assistant/presentation/widgets/momo/momo_painter.dart';
import 'package:momo_ajanda/features/tasks/application/task_providers.dart';
import 'package:momo_ajanda/features/reminders/application/reminder_providers.dart';

final momoMoodProvider = StateProvider<MomoMood>((ref) => MomoMood.idle);
final momoIntensityProvider = StateProvider<double>((ref) => 0.5);

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  bool _isSpeaking = false;
  double _audioLevel = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMomoState();
    });
  }

  void _updateMomoState() {
    final hour = DateTime.now().hour;
    final tasksAsync = ref.read(tasksProvider);
    final remindersAsync = ref.read(remindersProvider);

    final completedTasks = tasksAsync.maybeWhen(
      data: (tasks) => tasks.where((t) => t.isCompleted).length,
      orElse: () => 0,
    );
    final totalTasks = tasksAsync.maybeWhen(
      data: (tasks) => tasks.length,
      orElse: () => 0,
    );
    final overdueReminders = remindersAsync.maybeWhen(
      data: (reminders) => reminders.where((r) => r.isOverdue).length,
      orElse: () => 0,
    );

    MomoMood mood;
    double intensity = 0.5;

    if (hour >= 22 || hour < 6) {
      mood = MomoMood.idle;
      intensity = 0.3;
    } else if (overdueReminders > 0) {
      mood = MomoMood.sad;
      intensity = 0.7;
    } else if (totalTasks > 0 && completedTasks == totalTasks) {
      mood = MomoMood.celebrate;
      intensity = 1.0;
    } else if (hour >= 6 && hour < 12) {
      mood = MomoMood.happy;
      intensity = 0.6;
    } else if (hour >= 12 && hour < 18) {
      mood = MomoMood.idle;
      intensity = 0.5;
    } else {
      mood = MomoMood.thinking;
      intensity = 0.5;
    }

    ref.read(momoMoodProvider.notifier).state = mood;
    ref.read(momoIntensityProvider.notifier).state = intensity;
  }

  void _simulateAudioInput() {
    if (!_isSpeaking) return;
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _isSpeaking) {
        setState(() => _audioLevel = math.Random().nextDouble());
        _simulateAudioInput();
      }
    });
  }

  void _handleMomoTap() {
    final currentMood = ref.read(momoMoodProvider);
    if (currentMood == MomoMood.listening) return;

    if (currentMood == MomoMood.angry) {
      ref.read(momoIntensityProvider.notifier).state = 1.0;
    } else {
      ref.read(momoMoodProvider.notifier).state = MomoMood.happy;
      ref.read(momoIntensityProvider.notifier).state = 0.8;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mood = ref.watch(momoMoodProvider);
    final intensity = ref.watch(momoIntensityProvider);

    Color targetBg = Color.lerp(Colors.white, mood.bgColor, 0.3 + intensity * 0.7)!;

    return Scaffold(
      backgroundColor: targetBg,
      body: Stack(
        children: [
          // Arka plan
          Positioned.fill(
            child: CustomPaint(
              painter: AdvancedBackgroundPainter(
                color: mood.accentColor,
                intensity: intensity,
                isListening: mood == MomoMood.listening,
              ),
            ),
          ),

          // Momo karakteri
          Center(
            child: MomoActor(
              mood: mood,
              intensity: intensity,
              isSpeaking: _isSpeaking,
              simulatedAudioLevel: _audioLevel,
              onTap: _handleMomoTap,
            ),
          ),

          // Kontrol paneli
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildControlPanel(mood, intensity),
          ),

          // Mikrofon butonu
          Positioned(
            top: 50,
            right: 20,
            child: FloatingActionButton.small(
              backgroundColor: _isSpeaking ? Colors.red : Colors.blue,
              child: Icon(_isSpeaking ? Icons.mic_off : Icons.mic),
              onPressed: () {
                setState(() {
                  _isSpeaking = !_isSpeaking;
                  if (_isSpeaking) {
                    ref.read(momoMoodProvider.notifier).state = MomoMood.listening;
                    _simulateAudioInput();
                  } else {
                    ref.read(momoMoodProvider.notifier).state = MomoMood.idle;
                    _audioLevel = 0.0;
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(MomoMood currentMood, double currentIntensity) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Yoğunluk slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "YOĞUNLUK: %${(currentIntensity * 100).toInt()}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              SizedBox(
                width: 150,
                child: Slider(
                  value: currentIntensity,
                  min: 0.0,
                  max: 1.0,
                  activeColor: currentMood.accentColor,
                  onChanged: (v) {
                    ref.read(momoIntensityProvider.notifier).state = v;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Mood butonları
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: MomoMood.values.map((m) {
              bool active = m == currentMood;
              return GestureDetector(
                onTap: () {
                  ref.read(momoMoodProvider.notifier).state = m;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? m.accentColor : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: m.accentColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    m.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: active ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
