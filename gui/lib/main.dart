import 'package:flutter/material.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/features/onboarding/presentation/onboarding_screen.dart';

void main(List<String> args) {
  runApp(FlyxApp());
}

class FlyxApp extends StatelessWidget {
  const FlyxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: ThemeMode.light,
      home: Scaffold(
        body: OnboardingScreen(),
      ),
    );
  }
}