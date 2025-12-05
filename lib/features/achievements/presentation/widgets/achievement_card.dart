import 'package:flutter/material.dart';
import 'package:momo_ajanda/features/achievements/models/achievement.dart';

/// Rozet kartı widget'ı
class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final UserAchievement? userProgress;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.userProgress,
    this.onTap,
  });

  bool get isUnlocked => userProgress?.isUnlocked ?? false;
  double get progress => userProgress?.progress ?? 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isUnlocked ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isUnlocked
            ? BorderSide(color: achievement.tier.color, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Rozet ikonu
              _AchievementBadge(
                emoji: achievement.emoji,
                tier: achievement.tier,
                isUnlocked: isUnlocked,
                isSecret: achievement.isSecret && !isUnlocked,
              ),
              const SizedBox(width: 16),

              // Bilgiler
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Text(
                      achievement.isSecret && !isUnlocked
                          ? '???'
                          : achievement.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? null : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Açıklama
                    Text(
                      achievement.isSecret && !isUnlocked
                          ? 'Gizli rozet'
                          : achievement.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    // İlerleme çubuğu
                    if (!isUnlocked && !achievement.isSecret) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  achievement.tier.color,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${userProgress?.currentValue ?? 0}/${achievement.targetValue}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // XP değeri
              if (isUnlocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: achievement.tier.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${achievement.tier.xpValue} XP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: achievement.tier.color,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rozet simgesi
class _AchievementBadge extends StatelessWidget {
  final String emoji;
  final AchievementTier tier;
  final bool isUnlocked;
  final bool isSecret;

  const _AchievementBadge({
    required this.emoji,
    required this.tier,
    required this.isUnlocked,
    required this.isSecret,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isUnlocked
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: tier.gradient,
              )
            : null,
        color: isUnlocked ? null : Colors.grey.shade200,
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: tier.color.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: isSecret
            ? Icon(Icons.lock, color: Colors.grey.shade400, size: 24)
            : Text(
                emoji,
                style: TextStyle(
                  fontSize: 28,
                  color: isUnlocked ? null : Colors.grey.shade400,
                ),
              ),
      ),
    );
  }
}

/// Rozet açıldı popup'ı
class AchievementUnlockedDialog extends StatelessWidget {
  final Achievement achievement;

  const AchievementUnlockedDialog({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Konfeti efekti
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),

            // Başlık
            const Text(
              'Rozet Açıldı!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Rozet
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: achievement.tier.gradient,
                ),
                boxShadow: [
                  BoxShadow(
                    color: achievement.tier.color.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  achievement.emoji,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Rozet adı
            Text(
              achievement.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Açıklama
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),

            // XP
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: achievement.tier.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    '+${achievement.tier.xpValue} XP',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: achievement.tier.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Kapat butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: achievement.tier.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Harika!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
