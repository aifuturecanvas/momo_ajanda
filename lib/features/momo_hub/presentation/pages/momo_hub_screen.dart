import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/core/theme/app_theme.dart';
import 'package:momo_ajanda/features/momo_hub/application/momo_hub_providers.dart';
import 'package:momo_ajanda/features/momo_hub/application/voice_service.dart';
import 'package:momo_ajanda/features/momo_hub/presentation/widgets/daily_summary_card.dart';
import 'package:momo_ajanda/features/momo_hub/presentation/widgets/momo_suggestions_card.dart';
import 'package:momo_ajanda/features/momo_hub/presentation/widgets/quick_actions_card.dart';
import 'package:momo_ajanda/features/momo_hub/presentation/widgets/weekly_chart_card.dart';
import 'package:momo_ajanda/features/momo_hub/presentation/widgets/voice_input_button.dart';
import 'package:momo_ajanda/features/momo_hub/presentation/widgets/quick_add_dialogs.dart';
import 'package:momo_ajanda/features/assistant/presentation/widgets/momo/momo_actor.dart';
import 'package:momo_ajanda/features/assistant/presentation/widgets/momo/momo_enums.dart';

/// Global navigasyon key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Sekme değiştirme provider
final selectedTabProvider = StateProvider<int>((ref) => 2);

class MomoHubScreen extends ConsumerStatefulWidget {
  const MomoHubScreen({super.key});

  @override
  ConsumerState<MomoHubScreen> createState() => _MomoHubScreenState();
}

class _MomoHubScreenState extends ConsumerState<MomoHubScreen> {
  final VoiceService _voiceService = VoiceService();
  bool _isListening = false;
  String _lastCommand = '';
  String _partialCommand = '';

  @override
  void initState() {
    super.initState();
    _initializeVoice();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(momoHubProvider.notifier).updateMomoState();
      _greetUser();
    });
  }

  Future<void> _initializeVoice() async {
    await _voiceService.initialize();
  }

  void _greetUser() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      // Sabah selamlaması (sessiz)
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      await _voiceService.stopListening();
      setState(() {
        _isListening = false;
        _partialCommand = '';
      });
      ref.read(momoHubProvider.notifier).setMood(MomoMood.idle);
    } else {
      setState(() {
        _isListening = true;
        _partialCommand = '';
      });
      ref.read(momoHubProvider.notifier).setMood(MomoMood.listening);

      await _voiceService.startListening(
        onResult: (text) {
          setState(() {
            _lastCommand = text;
            _isListening = false;
            _partialCommand = '';
          });
          _processCommand(text);
        },
        onPartialResult: (text) {
          setState(() => _partialCommand = text);
        },
        onListeningStarted: () {
          setState(() => _isListening = true);
        },
        onListeningStopped: () {
          setState(() {
            _isListening = false;
            _partialCommand = '';
          });
          ref.read(momoHubProvider.notifier).setMood(MomoMood.idle);
        },
      );
    }
  }

  void _processCommand(String text) async {
    final command = _voiceService.parseCommand(text);
    ref.read(momoHubProvider.notifier).setLastCommand(text);

    MomoMood newMood = MomoMood.idle;
    String response =
        _voiceService.getMomoResponse(command.type, params: command.parameters);

    switch (command.type) {
      case CommandType.greeting:
      case CommandType.howAreYou:
      case CommandType.thanks:
        newMood = MomoMood.happy;
        break;

      case CommandType.help:
        newMood = MomoMood.thinking;
        break;

      case CommandType.motivation:
        newMood = MomoMood.celebrate;
        break;

      case CommandType.createTask:
        newMood = MomoMood.happy;
        ref.read(momoHubProvider.notifier).setMood(newMood);
        await _voiceService.speak(response);
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          _showQuickTaskDialog(command.parameters?['content']);
        }
        return;

      case CommandType.showTasks:
        newMood = MomoMood.idle;
        ref.read(selectedTabProvider.notifier).state = 1; // Görevler sekmesi
        break;

      case CommandType.createNote:
        newMood = MomoMood.happy;
        ref.read(momoHubProvider.notifier).setMood(newMood);
        await _voiceService.speak(response);
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          _showQuickNoteDialog(command.parameters?['content']);
        }
        return;

      case CommandType.createReminder:
        newMood = MomoMood.happy;
        ref.read(momoHubProvider.notifier).setMood(newMood);
        await _voiceService.speak(response);
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          _showQuickReminderDialog(
            command.parameters?['content'],
            command.parameters?['time'],
          );
        }
        return;

      case CommandType.showReminders:
        newMood = MomoMood.idle;
        ref.read(selectedTabProvider.notifier).state =
            3; // Hatırlatıcılar sekmesi
        break;

      case CommandType.showReport:
        newMood = MomoMood.thinking;
        // Zaten Momo Hub'dayız, rapor kartlarını göster
        break;

      case CommandType.enableDarkMode:
        ref.read(themeModeProvider.notifier).setDarkMode();
        newMood = MomoMood.happy;
        break;

      case CommandType.enableLightMode:
        ref.read(themeModeProvider.notifier).setLightMode();
        newMood = MomoMood.happy;
        break;

      case CommandType.goToAgenda:
        newMood = MomoMood.idle;
        ref.read(selectedTabProvider.notifier).state = 0; // Ajanda sekmesi
        break;

      case CommandType.goToPomodoro:
        newMood = MomoMood.thinking;
        ref.read(selectedTabProvider.notifier).state = 4; // Pomodoro sekmesi
        break;

      case CommandType.goToProfile:
        newMood = MomoMood.idle;
        ref.read(selectedTabProvider.notifier).state = 5; // Profil sekmesi
        break;

      case CommandType.startDay:
        newMood = MomoMood.happy;
        ref.read(momoHubProvider.notifier).updateMomoState();
        break;

      case CommandType.unknown:
        newMood = MomoMood.sad;
        break;

      default:
        newMood = MomoMood.idle;
    }

    ref.read(momoHubProvider.notifier).setMood(newMood);
    await _voiceService.speak(response);

    // 3 saniye sonra normal moda dön
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      ref.read(momoHubProvider.notifier).updateMomoState();
    }
  }

  void _showQuickTaskDialog([String? content]) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => QuickTaskDialog(initialContent: content),
    );

    if (result == true && mounted) {
      ref.read(momoHubProvider.notifier).setMood(MomoMood.celebrate);
      await _voiceService.speak('Görev eklendi!');
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        ref.read(momoHubProvider.notifier).updateMomoState();
      }
    }
  }

  void _showQuickReminderDialog([String? content, String? time]) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => QuickReminderDialog(
        initialContent: content,
        initialTime: time,
      ),
    );

    if (result == true && mounted) {
      ref.read(momoHubProvider.notifier).setMood(MomoMood.celebrate);
      await _voiceService.speak('Hatırlatıcı kuruldu!');
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        ref.read(momoHubProvider.notifier).updateMomoState();
      }
    }
  }

  void _showQuickNoteDialog([String? content]) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => QuickNoteDialog(initialContent: content),
    );

    if (result != null && mounted) {
      ref.read(momoHubProvider.notifier).setMood(MomoMood.celebrate);
      await _voiceService.speak('Not kaydedildi!');
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        ref.read(momoHubProvider.notifier).updateMomoState();
      }
    }
  }

  void _handleQuickAction(QuickActionType action) async {
    switch (action) {
      case QuickActionType.note:
        _showQuickNoteDialog();
        break;
      case QuickActionType.task:
        _showQuickTaskDialog();
        break;
      case QuickActionType.reminder:
        _showQuickReminderDialog();
        break;
      case QuickActionType.pomodoro:
        ref.read(selectedTabProvider.notifier).state = 4;
        await _voiceService.speak('Odaklanma modu açılıyor');
        break;
      case QuickActionType.report:
        // Zaten bu sayfadayız, scroll aşağı
        await _voiceService.speak('Raporlar aşağıda');
        break;
      case QuickActionType.settings:
        _showSettingsSheet();
        break;
    }
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hubState = ref.watch(momoHubProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              hubState.mood.bgColor.withOpacity(0.3),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Row(
                  children: [
                    const Text('🌞', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      'Momo Merkez',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                    ),
                    onPressed: () {
                      ref.read(themeModeProvider.notifier).toggleTheme();
                      final newMode = ref.read(themeModeProvider);
                      _voiceService.speak(
                        newMode == ThemeMode.dark ? 'Karanlık mod' : 'Açık mod',
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: _showSettingsSheet,
                  ),
                ],
              ),

              // İçerik
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Momo karakteri ve mesaj
                    Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: MomoActor(
                              mood: hubState.mood,
                              intensity: hubState.intensity,
                              isSpeaking: _isListening,
                              onTap: _toggleListening,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Momo mesaj balonu
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: hubState.mood.accentColor
                                      .withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              _isListening
                                  ? (_partialCommand.isNotEmpty
                                      ? '"$_partialCommand..."'
                                      : '🎤 Dinliyorum...')
                                  : hubState.message,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontStyle:
                                    _isListening ? FontStyle.italic : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Sesli giriş butonu
                    Center(
                      child: VoiceInputButton(
                        isListening: _isListening,
                        onTap: _toggleListening,
                        lastCommand:
                            _lastCommand.isNotEmpty ? _lastCommand : null,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Günlük özet
                    const DailySummaryCard(),

                    const SizedBox(height: 16),

                    // Momo önerileri
                    MomoSuggestionsCard(
                      onSuggestionAction: (suggestion) async {
                        await _voiceService.speak(suggestion.message);
                        // Öneri tipine göre aksiyon
                        if (suggestion.id == 'overdue_reminders') {
                          ref.read(selectedTabProvider.notifier).state = 3;
                        } else if (suggestion.id == 'no_tasks') {
                          _showQuickTaskDialog();
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Hızlı eylemler
                    QuickActionsCard(
                      onActionTap: _handleQuickAction,
                    ),

                    const SizedBox(height: 16),

                    // Haftalık grafik
                    const WeeklyChartCard(),

                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSheet extends ConsumerWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Ayarlar',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Tema ayarı
              _SettingsTile(
                icon: Icons.palette,
                title: 'Tema',
                subtitle: themeMode == ThemeMode.dark ? 'Karanlık' : 'Açık',
                trailing: Switch(
                  value: themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                ),
              ),

              _SettingsTile(
                icon: Icons.volume_up,
                title: 'Sesli Yanıtlar',
                subtitle: 'Momo sesli konuşsun',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                ),
              ),

              _SettingsTile(
                icon: Icons.notifications,
                title: 'Bildirimler',
                subtitle: 'Hatırlatıcı bildirimleri',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),

              _SettingsTile(
                icon: Icons.language,
                title: 'Dil',
                subtitle: 'Türkçe',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),

              _SettingsTile(
                icon: Icons.backup,
                title: 'Yedekleme',
                subtitle: 'Verilerini yedekle',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),

              const Divider(height: 32),

              _SettingsTile(
                icon: Icons.help_outline,
                title: 'Yardım',
                subtitle: 'Momo nasıl kullanılır?',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),

              _SettingsTile(
                icon: Icons.info_outline,
                title: 'Hakkında',
                subtitle: 'Momo Ajanda v1.0.0',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: theme.colorScheme.primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
