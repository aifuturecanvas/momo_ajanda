import 'package:flutter/foundation.dart';
import 'package:momo_ajanda/core/services/supabase_service.dart';
import 'package:momo_ajanda/features/reminders/models/reminder_model.dart';

/// Bu sınıf, hatırlatıcı verilerini Supabase'de kaydetme ve yükleme işlerinden sorumludur.
class ReminderRepository {
  final SupabaseService _supabase = SupabaseService();

  /// Kullanıcının tüm hatırlatıcılarını Supabase'den yükler
  Future<List<Reminder>> loadReminders() async {
    try {
      final data = await _supabase.getReminders();
      final reminders = data.map((json) => Reminder.fromJson(json)).toList();
      // Tarihe göre sırala (en yakın olan en üstte)
      reminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return reminders;
    } catch (e) {
      debugPrint('ReminderRepository.loadReminders hatası: $e');
      return [];
    }
  }

  /// Yeni hatırlatıcı ekler
  Future<void> addReminder(Reminder reminder) async {
    try {
      await _supabase.addReminder(reminder.toJson());
    } catch (e) {
      debugPrint('ReminderRepository.addReminder hatası: $e');
      rethrow;
    }
  }

  /// Hatırlatıcıyı günceller
  Future<void> updateReminder(Reminder reminder) async {
    try {
      await _supabase.updateReminder(reminder.id, reminder.toJson());
    } catch (e) {
      debugPrint('ReminderRepository.updateReminder hatası: $e');
      rethrow;
    }
  }

  /// Hatırlatıcıyı siler
  Future<void> deleteReminder(String id) async {
    try {
      await _supabase.deleteReminder(id);
    } catch (e) {
      debugPrint('ReminderRepository.deleteReminder hatası: $e');
      rethrow;
    }
  }

  /// DEPRECATED: Artık kullanılmıyor - Supabase ile tek tek işlemler yapılıyor
  @Deprecated('Supabase ile direkt işlem yapıldığı için gerekli değil')
  Future<void> saveReminders(List<Reminder> reminders) async {
    // Bu method artık kullanılmıyor
    debugPrint('⚠️ saveReminders() deprecated - Supabase kullanın');
  }
}
