import 'package:flutter/material.dart';
import 'package:flyx/core/di/service_locator.dart';
import 'package:flyx/core/route/router.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/core/theme/theme_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  final onboarded =
      getIt<SharedPreferences>().getBool(kOnboardedPrefKey) ?? false;
  runApp(FlyxApp(router: buildRouter(onboarded: onboarded)));
}

class FlyxApp extends StatelessWidget {
  const FlyxApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (_, _) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeController.themeMode,
        routerConfig: router,
      ),
    );
  }
}
