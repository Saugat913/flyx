import 'package:flutter/material.dart';
import 'package:flyx/core/di/service_locator.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/core/viewmodel/view_model.dart';
import 'package:flyx/features/send/data/models/peer.dart';
import 'package:flyx/features/send/presentation/viewmodel/send_view_model.dart';
import 'package:flyx/features/shared/widgets/radar_dicovery_indicator.dart';
import 'package:flyx/features/shared/widgets/muted.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Receiver'),
        leading: IconButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedChevronLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.screenH,
            vertical: AppSpace.screenV,
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpace.card),
              const RadarIndicator(),
              const SizedBox(height: AppSpace.card),
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
                          : 'Choose who to connect with',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.section),
              Expanded(
                child: _vm.select(
                  (vm) => vm.discoveredPeers.toList(),
                  (context, peers) => ListView.separated(
                    itemCount: peers.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpace.gap),
                    itemBuilder: (context, index) {
                      final peer = peers[index];
                      return _ReceiverDeviceTile(
                        key: ValueKey(peer.name),
                        peer: peer,
                        onTap: () {},
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

class _ReceiverDeviceTile extends StatelessWidget {
  const _ReceiverDeviceTile({
    super.key,
    required this.peer,
    required this.onTap,
  });

  final Peer peer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.appThemeColors.brand;

    return TweenAnimationBuilder<double>(
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
      child: Material(
        color: context.colorScheme.surfaceContainer,
        borderRadius: AppRadius.card,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.card,
              vertical: AppSpace.gap + 2,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.appThemeColors.brandSubtle,
                    borderRadius: AppRadius.icon,
                  ),
                  child: HugeIcon(
                    icon: peer.icon,
                    size: 22,
                    color: brand,
                  ),
                ),
                const SizedBox(width: AppSpace.gap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        peer.name,
                        style: context.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Muted('${peer.platform} · ${peer.connectionType}'),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpace.row),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Send',
                      style: context.textTheme.labelLarge?.copyWith(
                        color: brand,
                      ),
                    ),
                    const SizedBox(width: 4),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      size: 18,
                      color: brand,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}