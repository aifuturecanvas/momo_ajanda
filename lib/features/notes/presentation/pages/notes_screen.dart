import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/features/notes/application/note_providers.dart';
import 'package:momo_ajanda/features/notes/models/note_model.dart';
import 'package:momo_ajanda/features/notes/presentation/pages/note_detail_screen.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  void _navigateToDetail(BuildContext context, {Note? note}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(note: note),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsyncValue = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notlarım'),
      ),
      body: notesAsyncValue.when(
        data: (notes) => notes.isEmpty
            ? const Center(
                child: Text(
                  'Henüz notunuz yok.\nSağ alttaki + butonuyla ekleyebilirsiniz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return _buildNoteCard(context, ref, note);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: ${err.toString()}')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToDetail(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, WidgetRef ref, Note note) {
    return Dismissible(
      key: Key(note.id),
      onDismissed: (direction) =>
          ref.read(notesProvider.notifier).deleteNote(note.id),
      background: Container(
        color: Colors.red.withOpacity(0.8),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red.withOpacity(0.8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        child: ListTile(
          title: Text(
            note.title.isEmpty ? 'Başlıksız Not' : note.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            note.content.isEmpty ? 'İçerik yok' : note.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => _navigateToDetail(context, note: note),
        ),
      ),
    );
  }
}
