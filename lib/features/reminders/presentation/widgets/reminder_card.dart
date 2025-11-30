import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:momo_ajanda/features/reminders/application/reminder_providers.dart';
import 'package:momo_ajanda/features/reminders/models/reminder_model.dart';
import 'package:momo_ajanda/features/reminders/presentation/widgets/add_reminder_sheet.dart';

class ReminderCard extends ConsumerWidget {
  final Reminder reminder;

  const ReminderCard({super.key, required this.reminder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeFormatter = DateFormat('HH:mm', 'tr_TR');
    final dateFormatter = DateFormat('d MMM', 'tr_TR');

    return Dismissible(
      key: Key(reminder.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(remindersProvider.notifier).deleteReminder(reminder.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${reminder.title} silindi'),
            action: SnackBarAction(
              label: 'Geri Al',
              onPressed: () {
                // Silme geri alınamaz şu an, ileride undo özelliği eklenebilir
              },
            ),
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: reminder.isOverdue
              ? BorderSide(color: Colors.red.shade300, width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showEditSheet(context),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Checkbox
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: reminder.isCompleted,
                    onChanged: (_) {
                      ref
                          .read(remindersProvider.notifier)
                          .toggleReminderStatus(reminder.id);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),

                // Öncelik göstergesi
                Container(
                  width: 4,
                  height: 50,
                  decoration: BoxDecoration(
                    color: reminder.priorityColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),

                // İçerik
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık
                      Text(
                        reminder.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: reminder.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: reminder.isCompleted
                              ? Colors.grey
                              : reminder.isOverdue
                                  ? Colors.red.shade700
                                  : null,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Tarih ve saat
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: reminder.isOverdue
                                ? Colors.red.shade400
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${dateFormatter.format(reminder.dateTime)} - ${timeFormatter.format(reminder.dateTime)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: reminder.isOverdue
                                  ? Colors.red.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          if (reminder.isOverdue) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Gecikmiş',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Açıklama varsa göster
                      if (reminder.description != null &&
                          reminder.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          reminder.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],

                      // Etiketler
                      if (reminder.tags.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 2,
                          children: reminder.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                // Tekrar ikonu
                if (reminder.repeat != ReminderRepeat.none)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Tooltip(
                      message: reminder.repeatText,
                      child: Icon(
                        Icons.repeat,
                        size: 20,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddReminderSheet(existingReminder: reminder),
    );
  }
}
