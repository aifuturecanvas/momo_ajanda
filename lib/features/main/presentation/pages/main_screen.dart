import 'package:flutter/material.dart';
import 'package:momo_ajanda/features/agenda/presentation/pages/agenda_screen.dart';
import 'package:momo_ajanda/features/assistant/presentation/pages/assistant_screen.dart';
import 'package:momo_ajanda/features/notes/presentation/pages/notes_screen.dart';
import 'package:momo_ajanda/features/profile/presentation/pages/profile_screen.dart';
import 'package:momo_ajanda/features/reminders/presentation/pages/reminders_screen.dart';
import 'package:momo_ajanda/features/tasks/presentation/pages/tasks_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // 6 sekmeli ekran listesi
  static const List<Widget> _screens = <Widget>[
    AgendaScreen(),
    TasksScreen(),
    RemindersScreen(), // YENİ EKLENEN
    NotesScreen(),
    AssistantScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
                _buildNavItem(2, Icons.notifications_outlined,
                    Icons.notifications, 'Hatırlat'),
                _buildNavItem(
                    3, Icons.description_outlined, Icons.description, 'Notlar'),
                _buildNavItem(
                    4, Icons.smart_toy_outlined, Icons.smart_toy, 'Momo'),
                _buildNavItem(5, Icons.person_outline, Icons.person, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    final color =
        isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
