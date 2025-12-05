import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/features/achievements/application/achievement_providers.dart';
import 'package:momo_ajanda/features/achievements/models/achievement.dart';
import 'package:momo_ajanda/features/achievements/presentation/widgets/achievement_card.dart';
import 'package:momo_ajanda/features/achievements/presentation/widgets/level_progress.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAchievements = ref.watch(userAchievementsProvider);
    final level = ref.watch(userLevelProvider);
    final totalXp = ref.watch(totalXpProvider);
    final unlockedCount = ref.watch(unlockedCountProvider);

    return DefaultTabController(
      length: AchievementCategory.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Başarılar'),
          bottom: TabBar(
            isScrollable: true,
            tabs: AchievementCategory.values.map((category) {
              final categoryAchievements =
                  AchievementDefinitions.getByCategory(category);
              final unlockedInCategory = categoryAchievements.where((a) {
                final userA = userAchievements[a.id];
                return userA?.isUnlocked ?? false;
              }).length;

              return Tab(
                child: Row(
                  children: [
                    Icon(category.icon, size: 18),
                    const SizedBox(width: 6),
                    Text(category.label),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: unlockedInCategory == categoryAchievements.length
                            ? Colors.green
                            : Theme.of(context).primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unlockedInCategory/${categoryAchievements.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color:
                              unlockedInCategory == categoryAchievements.length
                                  ? Colors.white
                                  : Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        body: Column(
          children: [
            // Seviye kartı
            Padding(
              padding: const EdgeInsets.all(16),
              child: LevelProgressCard(
                level: level,
                totalXp: totalXp,
                unlockedCount: unlockedCount,
                totalCount: AchievementDefinitions.all.length,
              ),
            ),

            // Rozetler
            Expanded(
              child: TabBarView(
                children: AchievementCategory.values.map((category) {
                  final achievements =
                      AchievementDefinitions.getByCategory(category);

                  // Önce açıkları, sonra kilitlileri göster
                  achievements.sort((a, b) {
                    final aUnlocked =
                        userAchievements[a.id]?.isUnlocked ?? false;
                    final bUnlocked =
                        userAchievements[b.id]?.isUnlocked ?? false;
                    if (aUnlocked && !bUnlocked) return -1;
                    if (!aUnlocked && bUnlocked) return 1;
                    return a.tier.index.compareTo(b.tier.index);
                  });

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: achievements.length,
                    itemBuilder: (context, index) {
                      final achievement = achievements[index];
                      final userProgress = userAchievements[achievement.id];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AchievementCard(
                          achievement: achievement,
                          userProgress: userProgress,
                          onTap: () => _showAchievementDetails(
                            context,
                            achievement,
                            userProgress,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetails(
    BuildContext context,
    Achievement achievement,
    UserAchievement? userProgress,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AchievementDetailsSheet(
        achievement: achievement,
        userProgress: userProgress,
      ),
    );
  }
}

class _AchievementDetailsSheet extends StatelessWidget {
  final Achievement achievement;
  final UserAchievement? userProgress;

  const _AchievementDetailsSheet({
    required this.achievement,
    this.userProgress,
  });

  bool get isUnlocked => userProgress?.isUnlocked ?? false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rozet
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isUnlocked
                  ? LinearGradient(colors: achievement.tier.gradient)
                  : null,
              color: isUnlocked ? null : Colors.grey.shade200,
            ),
            child: Center(
              child: Text(
                achievement.emoji,
                style: TextStyle(
                  fontSize: 40,
                  color: isUnlocked ? null : Colors.grey.shade400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Seviye etiketi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: achievement.tier.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              achievement.tier.label,
              style: TextStyle(
                color: achievement.tier.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Başlık
          Text(
            achievement.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Açıklama
          Text(
            achievement.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),

          // İlerleme veya açılma tarihi
          if (isUnlocked && userProgress?.unlockedAt != null)
            Text(
              'Açıldı: ${_formatDate(userProgress!.unlockedAt!)}',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            )
          else if (!isUnlocked) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${userProgress?.currentValue ?? 0}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: achievement.tier.color,
                  ),
                ),
                Text(
                  ' / ${achievement.targetValue}',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // XP bilgisi
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                '${achievement.tier.xpValue} XP',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}
