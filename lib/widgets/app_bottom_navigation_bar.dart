import 'package:flutter/material.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final List<AppBottomNavItem> items;
  final ValueChanged<int> onSelected;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var index = 0; index < items.length; index++)
                _AppBottomNavButton(
                  item: items[index],
                  isSelected: currentIndex == index,
                  onTap: () => onSelected(index),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppBottomNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String semanticsLabel;

  const AppBottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.semanticsLabel,
  });
}

class _AppBottomNavButton extends StatelessWidget {
  final AppBottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _AppBottomNavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: item.semanticsLabel,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.deepPurple.withValues(alpha: 0.2),
                          Colors.deepPurple.withValues(alpha: 0.1),
                          Colors.purple.withValues(alpha: 0.05),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      )
                    : null,
                borderRadius: BorderRadius.circular(24),
                border: isSelected
                    ? Border.all(
                        color: Colors.deepPurple.withValues(alpha: 0.2),
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
                                color: Colors.deepPurple.withValues(alpha: 0.6),
                                blurRadius: 16,
                                spreadRadius: 3,
                                offset: const Offset(0, 5),
                              ),
                              BoxShadow(
                                color: Colors.purple.withValues(alpha: 0.4),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: const Offset(0, 3),
                              ),
                              BoxShadow(
                                color: Colors.deepPurple.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.15),
                                blurRadius: 6,
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
                                  Colors.white.withValues(alpha: 0.2),
                                  Colors.white.withValues(alpha: 0.1),
                                ],
                              ),
                              shape: BoxShape.circle,
                            )
                          : null,
                      child: Icon(
                        isSelected ? item.selectedIcon : item.icon,
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
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isSelected
                          ? Colors.deepPurple.shade800
                          : Colors.grey.shade700,
                      letterSpacing: isSelected ? 0.5 : 0.3,
                      height: 1.2,
                    ),
                    child: Text(
                      item.label,
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
      ),
    );
  }
}
