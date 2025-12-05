import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:momo_ajanda/core/config/openai_config.dart';

/// OpenAI Servis Sınıfı
class OpenAIService {
  static final OpenAIService _instance = OpenAIService._internal();
  factory OpenAIService() => _instance;
  OpenAIService._internal();

  String? _apiKey;
  bool _isInitialized = false;
  final List<Map<String, String>> _conversationHistory = [];

  bool get isInitialized => _isInitialized;

  /// OpenAI'ı başlat
  void initialize(String apiKey) {
    if (_isInitialized && _apiKey == apiKey) return;

    _apiKey = apiKey;
    _isInitialized = true;

    // Sistem mesajını ekle
    _conversationHistory.clear();
    _conversationHistory.add({
      'role': 'system',
      'content': OpenAIConfig.momoSystemPrompt,
    });

    debugPrint('✅ OpenAI başlatıldı');
  }

  /// Momo ile sohbet
  Future<MomoResponse> chat(String userMessage) async {
    if (!_isInitialized || _apiKey == null) {
      return MomoResponse(
        message:
            'AI servisi henüz başlatılmadı. Lütfen API anahtarını ayarlayın.',
        action: null,
      );
    }

    // Kullanıcı mesajını ekle
    _conversationHistory.add({
      'role': 'user',
      'content': userMessage,
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': OpenAIConfig.chatModel,
          'messages': _conversationHistory,
          'temperature': OpenAIConfig.temperature,
          'max_tokens': OpenAIConfig.maxTokens,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;

        // Asistan cevabını geçmişe ekle
        _conversationHistory.add({
          'role': 'assistant',
          'content': content,
        });

        // Konuşma geçmişini sınırla (son 20 mesaj)
        if (_conversationHistory.length > 21) {
          _conversationHistory.removeRange(1, _conversationHistory.length - 20);
        }

        // Aksiyonları parse et
        return _parseResponse(content);
      } else {
        debugPrint(
            'OpenAI API hatası: ${response.statusCode} - ${response.body}');
        return MomoResponse(
          message: 'Bir sorun oluştu, tekrar dener misin? 😅',
          action: null,
        );
      }
    } catch (e) {
      debugPrint('OpenAI hatası: $e');
      return MomoResponse(
        message: 'Bağlantı sorunu var, internet bağlantını kontrol et! 📶',
        action: null,
      );
    }
  }

  /// Cevabı parse et ve aksiyonları çıkar
  MomoResponse _parseResponse(String content) {
    // [ACTION:...] formatını bul
    final actionRegex = RegExp(r'\[ACTION:([^\]]+)\]');
    final match = actionRegex.firstMatch(content);

    String message = content;
    MomoAction? action;

    if (match != null) {
      // Aksiyonu mesajdan çıkar
      message = content.replaceAll(match.group(0)!, '').trim();

      // Aksiyonu parse et
      final actionString = match.group(1)!;
      action = _parseAction(actionString);
    }

    return MomoResponse(message: message, action: action);
  }

  /// Aksiyon string'ini parse et
  MomoAction? _parseAction(String actionString) {
    try {
      final parts = actionString.split('|');
      final actionType = parts[0];

      final params = <String, String>{};
      for (int i = 1; i < parts.length; i++) {
        final keyValue = parts[i].split(':');
        if (keyValue.length == 2) {
          params[keyValue[0].trim()] = keyValue[1].trim();
        }
      }

      return MomoAction(
        type: MomoActionType.fromString(actionType),
        parameters: params,
      );
    } catch (e) {
      debugPrint('Aksiyon parse hatası: $e');
      return null;
    }
  }

  /// Konuşma geçmişini temizle
  void clearHistory() {
    _conversationHistory.clear();
    _conversationHistory.add({
      'role': 'system',
      'content': OpenAIConfig.momoSystemPrompt,
    });
  }

  /// Bağlam ekle (görevler, notlar vb.)
  void addContext(String context) {
    _conversationHistory.add({
      'role': 'system',
      'content': 'Kullanıcının mevcut verileri:\n$context',
    });
  }
}

/// Momo'nun cevabı
class MomoResponse {
  final String message;
  final MomoAction? action;

  MomoResponse({required this.message, this.action});
}

/// Momo'nun aksiyonu
class MomoAction {
  final MomoActionType type;
  final Map<String, String> parameters;

  MomoAction({required this.type, required this.parameters});
}

/// Aksiyon tipleri
enum MomoActionType {
  createTask,
  createNote,
  createReminder,
  showTasks,
  showNotes,
  showReminders,
  completeTask,
  deleteTask,
  setTheme,
  navigate,
  unknown;

  static MomoActionType fromString(String value) {
    switch (value.toUpperCase().trim()) {
      case 'CREATE_TASK':
        return MomoActionType.createTask;
      case 'CREATE_NOTE':
        return MomoActionType.createNote;
      case 'CREATE_REMINDER':
        return MomoActionType.createReminder;
      case 'SHOW_TASKS':
        return MomoActionType.showTasks;
      case 'SHOW_NOTES':
        return MomoActionType.showNotes;
      case 'SHOW_REMINDERS':
        return MomoActionType.showReminders;
      case 'COMPLETE_TASK':
        return MomoActionType.completeTask;
      case 'DELETE_TASK':
        return MomoActionType.deleteTask;
      case 'SET_THEME':
        return MomoActionType.setTheme;
      case 'NAVIGATE':
        return MomoActionType.navigate;
      default:
        return MomoActionType.unknown;
    }
  }
}
