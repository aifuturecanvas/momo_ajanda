import 'package:flutter/material.dart';

/// Tamamlanan oturum göstergesi
class SessionIndicator extends StatelessWidget {
  final int completedSessions;
  final int sessionsUntilLongBreak;

  const SessionIndicator({
    super.key,
    required this.completedSessions,
    required this.sessionsUntilLongBreak,
  });

  @override
  Widget build(BuildContext context) {
    final currentCycle = completedSessions % sessionsUntilLongBreak;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(sessionsUntilLongBreak, (index) {
        final isCompleted = index < currentCycle;
        final isCurrent = index == currentCycle;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isCurrent ? 16 : 12,
            height: isCurrent ? 16 : 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? Theme.of(context).primaryColor
                  : isCurrent
                      ? Theme.of(context).primaryColor.withOpacity(0.5)
                      : Colors.grey.shade300,
              border: isCurrent
                  ? Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    )
                  : null,
            ),
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    size: 8,
                    color: Colors.white,
                  )
                : null,
          ),
        );
      }),
    );
  }
}

/// Oturum özet kartı
class SessionSummaryCard extends StatelessWidget {
  final int todaySessions;
  final int totalFocusMinutes;

  const SessionSummaryCard({
    super.key,
    required this.todaySessions,
    required this.totalFocusMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final hours = totalFocusMinutes ~/ 60;
    final minutes = totalFocusMinutes % 60;
    final timeText = hours > 0 ? '$hours sa $minutes dk' : '$minutes dk';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _SummaryItem(
                icon: Icons.local_fire_department,
                iconColor: Colors.orange,
                value: '$todaySessions',
                label: 'Bugün',
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey.shade300,
            ),
            Expanded(
              child: _SummaryItem(
                icon: Icons.timer,
                iconColor: Colors.blue,
                value: timeText,
                label: 'Odaklanma',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _SummaryItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
