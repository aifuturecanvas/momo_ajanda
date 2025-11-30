import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/features/notes/application/note_providers.dart';
import 'package:momo_ajanda/features/notes/models/note_model.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  final Note? note;

  const NoteDetailScreen({super.key, this.note});

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_titleController.text.isNotEmpty ||
        _contentController.text.isNotEmpty) {
      ref.read(notesProvider.notifier).addOrUpdateNote(
            id: widget.note?.id,
            title: _titleController.text,
            content: _contentController.text,
          );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Yeni Not' : 'Notu Düzenle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _saveNote,
            tooltip: 'Kaydet',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration.collapsed(
                hintText: 'Başlık',
              ),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(height: 24),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Notunuzu buraya yazın...',
                ),
                maxLines: null,
                expands: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
