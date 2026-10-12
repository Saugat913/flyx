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
        SvgPicture.asset(AppImage.logo, width: 50, height: 50,fit: BoxFit.contain,),
        RichText(
          text: TextSpan(
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colorScheme.primary,
            ),
            children: [
              TextSpan(text: "Fly"),
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