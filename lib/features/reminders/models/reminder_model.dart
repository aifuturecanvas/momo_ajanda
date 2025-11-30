import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Hatırlatıcı öncelik seviyeleri
enum ReminderPriority { low, medium, high }

/// Hatırlatıcı tekrar türleri
enum ReminderRepeat { none, daily, weekly, monthly, yearly }

/// Bir hatırlatıcının sahip olacağı tüm bilgileri içeren sınıf.
class Reminder {
  final String id;
  final String title;
  final String? description;
  final DateTime dateTime;
  final ReminderPriority priority;
  final ReminderRepeat repeat;
  final List<String> tags; // Etiketler: #iş, #kişisel vb.
  final bool isCompleted;
  final String? linkedEventId; // Bağlı etkinlik varsa
  final String? linkedTaskId; // Bağlı görev varsa
  final int minutesBefore; // Kaç dakika önce hatırlat (0, 5, 10, 15, 30, 60)

  Reminder({
    required this.id,
    required this.title,
    this.description,
    required this.dateTime,
    this.priority = ReminderPriority.medium,
    this.repeat = ReminderRepeat.none,
    this.tags = const [],
    this.isCompleted = false,
    this.linkedEventId,
    this.linkedTaskId,
    this.minutesBefore = 15,
  });

  /// Durumu güncellemeyi kolaylaştıran copyWith metodu.
  Reminder copyWith({
    String? title,
    String? description,
    DateTime? dateTime,
    ReminderPriority? priority,
    ReminderRepeat? repeat,
    List<String>? tags,
    bool? isCompleted,
    String? linkedEventId,
    String? linkedTaskId,
    int? minutesBefore,
  }) {
    return Reminder(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      priority: priority ?? this.priority,
      repeat: repeat ?? this.repeat,
      tags: tags ?? this.tags,
      isCompleted: isCompleted ?? this.isCompleted,
      linkedEventId: linkedEventId ?? this.linkedEventId,
      linkedTaskId: linkedTaskId ?? this.linkedTaskId,
      minutesBefore: minutesBefore ?? this.minutesBefore,
    );
  }

  /// Önceliğe göre renk döndüren yardımcı metot
  Color get priorityColor {
    switch (priority) {
      case ReminderPriority.high:
        return Colors.red.shade400;
      case ReminderPriority.medium:
        return Colors.orange.shade400;
      case ReminderPriority.low:
        return Colors.green.shade400;
    }
  }

  /// Önceliğe göre ikon döndüren yardımcı metot
  IconData get priorityIcon {
    switch (priority) {
      case ReminderPriority.high:
        return Icons.priority_high;
      case ReminderPriority.medium:
        return Icons.remove;
      case ReminderPriority.low:
        return Icons.arrow_downward;
    }
  }

  /// Tekrar türüne göre açıklama metni
  String get repeatText {
    switch (repeat) {
      case ReminderRepeat.none:
        return 'Tekrar yok';
      case ReminderRepeat.daily:
        return 'Her gün';
      case ReminderRepeat.weekly:
        return 'Her hafta';
      case ReminderRepeat.monthly:
        return 'Her ay';
      case ReminderRepeat.yearly:
        return 'Her yıl';
    }
  }

  /// Hatırlatıcının geçip geçmediğini kontrol eder
  bool get isOverdue {
    return !isCompleted && dateTime.isBefore(DateTime.now());
  }

  /// Bugün mü kontrol eder
  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Veriyi kaydetmek için JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'priority': priority.index,
      'repeat': repeat.index,
      'tags': tags,
      'isCompleted': isCompleted,
      'linkedEventId': linkedEventId,
      'linkedTaskId': linkedTaskId,
      'minutesBefore': minutesBefore,
    };
  }

  /// Kaydedilmiş veriden Reminder nesnesi oluşturma
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id']?.toString() ?? const Uuid().v4(),
      title: json['title']?.toString() ?? 'Başlıksız Hatırlatıcı',
      description: json['description']?.toString(),
      dateTime: _parseDate(json['dateTime']),
      priority: ReminderPriority.values[json['priority'] ?? 1],
      repeat: ReminderRepeat.values[json['repeat'] ?? 0],
      tags: List<String>.from(json['tags'] ?? []),
      isCompleted: json['isCompleted'] ?? false,
      linkedEventId: json['linkedEventId']?.toString(),
      linkedTaskId: json['linkedTaskId']?.toString(),
      minutesBefore: json['minutesBefore'] ?? 15,
    );
  }

  /// Tarih parse etme işlemini güvenli hale getiren yardımcı fonksiyon.
  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue is String && dateValue.isNotEmpty) {
      try {
        return DateTime.parse(dateValue);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}
