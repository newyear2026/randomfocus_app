import 'package:flutter/material.dart';
import 'roulette_page.dart';
import 'history_page.dart';
import 'settings_page.dart';
import '../services/app_localizations.dart';
import '../widgets/app_bottom_navigation_bar.dart';

class HomePage extends StatefulWidget {
  final Function(Locale)? onLanguageChanged;

  const HomePage({super.key, this.onLanguageChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final GlobalKey _historyPageKey = GlobalKey();

  List<Widget> get _pages => [
    const RoulettePage(),
    HistoryPage(key: _historyPageKey),
    SettingsPage(onLanguageChanged: widget.onLanguageChanged),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          AppBottomNavItem(
            icon: Icons.casino_outlined,
            selectedIcon: Icons.casino,
            label: l10n?.wheel ?? 'Wheel',
            semanticsLabel: l10n?.openWheelTab ?? 'Open wheel tab',
          ),
          AppBottomNavItem(
            icon: Icons.history_outlined,
            selectedIcon: Icons.history,
            label: l10n?.history ?? 'History',
            semanticsLabel: l10n?.openHistoryTab ?? 'Open history tab',
          ),
          AppBottomNavItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: l10n?.settings ?? 'Settings',
            semanticsLabel: l10n?.openSettingsTab ?? 'Open settings tab',
          ),
        ],
        onSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            final historyState = _historyPageKey.currentState;
            if (historyState != null) {
              (historyState as dynamic).refresh();
            }
          }
        },
      ),
    );
  }
}
