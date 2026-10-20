import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flyx/core/media/images.dart';
import 'package:flyx/core/theme/app_theme.dart';

class RadarPulseIndicator extends StatefulWidget {
  const RadarPulseIndicator({super.key});

  @override
  State<RadarPulseIndicator> createState() => _RadarPulseIndicatorState();
}

class _RadarPulseIndicatorState extends State<RadarPulseIndicator>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.appThemeColors.brand;

    return SizedBox.square(
      dimension: 200,
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
  _RadarPainter(this.progress, this.color) : super(repaint: progress);

  final Animation<double> progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final maxRadius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    for (var i = 0; i < 3; i++) {
      final t = (progress.value + i / 3) % 1.0;
      paint.color = color.withValues(alpha: (1 - t) * 0.35);
      canvas.drawCircle(
        size.center(Offset.zero),
        32 + (maxRadius - 32) * Curves.easeOutCubic.transform(t),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.color != color;
}