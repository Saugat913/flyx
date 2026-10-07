import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flyx/core/theme/app_palette.dart';

abstract class AppImage {
  const AppImage._();

  static const String onboarding1 = 'assets/onboarding/1.svg';
  static const String onboarding2 = 'assets/onboarding/2.svg';
  static const String onboarding3 = 'assets/onboarding/3.svg';

  static const String logo = 'assets/logo.svg';

  static ColorMapper colorMapper(Brightness brightness) =>
      AppArtColorMapper(brightness);
}

@immutable
class AppArtColorMapper extends ColorMapper {
  const AppArtColorMapper(this.brightness);

  final Brightness brightness;

  static final Map<Color, Color> _dark = <Color, Color>{
    AppPalette.black: AppPalette.neutral100,
    AppPalette.neutral700: AppPalette.neutral500,
    AppPalette.neutral500: AppPalette.neutral600,
    AppPalette.neutral400: AppPalette.neutral800,
    AppPalette.cyanDark: AppPalette.cyan,
    AppPalette.cyan: AppPalette.cyanBright,
  };

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (brightness != Brightness.dark) return color;
    return _dark[color] ?? color;
  }

  @override
  bool operator ==(Object other) =>
      other is AppArtColorMapper && other.brightness == brightness;

  @override
  int get hashCode => brightness.hashCode;
}
