import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/features/agenda/application/agenda_providers.dart';
import 'package:momo_ajanda/features/agenda/models/event_model.dart';
import 'package:table_calendar/table_calendar.dart';

class MonthlyView extends ConsumerWidget {
  final TabController tabController;

  const MonthlyView({super.key, required this.tabController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final eventsAsync = ref.watch(eventsProvider);

    return eventsAsync.when(
      data: (events) {
        return TableCalendar<Event>(
          locale: 'tr_TR',
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: selectedDate,
          selectedDayPredicate: (day) => isSameDay(selectedDate, day),
          onDaySelected: (newSelectedDay, newFocusedDay) {
            ref.read(selectedDateProvider.notifier).state = newSelectedDay;
            // Kullanıcı bir güne tıkladığında otomatik olarak Günlük sekmesine geç.
            tabController.animateTo(0);
          },
          eventLoader: (day) {
            return events.where((event) => isSameDay(event.date, day)).toList();
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return Positioned(
                  right: 1,
                  bottom: 1,
                  child: _buildEventsMarker(context, events),
                );
              }
              return null;
            },
          ),
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false, // 2 Hafta/Hafta butonunu gizle
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Hata: ${err.toString()}')),
    );
  }

  Widget _buildEventsMarker(BuildContext context, List<dynamic> events) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${events.length}',
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ),
    );
  }
}
