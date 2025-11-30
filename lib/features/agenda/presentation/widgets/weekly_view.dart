import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:momo_ajanda/features/agenda/application/agenda_providers.dart';
import 'package:momo_ajanda/features/agenda/models/event_model.dart';

// Widget'ımızı artık bir ConsumerWidget'a dönüştürüyoruz.
// Bu sayede dışarıdan parametre almasına gerek kalmayacak.
class WeeklyView extends ConsumerWidget {
  const WeeklyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Verileri doğrudan provider'lardan dinliyoruz.
    final selectedDate = ref.watch(selectedDateProvider);
    final allEventsAsyncValue = ref.watch(eventsProvider);

    // Haftanın günlerini hesaplayan yardımcı fonksiyon.
    List<DateTime> getDaysOfWeek(DateTime date) {
      DateTime startOfWeek = date.subtract(Duration(days: date.weekday - 1));
      return List.generate(
          7, (index) => startOfWeek.add(Duration(days: index)));
    }

    final List<DateTime> weekDays = getDaysOfWeek(selectedDate);
    final DateFormat dayFormatter = DateFormat('E', 'tr_TR');
    final DateFormat dayNumberFormatter = DateFormat('d');

    return Column(
      children: [
        // Haftanın günlerini gösteren üst bar.
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) {
              final isSelectedDay = DateUtils.isSameDay(day, selectedDate);
              return GestureDetector(
                // Tıklandığında seçili tarihi güncelliyoruz.
                onTap: () =>
                    ref.read(selectedDateProvider.notifier).state = day,
                child: Column(
                  children: [
                    Text(
                      dayFormatter.format(day).substring(0, 1),
                      style: TextStyle(
                        color: isSelectedDay
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade600,
                        fontWeight:
                            isSelectedDay ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: isSelectedDay
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      child: Text(
                        dayNumberFormatter.format(day),
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelectedDay
                              ? Color.fromARGB(255, 5, 75, 228)
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1),
        // Seçili güne ait etkinlikleri gösteren liste.
        Expanded(
          child: allEventsAsyncValue.when(
            data: (allEvents) {
              final dailyEvents = allEvents.where((event) {
                return DateUtils.isSameDay(event.date, selectedDate);
              }).toList();
              dailyEvents.sort((a, b) => a.startTime.compareTo(b.startTime));

              if (dailyEvents.isEmpty) {
                return const Center(
                    child: Text('Bu gün için planlanmış etkinlik yok.',
                        style: TextStyle(color: Colors.grey, fontSize: 16)));
              }
              // Bu kısım günlük görünümdeki liste ile aynı olduğu için
              // oradaki DailyEventTile'ı kullanabiliriz.
              // Bu da kod tekrarını azaltır.
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: dailyEvents.length,
                itemBuilder: (context, index) {
                  final event = dailyEvents[index];
                  // DailyEventTile'ı burada yeniden kullanıyoruz.
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: _buildWeeklyEventCard(context, event),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text('Hata: ${err.toString()}')),
          ),
        ),
      ],
    );
  }

  // Haftalık görünüm için özel bir kart tasarımı.
  Widget _buildWeeklyEventCard(BuildContext context, Event event) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: event.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: event.color, width: 4)),
      ),
      child: Row(
        children: [
          Text(
            event.startTime,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
