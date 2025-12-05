import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

/// Sesli etkileşim servisi
class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _lastWords = '';

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String get lastWords => _lastWords;

  /// Servisi başlat
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Speech to text
      bool speechAvailable = await _speech.initialize(
        onStatus: (status) => debugPrint('STT Status: $status'),
        onError: (error) => debugPrint('STT Error: $error'),
      );

      // Text to speech ayarları
      await _tts.setLanguage('tr-TR');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.1);

      // TTS durumlarını dinle
      _tts.setStartHandler(() {
        _isSpeaking = true;
      });
      _tts.setCompletionHandler(() {
        _isSpeaking = false;
      });
      _tts.setErrorHandler((msg) {
        _isSpeaking = false;
        debugPrint('TTS Error: $msg');
      });

      _isInitialized = speechAvailable;
      return speechAvailable;
    } catch (e) {
      debugPrint('Voice service init error: $e');
      return false;
    }
  }

  /// Dinlemeye başla
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onPartialResult,
    Function()? onListeningStarted,
    Function()? onListeningStopped,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isListening) return;

    // Önce konuşmayı durdur
    if (_isSpeaking) {
      await stopSpeaking();
    }

    _isListening = true;
    _lastWords = '';
    onListeningStarted?.call();

    await _speech.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;

        if (result.finalResult) {
          onResult(_lastWords);
          _isListening = false;
          onListeningStopped?.call();
        } else {
          onPartialResult?.call(_lastWords);
        }
      },
      localeId: 'tr_TR',
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
    );
  }

  /// Dinlemeyi durdur
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  /// Momo konuşsun
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Dinleme varsa durdur
    if (_isListening) {
      await stopListening();
    }

    _isSpeaking = true;
    await _tts.speak(text);
  }

  /// Konuşmayı durdur
  Future<void> stopSpeaking() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  /// Komut analizi - Geliştirilmiş versiyon
  MomoCommand parseCommand(String input) {
    final text = input.toLowerCase().trim();

    // Zaman bilgisi çıkarma
    final timeMatch =
        RegExp(r'saat\s*(\d{1,2})[:.]?(\d{0,2})').firstMatch(text);
    String? extractedTime;
    if (timeMatch != null) {
      final hour = timeMatch.group(1);
      final minute =
          timeMatch.group(2)?.isNotEmpty == true ? timeMatch.group(2) : '00';
      extractedTime = '$hour:$minute';
    }

    // Tarih bilgisi çıkarma
    String? extractedDate;
    if (text.contains('yarın')) {
      extractedDate = 'yarın';
    } else if (text.contains('bugün')) {
      extractedDate = 'bugün';
    } else if (text.contains('hafta sonu')) {
      extractedDate = 'hafta sonu';
    }

    // Görev komutları
    if (_containsAny(
        text, ['görev ekle', 'yeni görev', 'görev oluştur', 'görev yap'])) {
      final content = _extractContent(
          text, ['görev ekle', 'yeni görev', 'görev oluştur', 'görev yap']);
      return MomoCommand(
        type: CommandType.createTask,
        originalText: input,
        parameters: {
          'content': content,
          'time': extractedTime,
          'date': extractedDate,
        },
      );
    }
    if (_containsAny(text,
        ['görevleri göster', 'görevlerim', 'görevler', 'görev listesi'])) {
      return MomoCommand(type: CommandType.showTasks, originalText: input);
    }
    if (_containsAny(
        text, ['görevi tamamla', 'görevi bitir', 'hallettim', 'bitti'])) {
      return MomoCommand(type: CommandType.completeTask, originalText: input);
    }

    // Not komutları
    if (_containsAny(
        text, ['not al', 'not ekle', 'yeni not', 'not yaz', 'not oluştur'])) {
      final content = _extractContent(
          text, ['not al', 'not ekle', 'yeni not', 'not yaz', 'not oluştur']);
      return MomoCommand(
        type: CommandType.createNote,
        originalText: input,
        parameters: {'content': content},
      );
    }
    if (_containsAny(
        text, ['notları göster', 'notlarım', 'notlar', 'not listesi'])) {
      return MomoCommand(type: CommandType.showNotes, originalText: input);
    }

    // Hatırlatıcı komutları
    if (_containsAny(text, [
      'hatırlat',
      'hatırlatıcı ekle',
      'hatırlatıcı oluştur',
      'bana hatırlat'
    ])) {
      final content = _extractContent(text, [
        'hatırlat',
        'hatırlatıcı ekle',
        'hatırlatıcı oluştur',
        'bana hatırlat'
      ]);
      return MomoCommand(
        type: CommandType.createReminder,
        originalText: input,
        parameters: {
          'content': content,
          'time': extractedTime,
          'date': extractedDate,
        },
      );
    }
    if (_containsAny(text,
        ['hatırlatıcıları göster', 'hatırlatıcılarım', 'hatırlatıcılar'])) {
      return MomoCommand(type: CommandType.showReminders, originalText: input);
    }

    // Rapor komutları
    if (_containsAny(
        text, ['rapor', 'istatistik', 'özet', 'analiz', 'performans'])) {
      return MomoCommand(type: CommandType.showReport, originalText: input);
    }

    // Tema komutları
    if (_containsAny(
        text, ['karanlık mod', 'gece modu', 'dark mode', 'karanlık tema'])) {
      return MomoCommand(type: CommandType.enableDarkMode, originalText: input);
    }
    if (_containsAny(
        text, ['açık mod', 'gündüz modu', 'light mode', 'açık tema'])) {
      return MomoCommand(
          type: CommandType.enableLightMode, originalText: input);
    }

    // Navigasyon
    if (_containsAny(text, ['ajanda', 'ana sayfa', 'takvim', 'anasayfa'])) {
      return MomoCommand(type: CommandType.goToAgenda, originalText: input);
    }
    if (_containsAny(text,
        ['odaklan', 'pomodoro', 'zamanlayıcı', 'timer', 'çalışma modu'])) {
      return MomoCommand(type: CommandType.goToPomodoro, originalText: input);
    }
    if (_containsAny(text, ['profil', 'hesap', 'ayarlar'])) {
      return MomoCommand(type: CommandType.goToProfile, originalText: input);
    }

    // Momo etkileşim
    if (_containsAny(
        text, ['merhaba', 'selam', 'hey momo', 'günaydın', 'iyi akşamlar'])) {
      return MomoCommand(type: CommandType.greeting, originalText: input);
    }
    if (_containsAny(
        text, ['nasılsın', 'naber', 'ne haber', 'keyifler nasıl'])) {
      return MomoCommand(type: CommandType.howAreYou, originalText: input);
    }
    if (_containsAny(text, ['teşekkür', 'sağol', 'eyvallah', 'çok sağol'])) {
      return MomoCommand(type: CommandType.thanks, originalText: input);
    }
    if (_containsAny(
        text, ['yardım', 'ne yapabilirsin', 'komutlar', 'yeteneklerin'])) {
      return MomoCommand(type: CommandType.help, originalText: input);
    }
    if (_containsAny(text, ['günümü başlat', 'güne başla', 'bugün ne var'])) {
      return MomoCommand(type: CommandType.startDay, originalText: input);
    }
    if (_containsAny(text, ['motivasyon', 'motive et', 'cesaret ver'])) {
      return MomoCommand(type: CommandType.motivation, originalText: input);
    }

    return MomoCommand(type: CommandType.unknown, originalText: input);
  }

  bool _containsAny(String text, List<String> patterns) {
    for (var pattern in patterns) {
      if (text.contains(pattern)) return true;
    }
    return false;
  }

  String _extractContent(String text, List<String> triggers) {
    String result = text;
    for (var trigger in triggers) {
      result = result.replaceAll(trigger, '');
    }
    // Zaman ve tarih ifadelerini de temizle
    result = result.replaceAll(RegExp(r'saat\s*\d{1,2}[:.]?\d{0,2}'), '');
    result = result.replaceAll('yarın', '');
    result = result.replaceAll('bugün', '');
    result = result.replaceAll('hafta sonu', '');
    return result.trim();
  }

  /// Momo'nun akıllı yanıtları
  String getMomoResponse(CommandType type, {Map<String, dynamic>? params}) {
    final hour = DateTime.now().hour;
    final greeting =
        hour < 12 ? 'Günaydın' : (hour < 18 ? 'İyi günler' : 'İyi akşamlar');

    switch (type) {
      case CommandType.greeting:
        final responses = [
          '$greeting! Sana nasıl yardımcı olabilirim?',
          'Merhaba! Bugün neler yapmak istersin?',
          'Selam! Ben buradayım, ne yapayım?',
        ];
        return responses[DateTime.now().second % responses.length];

      case CommandType.howAreYou:
        final responses = [
          'Harikayım, teşekkürler! Sen nasılsın?',
          'Çok iyiyim! Seninle konuşmak güzel.',
          'Süper! Bugün enerjiyim yüksek!',
        ];
        return responses[DateTime.now().second % responses.length];

      case CommandType.thanks:
        final responses = [
          'Rica ederim! Her zaman buradayım.',
          'Ne demek, bu benim görevim!',
          'Yardımcı olabildiysem ne mutlu!',
        ];
        return responses[DateTime.now().second % responses.length];

      case CommandType.help:
        return 'Şunları yapabilirim: Görev ekle, not al, hatırlatıcı kur, rapor göster, tema değiştir, ve daha fazlası! Ne yapmamı istersin?';

      case CommandType.startDay:
        return '$greeting! Bugün için planlarına bakalım. Görevlerini ve hatırlatıcılarını kontrol ediyorum.';

      case CommandType.motivation:
        final motivations = [
          'Harika işler başarıyorsun, böyle devam et! 💪',
          'Her küçük adım seni hedefe yaklaştırıyor!',
          'Bugün senin günün, en iyisini yapabilirsin!',
          'Zorluklar seni güçlendirir, vazgeçme!',
          'Sen yapabilirsin, sana inanıyorum! 🌟',
        ];
        return motivations[DateTime.now().second % motivations.length];

      case CommandType.createTask:
        return 'Yeni görev oluşturuyorum!';
      case CommandType.showTasks:
        return 'Görevlerini açıyorum!';
      case CommandType.createNote:
        return 'Not ekliyorum!';
      case CommandType.showNotes:
        return 'Notlarını gösteriyorum!';
      case CommandType.createReminder:
        return 'Hatırlatıcı kuruyorum!';
      case CommandType.showReminders:
        return 'Hatırlatıcılarını açıyorum!';
      case CommandType.showReport:
        return 'Raporunu hazırlıyorum!';
      case CommandType.enableDarkMode:
        return 'Karanlık mod açıldı!';
      case CommandType.enableLightMode:
        return 'Açık mod açıldı!';
      case CommandType.goToAgenda:
        return 'Ajandaya gidiyoruz!';
      case CommandType.goToPomodoro:
        return 'Odaklanma modunu açıyorum!';
      case CommandType.goToProfile:
        return 'Profil sayfasını açıyorum!';
      case CommandType.unknown:
        final unknownResponses = [
          'Anlayamadım, tekrar söyler misin?',
          'Bunu tam anlayamadım. Başka türlü söyleyebilir misin?',
          'Hmm, ne demek istediğini çözemedim.',
        ];
        return unknownResponses[
            DateTime.now().second % unknownResponses.length];
      default:
        return 'Tamam, hemen yapıyorum!';
    }
  }
}

enum CommandType {
  // CRUD
  createTask,
  showTasks,
  completeTask,
  createNote,
  showNotes,
  createReminder,
  showReminders,
  showReport,

  // Tema
  enableDarkMode,
  enableLightMode,

  // Navigasyon
  goToAgenda,
  goToPomodoro,
  goToProfile,

  // Etkileşim
  greeting,
  howAreYou,
  thanks,
  help,
  startDay,
  motivation,

  unknown,
}

class MomoCommand {
  final CommandType type;
  final String originalText;
  final Map<String, dynamic>? parameters;

  MomoCommand({
    required this.type,
    required this.originalText,
    this.parameters,
  });
}
