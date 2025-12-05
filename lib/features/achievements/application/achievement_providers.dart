import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:momo_ajanda/features/achievements/models/achievement.dart';
import 'package:momo_ajanda/features/tasks/application/task_providers.dart';

/// Kullanıcı rozetleri provider'ı
final userAchievementsProvider = StateNotifierProvider<UserAchievementsNotifier,
    Map<String, UserAchievement>>((ref) {
  return UserAchievementsNotifier(ref);
});

/// Toplam XP provider'ı
final totalXpProvider = Provider<int>((ref) {
  final achievements = ref.watch(userAchievementsProvider);
  int totalXp = 0;

  for (final userAchievement in achievements.values) {
    if (userAchievement.isUnlocked) {
      final achievement =
          AchievementDefinitions.getById(userAchievement.odAchievementId);
      if (achievement != null) {
        totalXp += achievement.tier.xpValue;
      }
    }
  }

  return totalXp;
});

/// Seviye provider'ı
final userLevelProvider = Provider<UserLevel>((ref) {
  final xp = ref.watch(totalXpProvider);
  return UserLevel.fromXp(xp);
});

/// Kilidi açılmış rozet sayısı
final unlockedCountProvider = Provider<int>((ref) {
  final achievements = ref.watch(userAchievementsProvider);
  return achievements.values.where((a) => a.isUnlocked).length;
});

/// Son açılan rozet
final latestUnlockedProvider = StateProvider<Achievement?>((ref) => null);

/// Kullanıcı seviyesi
class UserLevel {
  final int level;
  final int currentXp;
  final int xpForNextLevel;
  final int xpInCurrentLevel;

  UserLevel({
    required this.level,
    required this.currentXp,
    required this.xpForNextLevel,
    required this.xpInCurrentLevel,
  });

  double get progress => xpInCurrentLevel / xpForNextLevel;

  String get title {
    if (level < 5) return 'Çaylak';
    if (level < 10) return 'Öğrenci';
    if (level < 20) return 'Uzman';
    if (level < 30) return 'Usta';
    if (level < 50) return 'Efsane';
    return 'Grandmaster';
  }

  factory UserLevel.fromXp(int totalXp) {
    int level = 1;
    int xpRequired = 50;
    int remainingXp = totalXp;

    while (remainingXp >= xpRequired) {
      remainingXp -= xpRequired;
      level++;
      xpRequired = (50 * (1 + level * 0.5)).toInt();
    }

    return UserLevel(
      level: level,
      currentXp: totalXp,
      xpForNextLevel: xpRequired,
      xpInCurrentLevel: remainingXp,
    );
  }
}

class UserAchievementsNotifier
    extends StateNotifier<Map<String, UserAchievement>> {
  final Ref _ref;
  static const _storageKey = 'user_achievements';

  UserAchievementsNotifier(this._ref) : super({}) {
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);

    if (data != null && data.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(data);
        final Map<String, UserAchievement> loaded = {};

        decoded.forEach((key, value) {
          loaded[key] = UserAchievement.fromJson(value);
        });

        state = loaded;
      } catch (_) {
        state = {};
      }
    }
  }

  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> toSave = {};

    state.forEach((key, value) {
      toSave[key] = value.toJson();
    });

    await prefs.setString(_storageKey, jsonEncode(toSave));
  }

  /// İlerlemeyi güncelle
  Future<Achievement?> updateProgress(String achievementId, int value) async {
    final achievement = AchievementDefinitions.getById(achievementId);
    if (achievement == null) return null;

    final current =
        state[achievementId] ?? UserAchievement(odAchievementId: achievementId);

    if (current.isUnlocked) return null; // Zaten açık

    final newValue = current.currentValue + value;
    final shouldUnlock = newValue >= achievement.targetValue;

    final updated = current.copyWith(
      currentValue: newValue,
      isUnlocked: shouldUnlock,
      unlockedAt: shouldUnlock ? DateTime.now() : null,
    );

    state = {...state, achievementId: updated};
    await _saveAchievements();

    if (shouldUnlock) {
      _ref.read(latestUnlockedProvider.notifier).state = achievement;
      return achievement;
    }

    return null;
  }

  /// Değeri ayarla (artır değil)
  Future<Achievement?> setValue(String achievementId, int value) async {
    final achievement = AchievementDefinitions.getById(achievementId);
    if (achievement == null) return null;

    final current =
        state[achievementId] ?? UserAchievement(odAchievementId: achievementId);

    if (current.isUnlocked) return null;

    final shouldUnlock = value >= achievement.targetValue;

    final updated = current.copyWith(
      currentValue: value,
      isUnlocked: shouldUnlock,
      unlockedAt: shouldUnlock ? DateTime.now() : null,
    );

    state = {...state, achievementId: updated};
    await _saveAchievements();

    if (shouldUnlock) {
      _ref.read(latestUnlockedProvider.notifier).state = achievement;
      return achievement;
    }

    return null;
  }

  /// Görev tamamlandığında
  Future<List<Achievement>> onTaskCompleted() async {
    final unlockedList = <Achievement>[];

    // Görev sayısı rozetleri
    final tasksAsync = _ref.read(tasksProvider);
    final completedCount = tasksAsync.maybeWhen(
      data: (tasks) => tasks.where((t) => t.isCompleted).length,
      orElse: () => 0,
    );

    final taskAchievements = [
      'first_task',
      'task_10',
      'task_50',
      'task_100',
      'task_500'
    ];
    for (final id in taskAchievements) {
      final result = await setValue(id, completedCount);
      if (result != null) unlockedList.add(result);
    }

    // Özel rozetler
    final hour = DateTime.now().hour;
    if (hour < 6) {
      final result = await updateProgress('early_bird', 1);
      if (result != null) unlockedList.add(result);
    }
    if (hour >= 0 && hour < 5) {
      final result = await updateProgress('night_owl', 1);
      if (result != null) unlockedList.add(result);
    }

    // Hafta sonu kontrolü
    final weekday = DateTime.now().weekday;
    if (weekday == 6 || weekday == 7) {
      final result = await updateProgress('weekend_warrior', 1);
      if (result != null) unlockedList.add(result);
    }

    return unlockedList;
  }

  /// Pomodoro tamamlandığında
  Future<Achievement?> onPomodoroCompleted() async {
    final achievements = ['pomodoro_1', 'pomodoro_10', 'pomodoro_50'];

    for (final id in achievements) {
      final current = state[id];
      final result = await updateProgress(id, 1);
      if (result != null) return result;
    }

    return null;
  }

  /// Streak güncelle
  Future<Achievement?> updateStreak(int streakDays) async {
    final streakAchievements = [
      'streak_3',
      'streak_7',
      'streak_14',
      'streak_30',
      'streak_100'
    ];

    for (final id in streakAchievements) {
      final result = await setValue(id, streakDays);
      if (result != null) return result;
    }

    return null;
  }
}
