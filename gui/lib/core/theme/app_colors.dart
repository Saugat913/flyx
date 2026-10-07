import 'package:flutter/material.dart';

import 'app_palette.dart';

abstract final class AppColors {
  static ColorScheme light() {
    return ColorScheme(
      brightness: Brightness.light,

      primary: AppPalette.black,
      onPrimary: AppPalette.white,

      primaryContainer: AppPalette.neutral100,
      onPrimaryContainer: AppPalette.black,

      secondary: AppPalette.neutral700,
      onSecondary: AppPalette.white,

      secondaryContainer: AppPalette.neutral100,
      onSecondaryContainer: AppPalette.black,

      tertiary: AppPalette.cyanDark,
      onTertiary: AppPalette.white,

      tertiaryContainer: AppPalette.neutral100,
      onTertiaryContainer: AppPalette.cyanDark,

      error: AppPalette.red,
      onError: AppPalette.white,

      errorContainer: AppPalette.redContainerLight,
      onErrorContainer: AppPalette.red,

      surface: AppPalette.neutral50,
      onSurface: AppPalette.black,

      onSurfaceVariant: AppThemeColors.light.muted,

      surfaceContainerLowest: AppPalette.white,
      surfaceContainerLow: AppPalette.white,
      surfaceContainer: AppPalette.white,
      surfaceContainerHigh: AppPalette.neutral100,
      surfaceContainerHighest: AppPalette.neutral200,

      outline: AppPalette.neutral500,
      outlineVariant: AppPalette.neutral200,

      shadow: AppPalette.black,
      scrim: AppPalette.black,

      inverseSurface: AppPalette.black,
      onInverseSurface: AppPalette.white,
      inversePrimary: AppPalette.cyanBright,
    );
  }

  static ColorScheme dark() {
    return ColorScheme(
      brightness: Brightness.dark,

      primary: AppPalette.white,
      onPrimary: AppPalette.black,

      primaryContainer: AppPalette.neutral900,
      onPrimaryContainer: AppPalette.white,

      secondary: AppPalette.neutral500,
      onSecondary: AppPalette.black,

      secondaryContainer: AppPalette.neutral900,
      onSecondaryContainer: AppPalette.white,

      tertiary: AppPalette.cyanBright,
      onTertiary: AppPalette.black,

      tertiaryContainer: AppPalette.neutral900,
      onTertiaryContainer: AppPalette.cyanBright,

      error: AppPalette.redBright,
      onError: AppPalette.black,

      errorContainer: AppPalette.redContainerDark,
      onErrorContainer: AppPalette.redBright,

      surface: AppPalette.neutral950,
      onSurface: AppPalette.white,

      onSurfaceVariant: AppThemeColors.dark.muted,

      surfaceContainerLowest: AppPalette.black,
      surfaceContainerLow: AppPalette.black,
      surfaceContainer: AppPalette.neutral900,
      surfaceContainerHigh: AppPalette.neutral800,
      surfaceContainerHighest: AppPalette.neutral800,

      outline: AppPalette.neutral600,
      outlineVariant: AppPalette.neutral800,

      shadow: AppPalette.black,
      scrim: AppPalette.black,

      inverseSurface: AppPalette.white,
      onInverseSurface: AppPalette.black,
      inversePrimary: AppPalette.cyanDark,
    );
  }
}




@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color brand;
  final Color brandSecondary;
  final Color muted;

  const AppThemeColors({
    required this.brand,
    required this.brandSecondary,
    required this.muted,
  });

  static const light = AppThemeColors(
    brand: AppPalette.cyan,
    brandSecondary: AppPalette.cyanDark,
    muted: AppPalette.neutral700,
  );

  static const dark = AppThemeColors(
    brand: AppPalette.cyan,
    brandSecondary: AppPalette.cyanBright,
    muted: AppPalette.neutral500,
  );


  static AppThemeColors of(BuildContext context) =>
      Theme.of(context).extension<AppThemeColors>()!;

  Color get brandSubtle => brand.withValues(alpha: 0.08);

  @override
  AppThemeColors copyWith({Color? brand, Color? brandSecondary, Color? muted}) {
    return AppThemeColors(
      brand: brand ?? this.brand,
      brandSecondary: brandSecondary ?? this.brandSecondary,
      muted: muted ?? this.muted,
    );
  }

  @override
  AppThemeColors lerp(covariant AppThemeColors? other, double t) {
    if (other == null) return this;

    return AppThemeColors(
      brand: Color.lerp(brand, other.brand, t)!,
      brandSecondary: Color.lerp(brandSecondary, other.brandSecondary, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
    );
  }
}
