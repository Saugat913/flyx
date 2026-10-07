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
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: ThemeMode.light,
      routerConfig: buildRouter(onboarded: false),
    );
  }
}