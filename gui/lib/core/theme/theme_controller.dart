import 'package:flutter/material.dart';
import 'package:flyx/core/viewmodel/view_model.dart';

class ThemeController extends ViewModel {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isSystem => _themeMode == ThemeMode.system;
  bool get isDark => _themeMode == ThemeMode.dark;
  bool get isLight => _themeMode == ThemeMode.light;

  void setTheme(ThemeMode mode) {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notify();
  }

  void toggle() {
    setTheme(isDark ? ThemeMode.light : ThemeMode.dark);
  }
}

final themeController = ThemeController();