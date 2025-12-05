import 'package:flutter/material.dart';

/// Rozet kategorileri
enum AchievementCategory {
  tasks, // Görev rozetleri
  streak, // Süreklilik rozetleri
  pomodoro, // Odaklanma rozetleri
  reminders, // Hatırlatıcı rozetleri
  special, // Özel rozetler
}

extension AchievementCategoryExtension on AchievementCategory {
  String get label {
    switch (this) {
      case AchievementCategory.tasks:
        return 'Görevler';
      case AchievementCategory.streak:
        return 'Süreklilik';
      case AchievementCategory.pomodoro:
        return 'Odaklanma';
      case AchievementCategory.reminders:
        return 'Hatırlatıcılar';
      case AchievementCategory.special:
        return 'Özel';
    }
  }

  IconData get icon {
    switch (this) {
      case AchievementCategory.tasks:
        return Icons.task_alt;
      case AchievementCategory.streak:
        return Icons.local_fire_department;
      case AchievementCategory.pomodoro:
        return Icons.timer;
      case AchievementCategory.reminders:
        return Icons.notifications_active;
      case AchievementCategory.special:
        return Icons.star;
    }
  }

  Color get color {
    switch (this) {
      case AchievementCategory.tasks:
        return Colors.blue;
      case AchievementCategory.streak:
        return Colors.orange;
      case AchievementCategory.pomodoro:
        return Colors.red;
      case AchievementCategory.reminders:
        return Colors.purple;
      case AchievementCategory.special:
        return Colors.amber;
    }
  }
}

/// Rozet seviyesi
enum AchievementTier {
  bronze, // Bronz
  silver, // Gümüş
  gold, // Altın
  platinum, // Platin
  diamond, // Elmas
}

extension AchievementTierExtension on AchievementTier {
  String get label {
    switch (this) {
      case AchievementTier.bronze:
        return 'Bronz';
      case AchievementTier.silver:
        return 'Gümüş';
      case AchievementTier.gold:
        return 'Altın';
      case AchievementTier.platinum:
        return 'Platin';
      case AchievementTier.diamond:
        return 'Elmas';
    }
  }

  Color get color {
    switch (this) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.platinum:
        return const Color(0xFFE5E4E2);
      case AchievementTier.diamond:
        return const Color(0xFFB9F2FF);
    }
  }

  List<Color> get gradient {
    switch (this) {
      case AchievementTier.bronze:
        return [const Color(0xFFCD7F32), const Color(0xFF8B4513)];
      case AchievementTier.silver:
        return [const Color(0xFFE8E8E8), const Color(0xFFA8A8A8)];
      case AchievementTier.gold:
        return [const Color(0xFFFFD700), const Color(0xFFFF8C00)];
      case AchievementTier.platinum:
        return [const Color(0xFFE5E4E2), const Color(0xFF9090A0)];
      case AchievementTier.diamond:
        return [const Color(0xFFB9F2FF), const Color(0xFF00CED1)];
    }
  }

  int get xpValue {
    switch (this) {
      case AchievementTier.bronze:
        return 10;
      case AchievementTier.silver:
        return 25;
      case AchievementTier.gold:
        return 50;
      case AchievementTier.platinum:
        return 100;
      case AchievementTier.diamond:
        return 200;
    }
  }
}

/// Rozet tanımı
class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final AchievementCategory category;
  final AchievementTier tier;
  final int targetValue;
  final bool isSecret;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.category,
    required this.tier,
    required this.targetValue,
    this.isSecret = false,
  });
}

/// Kullanıcının rozet ilerlemesi
class UserAchievement {
  final String odAchievementId;
  final int currentValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const UserAchievement({
    required this.odAchievementId,
    this.currentValue = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  double get progress {
    final achievement = AchievementDefinitions.getById(odAchievementId);
    if (achievement == null) return 0;
    return (currentValue / achievement.targetValue).clamp(0.0, 1.0);
  }

  UserAchievement copyWith({
    int? currentValue,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return UserAchievement(
      odAchievementId: odAchievementId,
      currentValue: currentValue ?? this.currentValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'achievementId': odAchievementId,
      'currentValue': currentValue,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      odAchievementId: json['achievementId'] ?? '',
      currentValue: json['currentValue'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.tryParse(json['unlockedAt'])
          : null,
    );
  }
}

/// Tüm rozet tanımları
class AchievementDefinitions {
  static const List<Achievement> all = [
    // === GÖREV ROZETLERİ ===
    Achievement(
      id: 'first_task',
      title: 'İlk Adım',
      description: 'İlk görevini tamamla',
      emoji: '🎯',
      category: AchievementCategory.tasks,
      tier: AchievementTier.bronze,
      targetValue: 1,
    ),
    Achievement(
      id: 'task_10',
      title: 'Görev Avcısı',
      description: '10 görev tamamla',
      emoji: '✅',
      category: AchievementCategory.tasks,
      tier: AchievementTier.bronze,
      targetValue: 10,
    ),
    Achievement(
      id: 'task_50',
      title: 'Görev Ustası',
      description: '50 görev tamamla',
      emoji: '🏅',
      category: AchievementCategory.tasks,
      tier: AchievementTier.silver,
      targetValue: 50,
    ),
    Achievement(
      id: 'task_100',
      title: 'Görev Şampiyonu',
      description: '100 görev tamamla',
      emoji: '🏆',
      category: AchievementCategory.tasks,
      tier: AchievementTier.gold,
      targetValue: 100,
    ),
    Achievement(
      id: 'task_500',
      title: 'Görev Efsanesi',
      description: '500 görev tamamla',
      emoji: '👑',
      category: AchievementCategory.tasks,
      tier: AchievementTier.diamond,
      targetValue: 500,
    ),

    // === SÜREKLİLİK ROZETLERİ ===
    Achievement(
      id: 'streak_3',
      title: 'İyi Başlangıç',
      description: '3 gün üst üste görev tamamla',
      emoji: '🔥',
      category: AchievementCategory.streak,
      tier: AchievementTier.bronze,
      targetValue: 3,
    ),
    Achievement(
      id: 'streak_7',
      title: 'Haftalık Savaşçı',
      description: '7 gün üst üste görev tamamla',
      emoji: '💪',
      category: AchievementCategory.streak,
      tier: AchievementTier.silver,
      targetValue: 7,
    ),
    Achievement(
      id: 'streak_14',
      title: 'Kararlı',
      description: '14 gün üst üste görev tamamla',
      emoji: '⚡',
      category: AchievementCategory.streak,
      tier: AchievementTier.gold,
      targetValue: 14,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Durdurulamaz',
      description: '30 gün üst üste görev tamamla',
      emoji: '🌟',
      category: AchievementCategory.streak,
      tier: AchievementTier.platinum,
      targetValue: 30,
    ),
    Achievement(
      id: 'streak_100',
      title: 'Efsane',
      description: '100 gün üst üste görev tamamla',
      emoji: '💎',
      category: AchievementCategory.streak,
      tier: AchievementTier.diamond,
      targetValue: 100,
    ),

    // === POMODORO ROZETLERİ ===
    Achievement(
      id: 'pomodoro_1',
      title: 'Odaklanmaya Başla',
      description: 'İlk pomodoro oturumunu tamamla',
      emoji: '🍅',
      category: AchievementCategory.pomodoro,
      tier: AchievementTier.bronze,
      targetValue: 1,
    ),
    Achievement(
      id: 'pomodoro_10',
      title: 'Odaklı Zihin',
      description: '10 pomodoro oturumu tamamla',
      emoji: '🧠',
      category: AchievementCategory.pomodoro,
      tier: AchievementTier.silver,
      targetValue: 10,
    ),
    Achievement(
      id: 'pomodoro_50',
      title: 'Odaklanma Ustası',
      description: '50 pomodoro oturumu tamamla',
      emoji: '🎯',
      category: AchievementCategory.pomodoro,
      tier: AchievementTier.gold,
      targetValue: 50,
    ),
    Achievement(
      id: 'focus_hours_10',
      title: 'Zamana Hükmet',
      description: '10 saat odaklanma süresine ulaş',
      emoji: '⏰',
      category: AchievementCategory.pomodoro,
      tier: AchievementTier.gold,
      targetValue: 600, // dakika
    ),

    // === HATIRLATICI ROZETLERİ ===
    Achievement(
      id: 'reminder_10',
      title: 'Hatırlatıcı Sever',
      description: '10 hatırlatıcı oluştur',
      emoji: '🔔',
      category: AchievementCategory.reminders,
      tier: AchievementTier.bronze,
      targetValue: 10,
    ),
    Achievement(
      id: 'reminder_ontime_10',
      title: 'Dakik',
      description: '10 hatırlatıcıyı zamanında tamamla',
      emoji: '⏱️',
      category: AchievementCategory.reminders,
      tier: AchievementTier.silver,
      targetValue: 10,
    ),

    // === ÖZEL ROZETLER ===
    Achievement(
      id: 'early_bird',
      title: 'Erken Kuş',
      description: 'Sabah 6\'dan önce görev tamamla',
      emoji: '🌅',
      category: AchievementCategory.special,
      tier: AchievementTier.silver,
      targetValue: 1,
      isSecret: true,
    ),
    Achievement(
      id: 'night_owl',
      title: 'Gece Kuşu',
      description: 'Gece 12\'den sonra görev tamamla',
      emoji: '🦉',
      category: AchievementCategory.special,
      tier: AchievementTier.silver,
      targetValue: 1,
      isSecret: true,
    ),
    Achievement(
      id: 'weekend_warrior',
      title: 'Hafta Sonu Savaşçısı',
      description: 'Hafta sonunda 5 görev tamamla',
      emoji: '🗓️',
      category: AchievementCategory.special,
      tier: AchievementTier.silver,
      targetValue: 5,
    ),
    Achievement(
      id: 'perfectionist',
      title: 'Mükemmeliyetçi',
      description: 'Bir günde tüm görevlerini tamamla (en az 5)',
      emoji: '💯',
      category: AchievementCategory.special,
      tier: AchievementTier.gold,
      targetValue: 1,
    ),
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Achievement> getByCategory(AchievementCategory category) {
    return all.where((a) => a.category == category).toList();
  }
}
