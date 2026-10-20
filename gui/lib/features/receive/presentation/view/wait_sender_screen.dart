import 'package:flutter/material.dart';
import 'package:flyx/core/di/service_locator.dart';
import 'package:flyx/core/route/route_config.dart';
import 'package:flyx/core/route/route_navigation.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/core/utils/formatter.dart';
import 'package:flyx/core/viewmodel/view_model.dart';
import 'package:flyx/features/receive/presentation/viewmodel/receive_view_model.dart';
import 'package:flyx/features/receive/presentation/widgets/radar_pulse_indicator.dart';
import 'package:flyx/features/setting/presentation/view/setting_screen.dart';
import 'package:flyx/features/shared/widgets/muted.dart';
import 'package:flyx/features/shared/widgets/peer_tile.dart';
import 'package:flyx/features/shared/widgets/responsive_content_wrapper.dart';
import 'package:flyx/features/shared/widgets/transfer_progress_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class WaitSenderScreen extends StatefulWidget {
  const WaitSenderScreen({super.key});

  @override
  State<WaitSenderScreen> createState() => _WaitSenderScreenState();
}

class _WaitSenderScreenState extends State<WaitSenderScreen> {
  final _vm = getIt<ReceiveViewModel>();

  @override
  void initState() {
    super.initState();
    _vm.startBroadcasting(
      onAutoAccepted: () {
        if (mounted) context.replaceTo(AppRoute.receiveTransfer);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return _vm.watch((context, vm) {
      final hasIncoming = vm.status == ReceiveStatus.incomingRequest;
      final peer = vm.senderPeer;
      final files = vm.incomingFiles;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Receive Files'),
          leading: IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedChevronLeft,
              color: scheme.onSurface,
            ),
            onPressed: () {
              vm.declineOrCancel();
              context.pop();
            },
          ),
        ),
        bottomNavigationBar: hasIncoming
            ? ResponsiveBottomBar(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => vm.startBroadcasting(),
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: AppSpace.gap),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          vm.acceptTransfer();
                          context.replaceTo(AppRoute.receiveTransfer);
                        },
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              )
            : null,
        body: SafeArea(
          child: SingleChildScrollView(
            child: ResponsiveContentWrapper(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.screenH,
                vertical: AppSpace.screenV,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpace.row),
                  const Center(child: RadarPulseIndicator()),
                  const SizedBox(height: AppSpace.card),
                  Text(
                    hasIncoming
                        ? 'Incoming transfer request'
                        : 'Waiting for sender...',
                    style: context.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: ValueListenableBuilder<String>(
                      valueListenable: deviceName,
                      builder: (_, name, _) => Muted(
                        hasIncoming
                            ? '${peer?.name ?? "A device"} wants to send you ${files.length} ${files.length == 1 ? "file" : "files"}'
                            : 'Visible to nearby devices as $name',
                      ),
                    ),
                  ),
                  if (hasIncoming && peer != null) ...[
                    const SizedBox(height: AppSpace.section),
                    PeerTile(
                      peer: peer,
                      trailing: Text(
                        formatFileSize(vm.totalSize),
                        style: context.textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(height: AppSpace.card),
                    TransferFilesCard(
                      files: files,
                      title:
                          '${files.length} ${files.length == 1 ? 'file' : 'files'} (${formatFileSize(vm.totalSize)})',
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
