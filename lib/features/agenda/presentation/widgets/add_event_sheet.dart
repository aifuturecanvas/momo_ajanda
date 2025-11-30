import 'package:flutter/material.dart';
import 'package:momo_ajanda/features/agenda/models/event_model.dart';
import 'package:uuid/uuid.dart';

class AddEventSheet extends StatefulWidget {
  // Bu paneli hangi gün için açtığımızı bilmek için bu parametreyi ekliyoruz.
  final DateTime selectedDate;

  const AddEventSheet({super.key, required this.selectedDate});

  @override
  State<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<AddEventSheet> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _startTimeController =
      TextEditingController(text: "10:00"); // Varsayılan saat
  final _endTimeController =
      TextEditingController(text: "11:00"); // Varsayılan saat
  final _uuid = const Uuid();

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _addEvent() {
    if (_titleController.text.isNotEmpty) {
      final newEvent = Event(
        id: _uuid.v4(),
        date: widget.selectedDate, // Ana ekrandan gelen tarihi kullanıyoruz.
        title: _titleController.text,
        subtitle: _subtitleController.text,
        startTime: _startTimeController
            .text, // Metin alanından gelen saati kullanıyoruz.
        endTime: _endTimeController.text,
        color: Colors.purple,
      );
      Navigator.of(context).pop(newEvent);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        // Klavye açıldığında taşmayı önler
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Yeni Etkinlik Ekle',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                  labelText: 'Başlık', prefixIcon: Icon(Icons.title)),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subtitleController,
              decoration: const InputDecoration(
                  labelText: 'Detay',
                  prefixIcon: Icon(Icons.description_outlined)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _startTimeController,
                    decoration: const InputDecoration(
                        labelText: 'Başlangıç',
                        prefixIcon: Icon(Icons.access_time)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _endTimeController,
                    decoration: const InputDecoration(
                        labelText: 'Bitiş',
                        prefixIcon: Icon(Icons.timer_off_outlined)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _addEvent,
              child: const Text('Etkinliği Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
