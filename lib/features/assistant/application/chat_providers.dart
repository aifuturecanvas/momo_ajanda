import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/core/services/openai_service.dart';
import 'package:momo_ajanda/core/config/openai_config.dart';
import 'package:momo_ajanda/features/assistant/models/chat_message_model.dart';
import 'package:momo_ajanda/features/tasks/application/task_providers.dart';
import 'package:momo_ajanda/features/notes/application/note_providers.dart';
import 'package:momo_ajanda/features/reminders/application/reminder_providers.dart';

/// Chat mesajları provider'ı
final chatMessagesProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref);
});

/// Chat durumu provider'ı (yükleniyor mu, hata var mı?)
final chatStateProvider = Provider<ChatState>((ref) {
  final messages = ref.watch(chatMessagesProvider);
  final hasMessages = messages.isNotEmpty;
  final isProcessing =
      messages.isNotEmpty && messages.last.isProcessing && !messages.last.isUser;

  return ChatState(
    hasMessages: hasMessages,
    isProcessing: isProcessing,
    messageCount: messages.length,
  );
});

/// Chat durumu veri sınıfı
class ChatState {
  final bool hasMessages;
  final bool isProcessing;
  final int messageCount;

  ChatState({
    this.hasMessages = false,
    this.isProcessing = false,
    this.messageCount = 0,
  });
}

/// Chat Notifier - Mesajları ve AI entegrasyonunu yönetir
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;
  final OpenAIService _openAI = OpenAIService();

  ChatNotifier(this._ref) : super([]) {
    _initializeOpenAI();
    _addWelcomeMessage();
  }

  void _initializeOpenAI() {
    // OpenAI API key'i config'den al ve set et
    if (OpenAIConfig.hasApiKey) {
      _openAI.initialize(OpenAIConfig.apiKey);
    } else {
      debugPrint('⚠️ OpenAI API key bulunamadı!');
    }
  }

  void _addWelcomeMessage() {
    final welcomeMessage = _getWelcomeMessage();
    state = [
      ChatMessage(
        text: welcomeMessage,
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ];
  }

  String _getWelcomeMessage() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Günaydın! Ben Momo, senin akıllı asistanınım! 🌞\n\nSana nasıl yardımcı olabilirim?';
    } else if (hour >= 12 && hour < 18) {
      return 'İyi günler! Ben Momo! 😊\n\nBugün sana nasıl yardımcı olabilirim?';
    } else if (hour >= 18 && hour < 23) {
      return 'İyi akşamlar! Ben Momo! 🌙\n\nSana nasıl yardımcı olabilirim?';
    } else {
      return 'Merhaba! Geç saatlere kadar çalışıyorsun! 🌃\n\nSana nasıl yardımcı olabilirim?';
    }
  }

  /// Kullanıcı mesajı gönder
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Kullanıcı mesajını ekle
    final userMessage = ChatMessage(
      text: text,
      isUser: true,
    );

    state = [...state, userMessage];

    // "Düşünüyor..." mesajı ekle
    final thinkingMessage = ChatMessage(
      text: 'Düşünüyorum...',
      isUser: false,
      isProcessing: true,
    );

    state = [...state, thinkingMessage];

    try {
      // Bağlam ekle (mevcut görevler, notlar vb.)
      await _addContextToAI();

      // OpenAI'dan yanıt al
      final response = await _openAI.chat(text);

      // "Düşünüyor..." mesajını kaldır
      state = state.where((m) => !m.isProcessing).toList();

      // AI yanıtını parse et ve ekle
      final aiMessage = ChatMessage(
        text: response.message,
        isUser: false,
        action: response.action,
      );

      state = [...state, aiMessage];

      // Eğer aksiyon varsa, otomatik olarak çalıştır
      if (response.action != null) {
        await _executeAction(response.action!);
      }
    } catch (e) {
      debugPrint('Chat hatası: $e');

      // Hata mesajını ekle
      state = state.where((m) => !m.isProcessing).toList();

      final errorMessage = ChatMessage(
        text: 'Üzgünüm, bir hata oluştu. Lütfen tekrar dener misin? 😅',
        isUser: false,
      );

      state = [...state, errorMessage];
    }
  }

  /// AI'a bağlam ekle (görevler, notlar vb.)
  Future<void> _addContextToAI() async {
    final tasksAsync = _ref.read(tasksProvider);
    final notesAsync = _ref.read(notesProvider);
    final remindersAsync = _ref.read(remindersProvider);

    final contextParts = <String>[];

    // Görevler
    tasksAsync.whenData((tasks) {
      if (tasks.isNotEmpty) {
        final pending = tasks.where((t) => !t.isCompleted).take(5).toList();
        if (pending.isNotEmpty) {
          final tasksList = pending.map((t) => '- ${t.title}').join('\n');
          contextParts.add('Bekleyen görevler:\n$tasksList');
        }
      }
    });

    // Notlar
    notesAsync.whenData((notes) {
      if (notes.isNotEmpty) {
        contextParts.add('Toplam ${notes.length} not var.');
      }
    });

    // Hatırlatıcılar
    remindersAsync.whenData((reminders) {
      final upcoming = reminders
          .where((r) => !r.isCompleted && r.dateTime.isAfter(DateTime.now()))
          .take(3)
          .toList();
      if (upcoming.isNotEmpty) {
        final remindersList = upcoming
            .map((r) =>
                '- ${r.title} (${_formatDateTime(r.dateTime)})')
            .join('\n');
        contextParts.add('Yaklaşan hatırlatıcılar:\n$remindersList');
      }
    });

    if (contextParts.isNotEmpty) {
      _openAI.addContext(contextParts.join('\n\n'));
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = dateTime.difference(now);

    if (diff.inDays == 0) {
      return 'Bugün ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yarın ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Aksiyonu çalıştır
  Future<void> _executeAction(MomoAction action) async {
    try {
      switch (action.type) {
        case MomoActionType.createTask:
          await _createTask(action);
          break;
        case MomoActionType.createNote:
          await _createNote(action);
          break;
        case MomoActionType.createReminder:
          await _createReminder(action);
          break;
        case MomoActionType.completeTask:
          await _completeTask(action);
          break;
        case MomoActionType.deleteTask:
          await _deleteTask(action);
          break;
        case MomoActionType.showTasks:
        case MomoActionType.showNotes:
        case MomoActionType.showReminders:
        case MomoActionType.navigate:
        case MomoActionType.setTheme:
          // Bu aksiyonlar UI tarafında handle edilecek
          break;
        case MomoActionType.unknown:
          debugPrint('⚠️ Bilinmeyen aksiyon tipi');
          break;
      }
    } catch (e) {
      debugPrint('Aksiyon çalıştırma hatası: $e');
    }
  }

  Future<void> _createTask(MomoAction action) async {
    final title = action.title;
    if (title == null || title.isEmpty) return;

    final category = action.parameters['category'] ?? 'Genel';
    DateTime? dueDate;

    // Due date parse et
    final dueDateStr = action.dueDate;
    if (dueDateStr != null) {
      dueDate = _parseDueDate(dueDateStr);
    }

    await _ref.read(tasksProvider.notifier).addTask(
          title,
          category,
          dueDate: dueDate,
        );
  }

  Future<void> _createNote(MomoAction action) async {
    final title = action.title;
    final content = action.content;

    if (title == null || title.isEmpty) return;

    await _ref.read(notesProvider.notifier).addOrUpdateNote(
          title: title,
          content: content ?? '',
        );
  }

  Future<void> _createReminder(MomoAction action) async {
    final title = action.title;
    final time = action.time;

    if (title == null || title.isEmpty || time == null) return;

    final dateTime = _parseTime(time);
    if (dateTime == null) return;

    await _ref.read(remindersProvider.notifier).addReminder(
          title: title,
          dateTime: dateTime,
        );
  }

  Future<void> _completeTask(MomoAction action) async {
    final taskId = action.taskId;
    if (taskId == null) return;

    await _ref.read(tasksProvider.notifier).toggleTaskStatus(taskId);
  }

  Future<void> _deleteTask(MomoAction action) async {
    final taskId = action.taskId;
    if (taskId == null) return;

    await _ref.read(tasksProvider.notifier).deleteTask(taskId);
  }

  /// Due date parse et (basit versiyon)
  DateTime? _parseDueDate(String dateStr) {
    final now = DateTime.now();
    final lower = dateStr.toLowerCase();

    if (lower.contains('bugün')) {
      return now;
    } else if (lower.contains('yarın')) {
      return now.add(const Duration(days: 1));
    } else if (lower.contains('pazartesi')) {
      return _getNextWeekday(DateTime.monday);
    } else if (lower.contains('salı')) {
      return _getNextWeekday(DateTime.tuesday);
    } else if (lower.contains('çarşamba')) {
      return _getNextWeekday(DateTime.wednesday);
    } else if (lower.contains('perşembe')) {
      return _getNextWeekday(DateTime.thursday);
    } else if (lower.contains('cuma')) {
      return _getNextWeekday(DateTime.friday);
    } else if (lower.contains('cumartesi')) {
      return _getNextWeekday(DateTime.saturday);
    } else if (lower.contains('pazar')) {
      return _getNextWeekday(DateTime.sunday);
    }

    return null;
  }

  DateTime _getNextWeekday(int weekday) {
    final now = DateTime.now();
    int daysToAdd = (weekday - now.weekday + 7) % 7;
    if (daysToAdd == 0) daysToAdd = 7; // Bir sonraki haftaki aynı gün
    return now.add(Duration(days: daysToAdd));
  }

  /// Zaman parse et
  DateTime? _parseTime(String timeStr) {
    final now = DateTime.now();
    final lower = timeStr.toLowerCase();

    // "tomorrow 15:00" formatı
    if (lower.contains('tomorrow') || lower.contains('yarın')) {
      final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(timeStr);
      if (match != null) {
        final hour = int.parse(match.group(1)!);
        final minute = int.parse(match.group(2)!);
        return DateTime(
          now.year,
          now.month,
          now.day + 1,
          hour,
          minute,
        );
      }
    }

    // "bugün 15:00" formatı
    if (lower.contains('bugün')) {
      final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(timeStr);
      if (match != null) {
        final hour = int.parse(match.group(1)!);
        final minute = int.parse(match.group(2)!);
        return DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );
      }
    }

    // Basit saat formatı "15:00"
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(timeStr);
    if (match != null) {
      final hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      return DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
    }

    return null;
  }

  /// Konuşmayı temizle
  void clearChat() {
    _openAI.clearHistory();
    _addWelcomeMessage();
  }

  /// Mesajları temizle (konuşma geçmişini koru)
  void clearMessages() {
    _addWelcomeMessage();
  }
}
