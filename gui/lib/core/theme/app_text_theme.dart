import 'package:flutter/material.dart';

abstract final class AppText {
  /// page titles
  static const pageTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    height: 1.15,
  );

  /// section headings
  static const sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.2,
  );

  /// item titles
  static const itemTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.25,
  );

  /// normal body text
  static const body = TextStyle(fontSize: 13, height: 1.4);

  /// supporting / secondary text
  static const secondary = TextStyle(fontSize: 12, height: 1.4);

  /// buttons and actions
  static const actionLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// navigation
  static const navLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  /// selected navigation
  static const navLabelOn = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static TextTheme theme(ColorScheme colors) {
    return TextTheme(
      titleLarge: pageTitle.copyWith(color: colors.onSurface),
      titleMedium: sectionTitle.copyWith(color: colors.onSurface),
      titleSmall: itemTitle.copyWith(color: colors.onSurface),
      bodyLarge: body.copyWith(color: colors.onSurface),
      bodyMedium: body.copyWith(color: colors.onSurface),
      bodySmall: secondary.copyWith(color: colors.onSurfaceVariant),
      labelLarge: actionLabel,
      labelMedium: navLabel.copyWith(color: colors.onSurfaceVariant),
      labelSmall: navLabel.copyWith(color: colors.onSurfaceVariant),
    );
  }
}
