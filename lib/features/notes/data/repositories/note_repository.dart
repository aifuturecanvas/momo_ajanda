import 'package:flutter/foundation.dart';
import 'package:momo_ajanda/core/services/supabase_service.dart';
import 'package:momo_ajanda/features/notes/models/note_model.dart';

/// Bu sınıf, not verilerini Supabase'de kaydetme ve yükleme işlerinden sorumludur.
class NoteRepository {
  final SupabaseService _supabase = SupabaseService();

  /// Kullanıcının tüm notlarını Supabase'den yükler
  Future<List<Note>> loadNotes() async {
    try {
      final data = await _supabase.getNotes();
      final notes = data.map((json) => Note.fromJson(json)).toList();
      // Tarihe göre en yeniden eskiye doğru sırala
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notes;
    } catch (e) {
      debugPrint('NoteRepository.loadNotes hatası: $e');
      return [];
    }
  }

  /// Yeni not ekler
  Future<void> addNote(Note note) async {
    try {
      await _supabase.addNote(note.toJson());
    } catch (e) {
      debugPrint('NoteRepository.addNote hatası: $e');
      rethrow;
    }
  }

  /// Notu günceller
  Future<void> updateNote(Note note) async {
    try {
      await _supabase.updateNote(note.id, note.toJson());
    } catch (e) {
      debugPrint('NoteRepository.updateNote hatası: $e');
      rethrow;
    }
  }

  /// Notu siler
  Future<void> deleteNote(String id) async {
    try {
      await _supabase.deleteNote(id);
    } catch (e) {
      debugPrint('NoteRepository.deleteNote hatası: $e');
      rethrow;
    }
  }

  /// DEPRECATED: Artık kullanılmıyor - Supabase ile tek tek işlemler yapılıyor
  @Deprecated('Supabase ile direkt işlem yapıldığı için gerekli değil')
  Future<void> saveNotes(List<Note> notes) async {
    // Bu method artık kullanılmıyor
    debugPrint('⚠️ saveNotes() deprecated - Supabase kullanın');
  }
}
