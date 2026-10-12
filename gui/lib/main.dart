import 'package:flutter/material.dart';
import 'package:flyx/core/route/router.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/core/theme/theme_controller.dart';
import 'package:go_router/go_router.dart';

void main(List<String> args) {
  runApp(FlyxApp(router: buildRouter(onboarded: false)));
}

class FlyxApp extends StatelessWidget {
  const FlyxApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (_, _) => MaterialApp.router(
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeController.themeMode,
        routerConfig: router,
      ),
    );
  }
}

