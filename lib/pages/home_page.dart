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
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.deepPurple.withOpacity(0.2),
                        Colors.deepPurple.withOpacity(0.1),
                        Colors.purple.withOpacity(0.05),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    )
                  : null,
              borderRadius: BorderRadius.circular(24),
              border: isSelected
                  ? Border.all(
                      color: Colors.deepPurple.withOpacity(0.2),
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  padding: EdgeInsets.all(isSelected ? 10 : 7),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.deepPurple.shade300,
                              Colors.deepPurple.shade500,
                              Colors.deepPurple.shade700,
                              Colors.purple.shade600,
                            ],
                            stops: const [0.0, 0.3, 0.7, 1.0],
                          )
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.grey.shade100, Colors.white],
                          ),
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.6),
                              blurRadius: 16,
                              spreadRadius: 3,
                              offset: const Offset(0, 5),
                            ),
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: const Offset(0, 3),
                            ),
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.2),
                              blurRadius: 6,
                              spreadRadius: 0,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 6,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Container(
                    decoration: isSelected
                        ? BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            shape: BoxShape.circle,
                          )
                        : null,
                    child: Icon(
                      isSelected ? selectedIcon : icon,
                      size: isSelected ? 28 : 24,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isSelected ? 12.5 : 11.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? Colors.deepPurple.shade800
                        : Colors.grey.shade700,
                    letterSpacing: isSelected ? 0.5 : 0.3,
                    height: 1.2,
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
