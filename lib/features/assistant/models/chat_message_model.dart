import 'package:uuid/uuid.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser; // Mesaj kullanıcıdan mı geldi, Momo'dan mı?
  final DateTime timestamp;
  final MomoAction? action; // AI'ın önerdiği aksiyon
  final bool isProcessing; // AI düşünüyor mu?

  ChatMessage({
    String? id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.action,
    this.isProcessing = false,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  ChatMessage copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
    MomoAction? action,
    bool? isProcessing,
  }) {
    return ChatMessage(
      id: id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      action: action ?? this.action,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

/// Momo'nun AI tarafından önerilen aksiyonu
class MomoAction {
  final MomoActionType type;
  final Map<String, String> parameters;

  MomoAction({
    required this.type,
    required this.parameters,
  });

  String? get title => parameters['title'];
  String? get content => parameters['content'];
  String? get time => parameters['time'];
  String? get dueDate => parameters['due_date'];
  String? get priority => parameters['priority'];
  String? get page => parameters['page'];
  String? get taskId => parameters['task_id'];
  String? get theme => parameters['theme'];
}

/// Aksiyon tipleri
enum MomoActionType {
  createTask,      // Görev oluştur
  createNote,      // Not oluştur
  createReminder,  // Hatırlatıcı kur
  showTasks,       // Görevleri göster
  showNotes,       // Notları göster
  showReminders,   // Hatırlatıcıları göster
  completeTask,    // Görevi tamamla
  deleteTask,      // Görevi sil
  setTheme,        // Tema değiştir
  navigate,        // Sayfa değiştir
  unknown;         // Tanımsız

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
