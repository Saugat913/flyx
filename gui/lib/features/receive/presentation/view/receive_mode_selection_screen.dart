import 'package:flutter/material.dart';
import 'package:flyx/core/route/route_config.dart';
import 'package:flyx/core/route/route_navigation.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/features/shared/widgets/mode_selection_list.dart';
import 'package:flyx/features/shared/widgets/responsive_content_wrapper.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class ReceiveModeSelectionScreen extends StatefulWidget {
  const ReceiveModeSelectionScreen({super.key});

  @override
  State<ReceiveModeSelectionScreen> createState() =>
      _ReceiveModeSelectionScreenState();
}

class _ReceiveModeSelectionScreenState
    extends State<ReceiveModeSelectionScreen> {
  int _selectedMode = 0;

  static const _modes = [
    TransferModeOption(
      title: 'Nearby devices',
      subtitle: 'Make this device visible over the same Wi-Fi',
      actionLabel: 'Wait for sender',
      route: AppRoute.waitSender,
      icon: HugeIcons.strokeRoundedWifi01,
    ),
    TransferModeOption(
      title: '6-digit code',
      subtitle: 'Enter the code shared by the sender',
      actionLabel: 'Enter code',
      route: AppRoute.enterCode,
      icon: HugeIcons.strokeRoundedPin,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activeMode = _modes[_selectedMode];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive Mode'),
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedChevronLeft,
            color: context.colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      bottomNavigationBar: ResponsiveBottomBar(
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => context.pushTo(activeMode.route),
            child: Text(activeMode.actionLabel),
          ),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContentWrapper(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.screenH,
            vertical: AppSpace.screenV,
          ),
          child: ModeSelectionList(
            options: _modes,
            selectedIndex: _selectedMode,
            onSelected: (index) => setState(() => _selectedMode = index),
          ),
        ),
      ),
    );
  }
}
