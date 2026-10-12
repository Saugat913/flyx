import 'package:flutter/material.dart';
import 'package:flyx/core/theme/app_palette.dart';

class RippleEffect extends StatelessWidget {
  const RippleEffect({super.key});

  static const _circles = [(150.0, 0.06), (110.0, 0.08), (70.0, 0.10)];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: SizedBox(
        height: 150,
        width: 150,
        child: Stack(
          children: _circles.map((circle) {
            final (size, alpha) = circle;
            return Positioned(
              top: 20 - size / 2,
              right: 20 - size / 2,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppPalette.neutral50.withValues(alpha: alpha),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
