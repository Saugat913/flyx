import 'package:flutter/material.dart';
import 'package:flyx/core/route/router.dart';
import 'package:flyx/core/theme/app_theme.dart';

void main(List<String> args) {
  runApp(FlyxApp());
}

class FlyxApp extends StatelessWidget {
  const FlyxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: buildRouter(onboarded: false),
    );
  }
}

