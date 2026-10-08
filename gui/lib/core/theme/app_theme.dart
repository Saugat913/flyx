import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_theme.dart';



extension AppThemeExtensions on BuildContext{
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  AppThemeColors get appThemeColors => Theme.of(this).extension<AppThemeColors>()!;
  TextTheme get textTheme => Theme.of(this).textTheme;
}

ThemeData buildAppTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final colors = dark ? AppColors.dark() : AppColors.light();
  final appColors = dark ? AppThemeColors.dark : AppThemeColors.light;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colors,

    scaffoldBackgroundColor: colors.surface,
    canvasColor: colors.surface,

    splashColor: appColors.brandSubtle,
    highlightColor: Colors.transparent,

    textTheme: AppText.theme(colors),

    appBarTheme: AppBarTheme(
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,

      surfaceTintColor: Colors.transparent,

      elevation: 0,
      scrolledUnderElevation: 0,

      centerTitle: false,

      titleTextStyle: AppText.pageTitle.copyWith(color: colors.onSurface),

      iconTheme: IconThemeData(color: colors.onSurface, size: 22),
    ),

    cardTheme: CardThemeData(
      color: colors.surfaceContainer,

      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,

      margin: EdgeInsets.zero,

      shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
    ),

    dividerTheme: DividerThemeData(
      color: colors.outlineVariant,
      thickness: 1,
      space: 1,
    ),

    iconTheme: IconThemeData(color: colors.onSurfaceVariant, size: 22),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,

        elevation: 0,
        shadowColor: Colors.transparent,

        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),

        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),

        textStyle: AppText.actionLabel,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.onSurface,

        backgroundColor: Colors.transparent,

        elevation: 0,
        shadowColor: Colors.transparent,

        side: BorderSide(color: colors.outlineVariant),

        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),

        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),

        textStyle: AppText.actionLabel,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.onSurface,

        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),

        textStyle: AppText.actionLabel,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceContainer,

      border: OutlineInputBorder(
        borderRadius: AppRadius.input,
        borderSide: BorderSide(color: colors.outlineVariant),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.input,
        borderSide: BorderSide(color: colors.outlineVariant),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.input,
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.input,
        borderSide: BorderSide(color: colors.error),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.input,
        borderSide: BorderSide(color: colors.error, width: 1.5),
      ),

      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),

      hintStyle: AppText.body.copyWith(color: colors.onSurfaceVariant),

      labelStyle: AppText.body.copyWith(color: colors.onSurfaceVariant),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return appColors.brand;
        }

        return Colors.transparent;
      }),

      checkColor: WidgetStatePropertyAll(colors.onPrimary),

      side: BorderSide(color: colors.outlineVariant, width: 1.5),

      shape: RoundedRectangleBorder(borderRadius: AppRadius.checkbox),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.onPrimary;
        }

        return colors.onSurfaceVariant;
      }),

      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return appColors.brand;
        }

        return colors.surfaceContainerHighest;
      }),

      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.transparent;
        }

        return colors.outlineVariant;
      }),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colors.inverseSurface,
      elevation: 0,
      insetPadding: const EdgeInsets.all(14),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.chip),

      contentTextStyle: AppText.body.copyWith(
        color: colors.onInverseSurface,
        fontWeight: FontWeight.w500,
      ),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.surfaceContainer,

      surfaceTintColor: Colors.transparent,

      elevation: 0,
      shadowColor: Colors.transparent,

      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: colors.surfaceContainer,

      surfaceTintColor: Colors.transparent,

      elevation: 0,
      shadowColor: Colors.transparent,

      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),

      titleTextStyle: AppText.sectionTitle.copyWith(color: colors.onSurface),

      contentTextStyle: AppText.body.copyWith(color: colors.onSurfaceVariant),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      indicatorColor: appColors.brandSubtle,

      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);

        return (selected ? AppText.navLabelOn : AppText.navLabel).copyWith(
          color: selected ? appColors.brand : colors.onSurfaceVariant,
        );
      }),

      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);

        return IconThemeData(
          color: selected ? appColors.brand : colors.onSurfaceVariant,
          size: 22,
        );
      }),
    ),

    extensions: <ThemeExtension<dynamic>>[appColors],
  );
}


final darkTheme = buildAppTheme(Brightness.dark);
final lightTheme = buildAppTheme(Brightness.light);
