import 'package:flyx/core/route/app_shell.dart';
import 'package:flyx/core/route/route_config.dart';
import 'package:flyx/core/viewmodel/view_model.dart';
import 'package:flyx/features/onboarding/presentation/view/onboarding_screen.dart';
import 'package:flyx/features/receive/presentation/view/enter_code_screen.dart';
import 'package:flyx/features/receive/presentation/view/receive_mode_selection_screen.dart';
import 'package:flyx/features/receive/presentation/view/receive_transfer_screen.dart';
import 'package:flyx/features/receive/presentation/view/wait_sender_screen.dart';
import 'package:flyx/features/receive/presentation/viewmodel/receive_view_model.dart';
import 'package:flyx/features/send/presentation/view/active_transfer_screen.dart';
import 'package:flyx/features/send/presentation/view/discover_receiver_screen.dart';
import 'package:flyx/features/send/presentation/view/file_selection_screen.dart';
import 'package:flyx/features/send/presentation/view/share_code_screen.dart';
import 'package:flyx/features/send/presentation/view/transfer_mode_selection_screen.dart';
import 'package:flyx/features/send/presentation/viewmodel/send_view_model.dart';
import 'package:go_router/go_router.dart';

GoRouter buildRouter({required bool onboarded}) => GoRouter(
  initialLocation: onboarded ? AppRoute.home.path : AppRoute.onboarding.path,
  routes: [
    GoRoute(
      path: AppRoute.onboarding.path,
      builder: (_, _) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoute.home.path,
      builder: (_, _) => const AppShell(),
    ),
    GoRoute(
      path: AppRoute.transfer.path,
      builder: (_, _) => const AppShell(initialIndex: 1),
    ),
    GoRoute(
      path: AppRoute.setting.path,
      builder: (_, _) => const AppShell(initialIndex: 2),
    ),

    // Send flow routes (ref-counted FlowScope<SendViewModel> auto-disposes on flow exit)
    GoRoute(
      path: AppRoute.fileSelector.path,
      builder: (_, _) =>
          const FlowScope<SendViewModel>(child: FileSelectionScreen()),
    ),
    GoRoute(
      path: AppRoute.transferModeSelection.path,
      builder: (_, _) =>
          const FlowScope<SendViewModel>(child: TransferModeSelectionScreen()),
    ),
    GoRoute(
      path: AppRoute.shareCode.path,
      builder: (_, _) =>
          const FlowScope<SendViewModel>(child: ShareCodeScreen()),
    ),
    GoRoute(
      path: AppRoute.discoverReceiver.path,
      builder: (_, _) =>
          const FlowScope<SendViewModel>(child: DiscoverReceiverScreen()),
    ),
    GoRoute(
      path: AppRoute.activeTransfer.path,
      builder: (_, _) =>
          const FlowScope<SendViewModel>(child: ActiveTransferScreen()),
    ),

    // Receive flow routes (ref-counted FlowScope<ReceiveViewModel> auto-disposes on flow exit)
    GoRoute(
      path: AppRoute.receiveModeSelection.path,
      builder: (_, _) =>
          const FlowScope<ReceiveViewModel>(child: ReceiveModeSelectionScreen()),
    ),
    GoRoute(
      path: AppRoute.enterCode.path,
      builder: (_, _) =>
          const FlowScope<ReceiveViewModel>(child: EnterCodeScreen()),
    ),
    GoRoute(
      path: AppRoute.waitSender.path,
      builder: (_, _) =>
          const FlowScope<ReceiveViewModel>(child: WaitSenderScreen()),
    ),
    GoRoute(
      path: AppRoute.receiveTransfer.path,
      builder: (_, _) =>
          const FlowScope<ReceiveViewModel>(child: ReceiveTransferScreen()),
    ),
  ],
);
