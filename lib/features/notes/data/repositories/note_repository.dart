import 'dart:convert';
import 'package:momo_ajanda/features/notes/models/note_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Bu sınıf, not verilerini kaydetme ve yükleme işlerinden sorumludur.
class NoteRepository {
  final _storageKey = 'notes_data';

  // Verilen not listesini yerel depolamaya kaydeder.
  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> notesAsMap =
        notes.map((note) => note.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(notesAsMap));
  }

  // Yerel depolamadan not listesini yükler.
  Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesString = prefs.getString(_storageKey);

    if (notesString != null && notesString.isNotEmpty) {
      final List<dynamic> decodedData = jsonDecode(notesString);
      // Kayıtlı veriyi tarihe göre en yeniden eskiye doğru sıralayarak döndür.
      final notes = decodedData.map((item) => Note.fromJson(item)).toList();
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notes;
    }
    // Eğer kayıtlı veri yoksa boş bir liste döndür.
    return [];
  }
}
