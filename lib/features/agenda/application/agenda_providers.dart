import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/features/agenda/data/repositories/event_repository.dart';
import 'package:momo_ajanda/features/agenda/models/event_model.dart';

// 1. EventRepository için basit bir provider.
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});

// 2. Seçili tarihi tutan provider.
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// 3. Etkinlik listesini yöneten ana StateNotifierProvider'ımız.
final eventsProvider =
    StateNotifierProvider<EventsNotifier, AsyncValue<List<Event>>>((ref) {
  // Repository'yi dinleyerek Notifier'ı oluşturuyoruz.
  final repository = ref.watch(eventRepositoryProvider);
  return EventsNotifier(repository);
});

class EventsNotifier extends StateNotifier<AsyncValue<List<Event>>> {
  final EventRepository _repository;

  Event? _lastDeletedEvent;
  int? _lastDeletedIndex;

  EventsNotifier(this._repository) : super(const AsyncLoading()) {
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      // DÜZELTME: Hatalı olan _loadEvents() çağrısını, doğru olan loadEvents() olarak değiştiriyoruz.
      final events = await _repository.loadEvents();
      state = AsyncData(events);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> addEvent(Event newEvent) async {
    final currentState = state;
    if (currentState is AsyncData<List<Event>>) {
      final updatedList = [...currentState.value, newEvent];
      state = AsyncData(updatedList);
      await _repository.saveEvents(updatedList);
    }
  }

  Future<void> deleteEvent(Event eventToDelete) async {
    final currentState = state;
    if (currentState is AsyncData<List<Event>>) {
      final currentList = currentState.value;
      _lastDeletedIndex = currentList.indexOf(eventToDelete);
      _lastDeletedEvent = eventToDelete;

      final updatedList =
          currentList.where((event) => event.id != eventToDelete.id).toList();
      state = AsyncData(updatedList);
      await _repository.saveEvents(updatedList);
    }
  }

  Future<void> undoDelete() async {
    if (_lastDeletedEvent != null && _lastDeletedIndex != null) {
      final currentState = state;
      if (currentState is AsyncData<List<Event>>) {
        final currentList = currentState.value;
        currentList.insert(_lastDeletedIndex!, _lastDeletedEvent!);

        state = AsyncData(List.from(currentList));
        await _repository.saveEvents(state.value!);

        _lastDeletedEvent = null;
        _lastDeletedIndex = null;
      }
    }
  }
}
