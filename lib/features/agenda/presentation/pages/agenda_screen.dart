import 'package:card_swiper/card_swiper.dart'; // YENİ PAKET
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:momo_ajanda/features/agenda/application/agenda_providers.dart';
import 'package:momo_ajanda/features/agenda/models/event_model.dart';
import 'package:momo_ajanda/features/agenda/presentation/widgets/add_event_sheet.dart';
import 'package:momo_ajanda/features/agenda/presentation/widgets/agenda_page_view.dart';
import 'package:momo_ajanda/features/agenda/presentation/widgets/monthly_view.dart';
import 'package:momo_ajanda/features/agenda/presentation/widgets/weekly_view.dart';

class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _swiperController = SwiperController(); // YENİ KONTROLCÜ

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _swiperController.dispose();
    super.dispose();
  }

  void _showAddEventSheet() async {
    final selectedDate = ref.read(selectedDateProvider);
    final newEvent = await showModalBottomSheet<Event>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => AddEventSheet(selectedDate: selectedDate),
    );

    if (mounted && newEvent != null) {
      await ref.read(eventsProvider.notifier).addEvent(newEvent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);

    String getFormattedDate(DateTime date) {
      return DateFormat('d MMMM y, EEEE', 'tr_TR').format(date);
    }

    void goToToday() {
      // Swiper'ı bugünün tarihine getirmek için state'i güncellememiz yeterli.
      // AgendaPageView içindeki `ref.listen` bunu yakalayıp Swiper'ı hareket ettirecek.
      ref.read(selectedDateProvider.notifier).state = DateTime.now();
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                getFormattedDate(selectedDate),
                style: Theme.of(context).textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(onPressed: goToToday, child: const Text('Bugün')),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Günlük'),
            Tab(text: 'Haftalık'),
            Tab(text: 'Aylık'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // KONTROLCÜYÜ YENİ WIDGET'A İLETİYORUZ
          AgendaPageView(swiperController: _swiperController),
          const WeeklyView(),
          MonthlyView(tabController: _tabController),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
