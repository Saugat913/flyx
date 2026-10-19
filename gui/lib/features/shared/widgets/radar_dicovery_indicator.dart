import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flyx/core/media/images.dart';
import 'package:flyx/core/theme/app_theme.dart';

class RadarIndicator extends StatefulWidget {
  const RadarIndicator({super.key});

  @override
  State<RadarIndicator> createState() => _RadarIndicatorState();
}

class _RadarIndicatorState extends State<RadarIndicator>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.appThemeColors.brand;

    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: _RadarPainter(_controller, brand),
        child: Center(
          child: Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colorScheme.surfaceContainer,
              border: Border.all(color: brand.withValues(alpha: 0.25), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: brand.withValues(alpha: 0.22),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: SvgPicture.asset(AppImage.logo, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter(this.animation, this.color) : super(repaint: animation);

  final Animation<double> animation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // range rings
    final ring = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (final f in const [0.48, 0.74, 1.0]) {
      canvas.drawCircle(center, radius * f, ring);
    }

    // sweep: last quarter of the gradient is the trailing cone, rotated with time
    final sweep = Paint()
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: 0), color.withValues(alpha: 0.3)],
        stops: const [0.75, 1.0],
        transform: GradientRotation(animation.value * 2 * math.pi),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, sweep);
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.color != color;
}