import 'package:flutter/material.dart';

class QuickActionsCard extends StatelessWidget {
  final Function(QuickActionType) onActionTap;

  const QuickActionsCard({
    super.key,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Hızlı Eylemler',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _ActionButton(
                  icon: Icons.note_add,
                  label: 'Not',
                  color: Colors.blue,
                  onTap: () => onActionTap(QuickActionType.note),
                ),
                _ActionButton(
                  icon: Icons.add_task,
                  label: 'Görev',
                  color: Colors.green,
                  onTap: () => onActionTap(QuickActionType.task),
                ),
                _ActionButton(
                  icon: Icons.alarm_add,
                  label: 'Hatırlat',
                  color: Colors.orange,
                  onTap: () => onActionTap(QuickActionType.reminder),
                ),
                _ActionButton(
                  icon: Icons.timer,
                  label: 'Odaklan',
                  color: Colors.red,
                  onTap: () => onActionTap(QuickActionType.pomodoro),
                ),
                _ActionButton(
                  icon: Icons.bar_chart,
                  label: 'Rapor',
                  color: Colors.purple,
                  onTap: () => onActionTap(QuickActionType.report),
                ),
                _ActionButton(
                  icon: Icons.settings,
                  label: 'Ayarlar',
                  color: Colors.grey,
                  onTap: () => onActionTap(QuickActionType.settings),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: color.withOpacity(isDark ? 0.2 : 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 70,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum QuickActionType {
  note,
  task,
  reminder,
  pomodoro,
  report,
  settings,
}
