import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/core/services/notification_service.dart';
import 'package:momo_ajanda/features/reminders/data/repositories/reminder_repository.dart';
import 'package:momo_ajanda/features/reminders/models/reminder_model.dart';
import 'package:uuid/uuid.dart';

// 1. ReminderRepository için provider.
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepository();
});

// 2. Hatırlatıcı listesini yöneten StateNotifierProvider.
final remindersProvider =
    StateNotifierProvider<RemindersNotifier, AsyncValue<List<Reminder>>>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return RemindersNotifier(repository);
});

// 3. Etiket filtresini yöneten StateProvider.
final reminderTagFilterProvider = StateProvider<String?>((ref) => null);

// 4. Filtrelenmiş hatırlatıcıları gösteren provider.
final filteredRemindersProvider = Provider<List<Reminder>>((ref) {
  final tagFilter = ref.watch(reminderTagFilterProvider);
  final remindersAsyncValue = ref.watch(remindersProvider);

  return remindersAsyncValue.maybeWhen(
    data: (reminders) {
      List<Reminder> filtered;

      if (tagFilter == null || tagFilter.isEmpty) {
        filtered = List.from(reminders);
      } else {
        filtered = reminders
            .where((reminder) => reminder.tags.contains(tagFilter))
            .toList();
      }

      filtered.sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        return a.dateTime.compareTo(b.dateTime);
      });

      return filtered;
    },
    orElse: () => [],
  );
});

// 5. Bugünün hatırlatıcılarını gösteren provider.
final todayRemindersProvider = Provider<List<Reminder>>((ref) {
  final remindersAsyncValue = ref.watch(remindersProvider);

  return remindersAsyncValue.maybeWhen(
    data: (reminders) {
      final now = DateTime.now();
      return reminders.where((reminder) {
        return reminder.dateTime.year == now.year &&
            reminder.dateTime.month == now.month &&
            reminder.dateTime.day == now.day &&
            !reminder.isCompleted;
      }).toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    },
    orElse: () => [],
  );
});

// 6. Yaklaşan hatırlatıcıları gösteren provider (önümüzdeki 7 gün).
final upcomingRemindersProvider = Provider<List<Reminder>>((ref) {
  final remindersAsyncValue = ref.watch(remindersProvider);

  return remindersAsyncValue.maybeWhen(
    data: (reminders) {
      final now = DateTime.now();
      final weekLater = now.add(const Duration(days: 7));

      return reminders.where((reminder) {
        return reminder.dateTime.isAfter(now) &&
            reminder.dateTime.isBefore(weekLater) &&
            !reminder.isCompleted;
      }).toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    },
    orElse: () => [],
  );
});

// 7. Gecikmiş hatırlatıcıları gösteren provider.
final overdueRemindersProvider = Provider<List<Reminder>>((ref) {
  final remindersAsyncValue = ref.watch(remindersProvider);

  return remindersAsyncValue.maybeWhen(
    data: (reminders) {
      return reminders.where((reminder) => reminder.isOverdue).toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    },
    orElse: () => [],
  );
});

// 8. Tüm benzersiz etiketleri gösteren provider.
final allTagsProvider = Provider<List<String>>((ref) {
  final remindersAsyncValue = ref.watch(remindersProvider);

  return remindersAsyncValue.maybeWhen(
    data: (reminders) {
      final tags = <String>{};
      for (final reminder in reminders) {
        tags.addAll(reminder.tags);
      }
      return tags.toList()..sort();
    },
    orElse: () => [],
  );
});

// 9. Hatırlatıcı istatistiklerini gösteren provider.
final reminderStatsProvider = Provider<ReminderStats>((ref) {
  final remindersAsyncValue = ref.watch(remindersProvider);

  return remindersAsyncValue.maybeWhen(
    data: (reminders) {
      final total = reminders.length;
      final completed = reminders.where((r) => r.isCompleted).length;
      final overdue = reminders.where((r) => r.isOverdue).length;
      final today = reminders.where((r) => r.isToday && !r.isCompleted).length;

      return ReminderStats(
        total: total,
        completed: completed,
        overdue: overdue,
        todayPending: today,
      );
    },
    orElse: () => ReminderStats(),
  );
});

/// Hatırlatıcı istatistikleri için veri sınıfı
class ReminderStats {
  final int total;
  final int completed;
  final int overdue;
  final int todayPending;

  ReminderStats({
    this.total = 0,
    this.completed = 0,
    this.overdue = 0,
    this.todayPending = 0,
  });

  double get completionRate => total == 0 ? 0 : completed / total;
}

// STATE NOTIFIER - Supabase entegre edilmiş versiyon
class RemindersNotifier extends StateNotifier<AsyncValue<List<Reminder>>> {
  final ReminderRepository _repository;
  final NotificationService _notificationService = NotificationService();

  RemindersNotifier(this._repository) : super(const AsyncLoading()) {
    loadReminders();
  }

  Future<void> loadReminders() async {
    try {
      state = const AsyncLoading();
      final reminders = await _repository.loadReminders();
      state = AsyncData(reminders);

      // Mevcut hatırlatıcılar için bildirimleri zamanla
      for (final reminder in reminders) {
        if (!reminder.isCompleted && !reminder.isOverdue) {
          await _scheduleNotification(reminder);
        }
      }
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> addReminder({
    required String title,
    String? description,
    required DateTime dateTime,
    ReminderPriority priority = ReminderPriority.medium,
    ReminderRepeat repeat = ReminderRepeat.none,
    List<String> tags = const [],
    String? linkedEventId,
    String? linkedTaskId,
    int minutesBefore = 15,
  }) async {
    try {
      final newReminder = Reminder(
        id: const Uuid().v4(),
        title: title,
        description: description,
        dateTime: dateTime,
        priority: priority,
        repeat: repeat,
        tags: tags,
        linkedEventId: linkedEventId,
        linkedTaskId: linkedTaskId,
        minutesBefore: minutesBefore,
      );

      // Önce Supabase'e ekle
      await _repository.addReminder(newReminder);

      // Başarılı olursa state'i güncelle
      final previousState = state.value ?? [];
      final updatedList = [...previousState, newReminder];
      updatedList.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      state = AsyncData(updatedList);

      // Bildirim zamanla
      await _scheduleNotification(newReminder);
    } catch (e) {
      // Hata olursa state'i tekrar yükle
      await loadReminders();
      rethrow;
    }
  }

  Future<void> _scheduleNotification(Reminder reminder) async {
    final notificationTime = reminder.dateTime.subtract(
      Duration(minutes: reminder.minutesBefore),
    );

    if (notificationTime.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: NotificationIdGenerator.fromString(reminder.id),
        title: '🔔 ${reminder.title}',
        body: reminder.description ?? 'Hatırlatıcı zamanı geldi!',
        scheduledDate: notificationTime,
        payload: reminder.id,
      );
    }
  }

  Future<void> updateReminder(Reminder updatedReminder) async {
    try {
      // Eski bildirimi iptal et
      await _notificationService.cancelNotification(
        NotificationIdGenerator.fromString(updatedReminder.id),
      );

      // Önce Supabase'de güncelle
      await _repository.updateReminder(updatedReminder);

      // Başarılı olursa state'i güncelle
      final previousState = state.value ?? [];
      final updatedList = previousState.map((reminder) {
        if (reminder.id == updatedReminder.id) {
          return updatedReminder;
        }
        return reminder;
      }).toList();

      updatedList.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      state = AsyncData(updatedList);

      // Yeni bildirimi zamanla
      if (!updatedReminder.isCompleted) {
        await _scheduleNotification(updatedReminder);
      }
    } catch (e) {
      // Hata olursa state'i tekrar yükle
      await loadReminders();
      rethrow;
    }
  }

  Future<void> toggleReminderStatus(String id) async {
    try {
      final previousState = state.value ?? [];
      final reminder = previousState.firstWhere((r) => r.id == id);
      final updatedReminder = reminder.copyWith(isCompleted: !reminder.isCompleted);

      // Önce Supabase'de güncelle
      await _repository.updateReminder(updatedReminder);

      // Başarılı olursa state'i güncelle
      final updatedList = previousState.map((r) {
        if (r.id == id) {
          return updatedReminder;
        }
        return r;
      }).toList();
      state = AsyncData(updatedList);

      // Tamamlandıysa bildirimi iptal et
      if (updatedReminder.isCompleted) {
        await _notificationService.cancelNotification(
          NotificationIdGenerator.fromString(id),
        );
      } else {
        await _scheduleNotification(updatedReminder);
      }
    } catch (e) {
      // Hata olursa state'i tekrar yükle
      await loadReminders();
      rethrow;
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      // Bildirimi iptal et
      await _notificationService.cancelNotification(
        NotificationIdGenerator.fromString(id),
      );

      // Önce Supabase'den sil
      await _repository.deleteReminder(id);

      // Başarılı olursa state'i güncelle
      final previousState = state.value ?? [];
      final updatedList =
          previousState.where((reminder) => reminder.id != id).toList();
      state = AsyncData(updatedList);
    } catch (e) {
      // Hata olursa state'i tekrar yükle
      await loadReminders();
      rethrow;
    }
  }

  Future<void> addTagToReminder(String id, String tag) async {
    try {
      final previousState = state.value ?? [];
      final reminder = previousState.firstWhere((r) => r.id == id);

      if (!reminder.tags.contains(tag)) {
        final updatedReminder = reminder.copyWith(tags: [...reminder.tags, tag]);

        // Önce Supabase'de güncelle
        await _repository.updateReminder(updatedReminder);

        // Başarılı olursa state'i güncelle
        final updatedList = previousState.map((r) {
          if (r.id == id) {
            return updatedReminder;
          }
          return r;
        }).toList();
        state = AsyncData(updatedList);
      }
    } catch (e) {
      // Hata olursa state'i tekrar yükle
      await loadReminders();
      rethrow;
    }
  }

  Future<void> removeTagFromReminder(String id, String tag) async {
    try {
      final previousState = state.value ?? [];
      final reminder = previousState.firstWhere((r) => r.id == id);
      final updatedReminder = reminder.copyWith(
        tags: reminder.tags.where((t) => t != tag).toList(),
      );

      // Önce Supabase'de güncelle
      await _repository.updateReminder(updatedReminder);

      // Başarılı olursa state'i güncelle
      final updatedList = previousState.map((r) {
        if (r.id == id) {
          return updatedReminder;
        }
        return r;
      }).toList();
      state = AsyncData(updatedList);
    } catch (e) {
      // Hata olursa state'i tekrar yükle
      await loadReminders();
      rethrow;
    }
  }

  Future<void> processRepeatingReminders() async {
    try {
      final previousState = state.value ?? [];
      final now = DateTime.now();
      bool hasChanges = false;

      final updatedList = <Reminder>[];

      for (final reminder in previousState) {
        if (reminder.isOverdue &&
            !reminder.isCompleted &&
            reminder.repeat != ReminderRepeat.none) {
          hasChanges = true;
          DateTime newDate = reminder.dateTime;

          while (newDate.isBefore(now)) {
            switch (reminder.repeat) {
              case ReminderRepeat.daily:
                newDate = newDate.add(const Duration(days: 1));
                break;
              case ReminderRepeat.weekly:
                newDate = newDate.add(const Duration(days: 7));
                break;
              case ReminderRepeat.monthly:
                newDate = DateTime(
                  newDate.year,
                  newDate.month + 1,
                  newDate.day,
                  newDate.hour,
                  newDate.minute,
                );
                break;
              case ReminderRepeat.yearly:
                newDate = DateTime(
                  newDate.year + 1,
                  newDate.month,
                  newDate.day,
                  newDate.hour,
                  newDate.minute,
                );
                break;
              case ReminderRepeat.none:
                break;
            }
          }

          final updatedReminder = reminder.copyWith(dateTime: newDate);
          updatedList.add(updatedReminder);

          // Supabase'de güncelle
          await _repository.updateReminder(updatedReminder);
        } else {
          updatedList.add(reminder);
        }
      }

      if (hasChanges) {
        updatedList.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        state = AsyncData(updatedList);

        // Güncellenmiş hatırlatıcılar için bildirimleri yeniden zamanla
        for (final reminder in updatedList) {
          if (!reminder.isCompleted && !reminder.isOverdue) {
            await _scheduleNotification(reminder);
          }
        }
      }
    } catch (e) {
      // Hata olursa state'i tekrar yükle
      await loadReminders();
      rethrow;
    }
  }
}
