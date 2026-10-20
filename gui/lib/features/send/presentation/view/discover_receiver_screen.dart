import 'package:flutter/material.dart';
import 'package:flyx/core/di/service_locator.dart';
import 'package:flyx/core/route/route_config.dart';
import 'package:flyx/core/route/route_navigation.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/core/viewmodel/view_model.dart';
import 'package:flyx/features/send/presentation/viewmodel/send_view_model.dart';
import 'package:flyx/features/send/presentation/widgets/radar_discovery_indicator.dart';
import 'package:flyx/features/shared/widgets/muted.dart';
import 'package:flyx/features/shared/widgets/peer_tile.dart';
import 'package:flyx/features/shared/widgets/responsive_content_wrapper.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class DiscoverReceiverScreen extends StatefulWidget {
  const DiscoverReceiverScreen({super.key});

  @override
  State<DiscoverReceiverScreen> createState() => _DiscoverReceiverScreenState();
}

class _DiscoverReceiverScreenState extends State<DiscoverReceiverScreen> {
  final _vm = getIt<SendViewModel>();

  @override
  void initState() {
    super.initState();
    _vm.startDiscovery();
  }

  @override
  void dispose() {
    _vm.stopDiscovery();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Receiver'),
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedChevronLeft,
            color: scheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContentWrapper(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.screenH,
            vertical: AppSpace.screenV,
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpace.section),
              const RadarIndicator(),
              const SizedBox(height: AppSpace.gap),
              _vm.select(
                (vm) => vm.discoveredPeers.isEmpty,
                (context, isEmpty) => Column(
                  children: [
                    Text(
                      isEmpty ? 'Searching nearby...' : 'Devices nearby',
                      style: context.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Muted(
                      isEmpty
                          ? 'Make sure the receiver has Flyx open'
                          : 'Tap a device to start sending',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.section),
              Expanded(
                child: _vm.select(
                  (vm) => vm.discoveredPeers.toList(),
                  (context, peers) => peers.isEmpty
                      ? const Center(
                          child: SizedBox.shrink(),
                        )
                      : ListView.separated(
                          itemCount: peers.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpace.gap),
                          itemBuilder: (context, index) {
                            final peer = peers[index];
                            return TweenAnimationBuilder<double>(
                              key: ValueKey(peer.name),
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 12 * (1 - value)),
                                  child: child,
                                ),
                              ),
                              child: PeerTile(
                                peer: peer,
                                onTap: () {
                                  _vm.startTransfer(peer);
                                  context.replaceTo(AppRoute.activeTransfer);
                                },
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: scheme.primary,
                                    borderRadius: AppRadius.button,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Send',
                                        style: context.textTheme.labelLarge?.copyWith(
                                          color: scheme.onPrimary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedArrowRight01,
                                        size: 16,
                                        color: scheme.onPrimary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
