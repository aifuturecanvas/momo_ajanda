import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/features/agenda/presentation/pages/agenda_screen.dart';
import 'package:momo_ajanda/features/momo_hub/presentation/pages/momo_hub_screen.dart';
import 'package:momo_ajanda/features/pomodoro/presentation/pages/pomodoro_screen.dart';
import 'package:momo_ajanda/features/profile/presentation/pages/profile_screen.dart';
import 'package:momo_ajanda/features/reminders/presentation/pages/reminders_screen.dart';
import 'package:momo_ajanda/features/tasks/presentation/pages/tasks_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  static const List<Widget> _screens = <Widget>[
    AgendaScreen(),
    TasksScreen(),
    MomoHubScreen(),
    RemindersScreen(),
    PomodoroScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedTabProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.calendar_today_outlined,
                    Icons.calendar_today, 'Ajanda'),
                _buildNavItem(1, Icons.check_circle_outline, Icons.check_circle,
                    'Görevler'),
                _buildMomoNavItem(2),
                _buildNavItem(3, Icons.notifications_outlined,
                    Icons.notifications, 'Hatırlat'),
                _buildNavItem(4, Icons.timer_outlined, Icons.timer, 'Odaklan'),
                _buildNavItem(5, Icons.person_outlined, Icons.person, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final selectedIndex = ref.watch(selectedTabProvider);
    final isSelected = selectedIndex == index;
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : Colors.grey.shade600;

    return InkWell(
      onTap: () => ref.read(selectedTabProvider.notifier).state = index,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMomoNavItem(int index) {
    final selectedIndex = ref.watch(selectedTabProvider);
    final isSelected = selectedIndex == index;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => ref.read(selectedTabProvider.notifier).state = index,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🌞',
              style: TextStyle(fontSize: isSelected ? 20 : 18),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Text(
                'Momo',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
