import 'package:flutter/material.dart';
import 'package:momo_ajanda/features/agenda/presentation/pages/agenda_screen.dart';
import 'package:momo_ajanda/features/assistant/presentation/pages/assistant_screen.dart';
import 'package:momo_ajanda/features/notes/presentation/pages/notes_screen.dart';
import 'package:momo_ajanda/features/profile/presentation/pages/profile_screen.dart';
import 'package:momo_ajanda/features/tasks/presentation/pages/tasks_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Hangi sekmenin seçili olduğunu takip eden değişken. 0, ilk sekme demek.
  int _selectedIndex = 0;

  // Navigasyon menüsündeki her bir sekmeye karşılık gelen ekranların listesi.
  static const List<Widget> _widgetOptions = <Widget>[
    AgendaScreen(),
    TasksScreen(),
    NotesScreen(),
    AssistantScreen(),
    ProfileScreen(),
  ];

  // Bir sekmeye tıklandığında bu fonksiyon çalışır.
  void _onItemTapped(int index) {
    // setState, Flutter'a ekranda bir şeyin değiştiğini ve
    // ekranı yeniden çizmesi gerektiğini söyler.
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body olarak, o an hangi sekme seçiliyse o ekranı gösteriyoruz.
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // Alt navigasyon menüsünü burada tanımlıyoruz.
      bottomNavigationBar: BottomNavigationBar(
        // Menüdeki ikon ve yazılar.
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Ajanda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            activeIcon: Icon(Icons.check_circle),
            label: 'Görevler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Notlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            activeIcon: Icon(Icons.smart_toy),
            label: 'Asistan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex, // Hangi sekmenin aktif olduğunu belirtir.
        onTap: _onItemTapped, // Tıklanma olayını yöneten fonksiyon.

        // Temamızdan renkleri alarak görünümü tasarıma uygun hale getiriyoruz.
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true, // Seçili olmayan etiketleri de göster.
        type: BottomNavigationBarType.fixed, // Menünün sabit kalmasını sağlar.
      ),
    );
  }
}
