import 'dart:convert';
import 'package:momo_ajanda/features/reminders/models/reminder_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bu sınıf, hatırlatıcı verilerini kaydetme ve yükleme işlerinden sorumludur.
class ReminderRepository {
  static const _storageKey = 'reminders_data';

  /// Hatırlatıcıları yerel depolamadan yükler.
  Future<List<Reminder>> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? remindersString = prefs.getString(_storageKey);

    if (remindersString != null && remindersString.isNotEmpty) {
      try {
        final List<dynamic> decodedData = jsonDecode(remindersString);
        final reminders =
            decodedData.map((item) => Reminder.fromJson(item)).toList();
        // Tarihe göre sırala (en yakın olan en üstte)
        reminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        return reminders;
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  /// Verilen hatırlatıcı listesini yerel depolamaya kaydeder.
  Future<void> saveReminders(List<Reminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> remindersAsMap =
        reminders.map((reminder) => reminder.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(remindersAsMap));
  }
}
