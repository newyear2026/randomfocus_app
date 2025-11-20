import 'package:flutter/material.dart';
import 'roulette_page.dart';
import 'history_page.dart';
import 'settings_page.dart';
import '../services/app_localizations.dart';

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
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  icon: Icons.casino_outlined,
                  selectedIcon: Icons.casino,
                  label: AppLocalizations.of(context)?.wheel ?? 'Wheel',
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  icon: Icons.history_outlined,
                  selectedIcon: Icons.history,
                  label: AppLocalizations.of(context)?.history ?? 'History',
                ),
                _buildNavItem(
                  context,
                  index: 2,
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: AppLocalizations.of(context)?.settings ?? 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentIndex = index;
            });
            // 히스토리 탭을 선택하면 히스토리 페이지 새로고침
            if (index == 1) {
              final historyState = _historyPageKey.currentState;
              if (historyState != null) {
                (historyState as dynamic).refresh();
              }
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.deepPurple.withOpacity(0.15),
                        Colors.deepPurple.withOpacity(0.08),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutCubic,
                  padding: EdgeInsets.all(isSelected ? 7 : 5),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.deepPurple,
                              Colors.deepPurple.shade600,
                            ],
                          )
                        : null,
                    color: !isSelected ? Colors.transparent : null,
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isSelected ? selectedIcon : icon,
                    size: isSelected ? 24 : 22,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isSelected ? 11.5 : 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.deepPurple
                        : Colors.grey.shade600,
                    letterSpacing: 0.3,
                    height: 1.1,
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
