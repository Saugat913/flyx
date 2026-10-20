import 'package:flutter/material.dart';
import 'package:flyx/core/route/route_config.dart';
import 'package:flyx/core/route/route_navigation.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/features/shared/widgets/mode_selection_list.dart';
import 'package:flyx/features/shared/widgets/responsive_content_wrapper.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class TransferModeSelectionScreen extends StatefulWidget {
  const TransferModeSelectionScreen({super.key});

  @override
  State<TransferModeSelectionScreen> createState() =>
      _TransferModeSelectionScreenState();
}

class _TransferModeSelectionScreenState
    extends State<TransferModeSelectionScreen> {
  int _selectedMode = 0;

  static const _modes = [
    TransferModeOption(
      title: 'Nearby devices',
      subtitle: 'Fastest option over the same Wi-Fi',
      actionLabel: 'Continue',
      route: AppRoute.discoverReceiver,
      icon: HugeIcons.strokeRoundedWifi01,
    ),
    TransferModeOption(
      title: '6-digit code',
      subtitle: 'Pair manually across networks',
      actionLabel: 'Continue',
      route: AppRoute.shareCode,
      icon: HugeIcons.strokeRoundedKey01,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activeMode = _modes[_selectedMode];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Mode'),
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
