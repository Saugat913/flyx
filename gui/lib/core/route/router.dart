import 'package:flyx/core/route/app_shell.dart';
import 'package:flyx/core/route/route_config.dart';
import 'package:flyx/features/home/presentation/view/home_screen.dart';
import 'package:flyx/features/onboarding/presentation/view/onboarding_screen.dart';
import 'package:flyx/features/send/presentation/view/discover_receiver_screen.dart';
import 'package:flyx/features/send/presentation/view/file_selection_screen.dart';
import 'package:flyx/features/send/presentation/view/share_code_screen.dart';
import 'package:flyx/features/send/presentation/view/transfer_mode_selection_screen.dart';
import 'package:flyx/features/setting/presentation/view/setting_screen.dart';
import 'package:flyx/features/transfer/presentation/view/transfer_screen.dart';
import 'package:go_router/go_router.dart';



GoRouter buildRouter({required bool onboarded}) => GoRouter(
  initialLocation: onboarded ? AppRoute.home.path : AppRoute.onboarding.path,
  routes: [
    GoRoute(
      path: AppRoute.onboarding.path,
      builder: (_, _) => const OnboardingScreen(),
    ),

    GoRoute(
      path: AppRoute.fileSelector.path,
      builder: (_, _) => const FileSelectionScreen(),
    ),
    
    GoRoute(
      path: AppRoute.transferModeSelection.path,
      builder: (_, _) => const TransferModeSelectionScreen(),
    ),
    
    GoRoute(
      path: AppRoute.shareCode.path,
      builder: (_, _) => const ShareCodeScreen(),
    ),

    GoRoute(
      path: AppRoute.discoverReceiver.path,
      builder: (_, _) => const DiscoverReceiverScreen(),
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
