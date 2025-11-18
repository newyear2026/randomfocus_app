import 'package:flutter/material.dart';
import 'roulette_page.dart';
import 'history_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const RoulettePage(),
    const HistoryPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          indicatorColor: Colors.deepPurple.withOpacity(0.2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 70,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.casino_outlined, size: 26),
              selectedIcon: Icon(Icons.casino, size: 26),
              label: 'Wheel',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined, size: 26),
              selectedIcon: Icon(Icons.history, size: 26),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, size: 26),
              selectedIcon: Icon(Icons.settings, size: 26),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

