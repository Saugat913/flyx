import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flyx/core/media/images.dart';
import 'package:flyx/core/theme/app_theme.dart';

class Branding extends StatelessWidget {
  const Branding({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          AppImage.logo,
          width: 38,
          height: 38,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: context.colorScheme.onSurface,
            ),
            children: [
              const TextSpan(text: 'Fly'),
              TextSpan(
                text: 'X',
                style: TextStyle(color: context.appThemeColors.brand),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
