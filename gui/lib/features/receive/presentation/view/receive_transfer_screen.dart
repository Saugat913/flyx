import 'package:flutter/material.dart';
import 'package:flyx/core/di/service_locator.dart';
import 'package:flyx/core/route/route_config.dart';
import 'package:flyx/core/route/route_navigation.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/core/viewmodel/view_model.dart';
import 'package:flyx/features/receive/presentation/viewmodel/receive_view_model.dart';
import 'package:flyx/features/shared/widgets/muted.dart';
import 'package:flyx/features/shared/widgets/responsive_content_wrapper.dart';
import 'package:flyx/features/shared/widgets/transfer_progress_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class ReceiveTransferScreen extends StatefulWidget {
  const ReceiveTransferScreen({super.key});

  @override
  State<ReceiveTransferScreen> createState() => _ReceiveTransferScreenState();
}

class _ReceiveTransferScreenState extends State<ReceiveTransferScreen> {
  final _vm = getIt<ReceiveViewModel>();
  bool _isDialogOpen = false;

  Future<void> _handleCancelOrExit() async {
    if (_vm.status == ReceiveStatus.completed ||
        _vm.status == ReceiveStatus.idle) {
      _vm.declineOrCancel();
      context.goTo(AppRoute.home);
      return;
    }

    if (_vm.status == ReceiveStatus.incomingRequest) {
      _vm.declineOrCancel();
      context.pop();
      return;
    }

    if (_isDialogOpen) return;
    _isDialogOpen = true;

    final shouldCancel = await confirmCancelTransferDialog(
      context,
      message: 'Do you really want to stop receiving these files?',
    );
    _isDialogOpen = false;

    if (shouldCancel && mounted) {
      _vm.declineOrCancel();
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleCancelOrExit();
      },
      child: _vm.watch((context, vm) {
        final status = vm.status;
        final isPending = status == ReceiveStatus.incomingRequest;
        final isCompleted = status == ReceiveStatus.completed;
        final peerName = vm.senderPeer?.name ?? 'Sender';
        final progress = vm.overallProgress;
        final files = vm.incomingFiles;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Transfer'),
            leading: IconButton(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedChevronLeft,
                color: scheme.onSurface,
              ),
              onPressed: _handleCancelOrExit,
            ),
            actions: (isCompleted || isPending)
                ? null
                : [
                    TextButton(
                      onPressed: _handleCancelOrExit,
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: AppSpace.row),
                  ],
          ),
          bottomNavigationBar: ResponsiveBottomBar(
            child: isPending
                ? Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _handleCancelOrExit,
                          child: const Text('Decline'),
                        ),
                      ),
                      const SizedBox(width: AppSpace.gap),
                      Expanded(
                        child: FilledButton(
                          onPressed: vm.acceptTransfer,
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _handleCancelOrExit,
                      child: Text(isCompleted ? 'Done' : 'Cancel transfer'),
                    ),
                  ),
          ),
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
                    Center(
                      child: TransferCircularGauge(
                        progress: progress,
                        activeIcon: HugeIcons.strokeRoundedArrowDownLeft01,
                        isCompleted: isCompleted,
                        centerLabel: isPending ? 'Ready' : null,
                      ),
                    ),
                    const SizedBox(height: AppSpace.card),
                    Text(
                      isPending
                          ? 'Ready to receive'
                          : isCompleted
                          ? 'Transfer complete'
                          : 'Receiving...',
                      style: context.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Muted(
                        isPending
                            ? '$peerName wants to send ${files.length} ${files.length == 1 ? "file" : "files"}'
                            : isCompleted
                            ? 'Received from $peerName'
                            : 'Receiving from $peerName',
                      ),
                    ),
                    const SizedBox(height: AppSpace.section),
                    TransferStatsCard(
                      fileCount: files.length,
                      totalBytes: vm.totalSize,
                      processedBytes: vm.receivedBytes,
                      speedBytesPerSec: vm.speedBytesPerSec,
                      processedLabel: 'Received',
                    ),
                    if (files.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.card),
                      TransferFilesCard(
                        files: files,
                        fileProgress: vm.fileProgress,
                        showProgress: !isPending,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
