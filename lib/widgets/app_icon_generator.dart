import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 룰렛 휠 앱 아이콘 생성 위젯
/// 
/// 이 위젯을 사용하여 룰렛 휠 모양의 앱 아이콘을 생성할 수 있습니다.
/// 
/// 사용 예시:
/// ```dart
/// AppIconGenerator(size: 1024)
/// ```
class AppIconGenerator extends StatelessWidget {
  final double size;
  final List<int> numbers;
  final List<Color> colors;
  final bool showBackground;

  const AppIconGenerator({
    super.key,
    this.size = 1024,
    this.numbers = const [5, 10, 10, 15, 20, 25],
    this.colors = const [
      Color(0xFFFF9800), // 주황색
      Color(0xFFEF4444), // 빨간색
      Color(0xFF10B981), // 청록색
      Color(0xFF6366F1), // 보라색
      Color(0xFF3B82F6), // 파란색
      Color(0xFFEC4899), // 분홍색
    ],
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _RouletteIconPainter(
        numbers: numbers,
        colors: colors,
        showBackground: showBackground,
      ),
    );
  }
}

class _RouletteIconPainter extends CustomPainter {
  final List<int> numbers;
  final List<Color> colors;
  final bool showBackground;

  _RouletteIconPainter({
    required this.numbers,
    required this.colors,
    this.showBackground = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;
    final sectionAngle = (2 * 3.14159) / numbers.length;

    // 배경 (보라색) - showBackground가 true일 때만 그리기
    if (showBackground) {
      paint.color = const Color(0xFF6366F1);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }

    // 각 섹션 그리기
    for (int i = 0; i < numbers.length; i++) {
      final startAngle = i * sectionAngle - 3.14159 / 2;
      final endAngle = (i + 1) * sectionAngle - 3.14159 / 2;

      // 섹션 채우기
      paint.color = colors[i % colors.length];
      paint.style = PaintingStyle.fill;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          endAngle - startAngle,
          false,
        )
        ..close();
      canvas.drawPath(path, paint);

      // 흰색 테두리
      paint.color = Colors.white;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = size.width * 0.02;
      canvas.drawPath(path, paint);
      paint.style = PaintingStyle.fill;

      // 숫자 텍스트
      final textAngle = startAngle + (endAngle - startAngle) / 2;
      final textRadius = radius * 0.7;
      final textX = center.dx + textRadius * math.cos(textAngle);
      final textY = center.dy + textRadius * math.sin(textAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${numbers[i]}',
          style: TextStyle(
            color: Colors.white,
            fontSize: size.width * 0.12,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          textX - textPainter.width / 2,
          textY - textPainter.height / 2,
        ),
      );
    }

    // 중앙 원
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.15, paint);

    // 외곽 테두리
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.03;
    canvas.drawCircle(center, radius, paint);

    // 상단 포인터
    final pointerPath = Path()
      ..moveTo(center.dx, center.dy - radius - size.width * 0.05)
      ..lineTo(center.dx - size.width * 0.03, center.dy - radius + size.width * 0.02)
      ..lineTo(center.dx + size.width * 0.03, center.dy - radius + size.width * 0.02)
      ..close();
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    canvas.drawPath(pointerPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


