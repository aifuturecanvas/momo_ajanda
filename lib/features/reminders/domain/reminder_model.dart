/// Tekrarlama tipi
enum RepeatType {
  none,
  daily,
  weekly,
  monthly;

  String get label {
    switch (this) {
      case RepeatType.none:
        return 'Tekrarlama yok';
      case RepeatType.daily:
        return 'Her gün';
      case RepeatType.weekly:
        return 'Her hafta';
      case RepeatType.monthly:
        return 'Her ay';
    }
  }

  static RepeatType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'daily':
        return RepeatType.daily;
      case 'weekly':
        return RepeatType.weekly;
      case 'monthly':
        return RepeatType.monthly;
      default:
        return RepeatType.none;
    }
  }
}

/// Hatırlatıcı modeli
class Reminder {
  final String id;
  final String title;
  final DateTime dateTime;
  final bool isCompleted;
  final RepeatType repeatType;
  final DateTime createdAt;

  Reminder({
    required this.id,
    required this.title,
    required this.dateTime,
    this.isCompleted = false,
    this.repeatType = RepeatType.none,
    required this.createdAt,
  });

  /// Süresi geçmiş mi?
  bool get isOverdue => !isCompleted && dateTime.isBefore(DateTime.now());

  /// JSON'dan oluştur
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      title: json['title'] as String,
      dateTime: DateTime.parse(json['reminder_time'] as String),
      isCompleted: json['is_completed'] as bool? ?? false,
      repeatType: RepeatType.fromString(json['repeat_type'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'reminder_time': dateTime.toIso8601String(),
      'is_completed': isCompleted,
      'repeat_type': repeatType.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Kopya oluştur
  Reminder copyWith({
    String? id,
    String? title,
    DateTime? dateTime,
    bool? isCompleted,
    RepeatType? repeatType,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
      repeatType: repeatType ?? this.repeatType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
