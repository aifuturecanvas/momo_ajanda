import 'package:momo_ajanda/core/services/openai_service.dart';
import 'package:uuid/uuid.dart';

/// Chat mesajı - Kullanıcı ve Momo arasındaki mesajlaşma
class ChatMessage {
  final String id;
  final String text;
  final bool isUser; // Mesaj kullanıcıdan mı geldi, Momo'dan mı?
  final DateTime timestamp;
  final MomoAction? action; // AI'ın önerdiği aksiyon (openai_service.dart'tan)
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

/// Helper extension for MomoAction to access parameters easily
extension MomoActionExtension on MomoAction {
  String? get title => parameters['title'];
  String? get content => parameters['content'];
  String? get time => parameters['time'];
  String? get dueDate => parameters['due_date'];
  String? get priority => parameters['priority'];
  String? get page => parameters['page'];
  String? get taskId => parameters['task_id'];
  String? get theme => parameters['theme'];
}
