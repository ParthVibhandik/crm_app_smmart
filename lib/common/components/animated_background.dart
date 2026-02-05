import 'dart:math';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Orb> _orbs = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    for (int i = 0; i < 5; i++) {
      _orbs.add(Orb(
        color: i % 2 == 0 ? ColorResources.neonCyan : ColorResources.electricPurple,
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 150 + 50,
        speedX: _random.nextDouble() * 0.2 - 0.1,
        speedY: _random.nextDouble() * 0.2 - 0.1,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorResources.voidBackground,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: BackgroundPainter(
                orbs: _orbs,
                progress: _controller.value,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

class Orb {
  Color color;
  double x;
  double y;
  double size;
  double speedX;
  double speedY;

  Orb({
    required this.color,
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
  });

  void move() {
    x += speedX * 0.01;
    y += speedY * 0.01;

    if (x < -0.2) x = 1.2;
    if (x > 1.2) x = -0.2;
    if (y < -0.2) y = 1.2;
    if (y > 1.2) y = -0.2;
  }
}

class BackgroundPainter extends CustomPainter {
  final List<Orb> orbs;
  final double progress;

  BackgroundPainter({required this.orbs, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var orb in orbs) {
      orb.move();
      final paint = Paint()
        ..color = orb.color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

      canvas.drawCircle(
        Offset(orb.x * size.width, orb.y * size.height),
        orb.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) => true;
}
