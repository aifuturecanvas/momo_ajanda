import 'dart:convert';
import 'package:momo_ajanda/features/agenda/models/event_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Bu sınıf, etkinlik verilerini yönetmekten sorumlu tek yerdir.
class EventRepository {
  // Verileri kaydetmek için kullanılacak anahtar.
  static const _eventsKey = 'events_data';

  // Etkinlikleri yerel depolamadan yükleyen metot.
  // Bu metot public'tir (başında _ yoktur) ve dışarıdan çağrılabilir.
  Future<List<Event>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsString = prefs.getString(_eventsKey);

    if (eventsString != null && eventsString.isNotEmpty) {
      try {
        final List<dynamic> decodedData = jsonDecode(eventsString);
        return decodedData.map((item) => Event.fromJson(item)).toList();
      } catch (e) {
        // Eğer JSON parse ederken bir hata olursa (bozuk veri),
        // boş liste döndürerek uygulamanın çökmesini engelle.
        return [];
      }
    }
    // Eğer hiç veri yoksa, boş bir liste döndür.
    return [];
  }

  // Verilen etkinlik listesini yerel depolamaya kaydeden metot.
  Future<void> saveEvents(List<Event> events) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> eventsAsMap =
        events.map((event) => event.toJson()).toList();
    await prefs.setString(_eventsKey, jsonEncode(eventsAsMap));
  }
}
