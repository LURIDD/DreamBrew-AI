import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Yıldızlı arka plan oluşturan CustomPainter.
/// Onboarding ve diğer mistik ekranlarda kullanılır.
class StarBackgroundPainter extends CustomPainter {
  final List<_Star> _stars;

  StarBackgroundPainter({int starCount = 80, int seed = 42})
    : _stars = _generateStars(starCount, seed);

  static List<_Star> _generateStars(int count, int seed) {
    final random = math.Random(seed);
    return List.generate(count, (_) {
      return _Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: random.nextDouble() * 1.8 + 0.3,
        opacity: random.nextDouble() * 0.6 + 0.2,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final star in _stars) {
      paint.color = AppColors.starColor.withValues(alpha: star.opacity);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Star {
  final double x;
  final double y;
  final double radius;
  final double opacity;

  const _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
  });
}

/// Yıldızlı arka planı saran widget.
/// [child] ile üstüne içerik yerleştirilir.
class StarBackground extends StatelessWidget {
  final Widget child;
  final int starCount;

  const StarBackground({super.key, required this.child, this.starCount = 80});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Arka plan gradyantı
        Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
        ),
        // Yıldız katmanı
        CustomPaint(
          painter: StarBackgroundPainter(starCount: starCount),
          size: Size.infinite,
        ),
        // İçerik
        child,
      ],
    );
  }
}
