import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Material 3 NavigationBar 규칙을 따르는 하단 탭 바.
///
/// 선택 상태는 아이콘 뒤의 알약 인디케이터로만 표현한다. 아이콘 크기나
/// 패딩을 바꾸면 탭을 옮길 때마다 바 높이가 흔들리므로 크기는 고정한다.
class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final List<AppBottomNavItem> items;
  final ValueChanged<int> onSelected;

  /// 라벨 영역까지 포함한 고정 높이. 선택 상태와 무관하게 유지된다.
  static const double barHeight = 64;

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
        color: AppColors.surface(context),
        border: Border(top: BorderSide(color: AppColors.subtleBorder(context))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: barHeight,
          child: Row(
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
    final accent = AppColors.accentStrong(context);
    final muted = AppColors.textMuted(context);

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: item.semanticsLabel,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 인디케이터만 애니메이션한다. 아이콘 크기는 32px로 고정이라
                // 선택이 바뀌어도 이 열의 높이는 변하지 않는다.
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: 56,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accent.withValues(alpha: 0.16)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isSelected ? item.selectedIcon : item.icon,
                    size: 24,
                    color: isSelected ? accent : muted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: isSelected ? accent : muted,
                    height: 1.2,
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
