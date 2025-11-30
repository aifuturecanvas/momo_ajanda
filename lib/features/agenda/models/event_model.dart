import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// Bir ajanda etkinliğinin sahip olacağı tüm bilgileri içeren sınıf.
class Event {
  final String id;
  final DateTime date;
  final String title;
  final String subtitle;
  final String startTime;
  final String endTime;
  final Color color;

  Event({
    required this.id,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.startTime,
    required this.endTime,
    required this.color,
  });

  // Veriyi kaydetmek için JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // HATA BURADAYDI: Ortadaki tire (-) kaldırıldı.
      'date': date.toIso8601String(),
      'title': title,
      'subtitle': subtitle,
      'startTime': startTime,
      'endTime': endTime,
      'color': color.value,
    };
  }

  // --- YENİLENMİŞ VE GÜVENLİ fromJson METODU ---
  // Kaydedilmiş veriden Event nesnesi oluşturma
  factory Event.fromJson(Map<String, dynamic> json) {
    // toString() metodu, değer null olsa bile "null" string'i döndürmez,
    // gerçek bir null döndürür. Bu yüzden ?? operatörü güvenle çalışır.
    final id = json['id']?.toString() ?? const Uuid().v4();
    final title = json['title']?.toString() ?? 'Başlıksız Etkinlik';
    final subtitle = json['subtitle']?.toString() ?? '';
    final startTime = json['startTime']?.toString() ?? '00:00';
    final endTime = json['endTime']?.toString() ?? '00:00';
    final colorValue = json['color'] as int? ?? Colors.blue.value;

    DateTime date;
    try {
      // Tarih alanı null veya boş ise, veya formatı bozuksa
      // hata vermemesi için try-catch bloğu kullanıyoruz.
      date = DateTime.parse(json['date']?.toString() ?? '');
    } catch (e) {
      // Hata durumunda, etkinliği bugünün tarihi olarak ayarla.
      date = DateTime.now();
    }

    return Event(
      id: id,
      date: date,
      title: title,
      subtitle: subtitle,
      startTime: startTime,
      endTime: endTime,
      color: Color(colorValue),
    );
  }
}
