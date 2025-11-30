import 'package:uuid/uuid.dart';

// Bir notun sahip olacağı özellikleri tanımlayan sınıf.
class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  // Durumu güncellemeyi kolaylaştıran copyWith metodu.
  Note copyWith({String? title, String? content}) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
    );
  }

  // Veriyi kaydetmek için JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Kaydedilmiş veriden Note nesnesi oluşturma (Güvenli)
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id']?.toString() ?? const Uuid().v4(),
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: _parseDate(json['createdAt']),
    );
  }

  // Tarih parse etme işlemini güvenli hale getiren yardımcı fonksiyon.
  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue is String && dateValue.isNotEmpty) {
      try {
        return DateTime.parse(dateValue);
      } catch (_) {
        return DateTime.now(); // Hata durumunda şimdiki zamanı kullan.
      }
    }
    return DateTime.now(); // Değer null veya geçersizse şimdiki zamanı kullan.
  }
}
