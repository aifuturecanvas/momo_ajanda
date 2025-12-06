import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/features/notes/data/repositories/note_repository.dart';
import 'package:momo_ajanda/features/notes/models/note_model.dart';
import 'package:uuid/uuid.dart';

// 1. NoteRepository için provider.
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository();
});

// 2. Not listesini yöneten StateNotifierProvider.
final notesProvider =
    StateNotifierProvider<NotesNotifier, AsyncValue<List<Note>>>((ref) {
  final repository = ref.watch(noteRepositoryProvider);
  return NotesNotifier(repository);
});

// STATE NOTIFIER - Supabase entegre edilmiş versiyon
class NotesNotifier extends StateNotifier<AsyncValue<List<Note>>> {
  final NoteRepository _repository;

  NotesNotifier(this._repository) : super(const AsyncLoading()) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    try {
      state = const AsyncLoading();
      final notes = await _repository.loadNotes();
      state = AsyncData(notes);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> addOrUpdateNote({
    String? id,
    required String title,
    required String content,
  }) async {
    try {
      final previousState = state.value ?? [];

      if (id == null) {
        // Yeni Not Ekleme
        final newNote = Note(
          id: const Uuid().v4(),
          title: title,
          content: content,
          createdAt: DateTime.now(),
        );

        // Önce Supabase'e ekle
        await _repository.addNote(newNote);

        // Başarılı olursa state'i güncelle
        final updatedList = [newNote, ...previousState];
        state = AsyncData(updatedList);
      } else {
        // Mevcut Notu Güncelleme
        final note = previousState.firstWhere((n) => n.id == id);
        final updatedNote = note.copyWith(title: title, content: content);

        // Önce Supabase'de güncelle
        await _repository.updateNote(updatedNote);

        // Başarılı olursa state'i güncelle
        final updatedList = previousState.map((n) {
          if (n.id == id) {
            return updatedNote;
          }
          return n;
        }).toList();
        state = AsyncData(updatedList);
      }
    } catch (e) {
      // Hata olursa state'i tekrar yükle
      await loadNotes();
      rethrow;
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      // Önce Supabase'den sil
      await _repository.deleteNote(id);

      // Başarılı olursa state'i güncelle
      final previousState = state.value ?? [];
      final updatedList = previousState.where((note) => note.id != id).toList();
      state = AsyncData(updatedList);
    } catch (e) {
      // Hata olursa state'i tekrar yükle
      await loadNotes();
      rethrow;
    }
  }
}
