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

// STATE NOTIFIER
class NotesNotifier extends StateNotifier<AsyncValue<List<Note>>> {
  final NoteRepository _repository;

  NotesNotifier(this._repository) : super(const AsyncLoading()) {
    // Notifier oluşturulur oluşturulmaz notları yükle.
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

  Future<void> addOrUpdateNote(
      {String? id, required String title, required String content}) async {
    final previousState = state.value ?? [];
    if (id == null) {
      // Yeni Not Ekleme
      final newNote = Note(
        id: const Uuid().v4(),
        title: title,
        content: content,
        createdAt: DateTime.now(),
      );
      final updatedList = [newNote, ...previousState];
      state = AsyncData(updatedList);
      await _repository.saveNotes(updatedList);
    } else {
      // Mevcut Notu Güncelleme
      final updatedList = previousState.map((note) {
        if (note.id == id) {
          return note.copyWith(title: title, content: content);
        }
        return note;
      }).toList();
      state = AsyncData(updatedList);
      await _repository.saveNotes(updatedList);
    }
  }

  Future<void> deleteNote(String id) async {
    final previousState = state.value ?? [];
    final updatedList = previousState.where((note) => note.id != id).toList();
    state = AsyncData(updatedList);
    await _repository.saveNotes(updatedList);
  }
}
