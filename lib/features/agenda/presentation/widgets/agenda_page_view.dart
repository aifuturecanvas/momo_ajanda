import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/features/agenda/application/agenda_providers.dart';
import 'package:momo_ajanda/features/agenda/presentation/widgets/daily_event_tile.dart';
import 'package:momo_ajanda/features/agenda/presentation/widgets/daily_summary_card.dart';

class AgendaPageView extends ConsumerWidget {
  final SwiperController swiperController;
  const AgendaPageView({super.key, required this.swiperController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tarih dışarıdan değiştiğinde (Bugün butonu, takvim vb.) Swiper'ı da hareket ettir.
    ref.listen<DateTime>(selectedDateProvider, (previous, next) {
      if (previous != null && !DateUtils.isSameDay(previous, next)) {
        final today = DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day);
        final difference = next.difference(today).inDays;
        swiperController.move(1000 + difference);
      }
    });

    final allEventsAsync = ref.watch(eventsProvider);

    return allEventsAsync.when(
      data: (allEvents) {
        return Swiper(
          controller: swiperController,
          loop: true,
          index: 1000, // Ortadan başlamak için yüksek bir değer
          onIndexChanged: (index) {
            final newDate = DateTime.now().add(Duration(days: index - 1000));
            // addPostFrameCallback, build işlemi bittikten sonra state güncellemesi
            // yaparak "setState() or markNeedsBuild() called during build" hatasını önler.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(selectedDateProvider.notifier).state = newDate;
            });
          },
          itemBuilder: (context, index) {
            final date = DateTime.now().add(Duration(days: index - 1000));
            final dailyEvents = allEvents
                .where((event) => DateUtils.isSameDay(event.date, date))
                .toList()
              ..sort((a, b) => a.startTime.compareTo(b.startTime));

            // Her bir gün için oluşturulan sayfa içeriği
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const DailySummaryCard(),
                const SizedBox(height: 16),
                if (dailyEvents.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(
                      child: Text(
                        'Bugün için planlanmış etkinlik yok.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  )
                else
                  ...dailyEvents
                      .map((event) => DailyEventTile(event: event))
                      .toList(),
              ],
            );
          },
          itemCount: 2000, // İleri ve geri gitmek için geniş bir aralık
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Hata: ${err.toString()}')),
    );
  }
}
