import 'package:flyx/core/route/app_shell.dart';
import 'package:flyx/core/route/route_config.dart';
import 'package:flyx/features/home/presentation/home_screen.dart';
import 'package:flyx/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flyx/features/setting/presentation/setting_screen.dart';
import 'package:flyx/features/transfer/presentation/transfer_screen.dart';
import 'package:go_router/go_router.dart';



GoRouter buildRouter({required bool onboarded}) => GoRouter(
  initialLocation: onboarded ? AppRoute.home.path : AppRoute.onboarding.path,
  routes: [
    GoRoute(
      path: AppRoute.onboarding.path,
      builder: (_, _) => const OnboardingScreen(),
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoute.home.path,
              builder: (_, _) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoute.transfer.path,
              builder: (_, _) => const TransferScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoute.setting.path,
              builder: (_, _) => const SettingScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

// Create the router single instance why?
// Could cause the error to rebuild the router if whole app state rebuild like theme switch 
// If called buildRouter called at AppInstanciation in each theme app reinitialization
// would cause to rebuild router and lost the current route stack
final router= buildRouter(onboarded: false);