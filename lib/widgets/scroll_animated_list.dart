import 'package:flutter/material.dart';

/// 스크롤 시 아래에서 위로 올라오는 애니메이션을 가진 리스트 아이템
class ScrollAnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final ScrollController scrollController;

  const ScrollAnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    required this.scrollController,
  });

  @override
  State<ScrollAnimatedListItem> createState() => _ScrollAnimatedListItemState();
}

class _ScrollAnimatedListItemState extends State<ScrollAnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // 스크롤 리스너 추가
    widget.scrollController.addListener(_onScroll);

    // 초기 로드 시 첫 번째 항목은 즉시 애니메이션
    if (widget.index == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.forward();
          _hasAnimated = true;
        }
      });
    }
  }

  void _onScroll() {
    if (_hasAnimated) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;

    // 화면에 보이기 시작하면 애니메이션 시작
    if (position.dy < screenHeight * 0.8) {
      _controller.forward();
      _hasAnimated = true;
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
    );
  }
}
