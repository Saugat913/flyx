import 'package:flutter/material.dart';
import 'package:flyx/core/di/service_locator.dart';
import 'package:flyx/core/route/route_config.dart';
import 'package:flyx/core/route/route_navigation.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/core/viewmodel/view_model.dart';
import 'package:flyx/features/send/presentation/viewmodel/send_view_model.dart';
import 'package:flyx/features/shared/widgets/muted.dart';
import 'package:flyx/features/shared/widgets/responsive_content_wrapper.dart';
import 'package:flyx/features/shared/widgets/transfer_progress_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class ActiveTransferScreen extends StatefulWidget {
  const ActiveTransferScreen({super.key});

  @override
  State<ActiveTransferScreen> createState() => _ActiveTransferScreenState();
}

class _ActiveTransferScreenState extends State<ActiveTransferScreen> {
  final _vm = getIt<SendViewModel>();
  bool _isDialogOpen = false;

  Future<void> _handleCancelOrExit() async {
    if (_vm.transferStatus == TransferStatus.completed ||
        _vm.transferStatus == TransferStatus.idle) {
      _vm.cancelTransfer();
      context.goTo(AppRoute.home);
      return;
    }

    if (_isDialogOpen) return;
    _isDialogOpen = true;

    final shouldCancel = await confirmCancelTransferDialog(
      context,
      message: 'Do you really want to stop sending these files?',
    );
    _isDialogOpen = false;

    if (shouldCancel && mounted) {
      _vm.cancelTransfer();
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
        final status = vm.transferStatus;
        final isCompleted = status == TransferStatus.completed;
        final isWaiting = status == TransferStatus.waitingAcceptance;
        final peerName = vm.activePeer?.name ?? 'Receiver';
        final progress = vm.overallProgress;
        final files = vm.selectedFiles.toList();

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
            actions: isCompleted
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
            child: SizedBox(
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
                        activeIcon: HugeIcons.strokeRoundedArrowUpRight01,
                        isWaiting: isWaiting,
                        isCompleted: isCompleted,
                      ),
                    ),
                    const SizedBox(height: AppSpace.card),
                    Text(
                      isWaiting
                          ? 'Waiting for receiver...'
                          : isCompleted
                          ? 'Transfer complete'
                          : 'Transferring...',
                      style: context.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Muted(
                        isWaiting
                            ? 'Asking $peerName to accept'
                            : isCompleted
                            ? 'Sent to $peerName'
                            : 'Sending to $peerName',
                      ),
                    ),
                    const SizedBox(height: AppSpace.section),
                    TransferStatsCard(
                      fileCount: files.length,
                      totalBytes: vm.totalSize,
                      processedBytes: vm.transferredBytes,
                      speedBytesPerSec: vm.speedBytesPerSec,
                      processedLabel: 'Transferred',
                    ),
                    if (files.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.card),
                      TransferFilesCard(
                        files: files,
                        fileProgress: vm.fileProgress,
                        showProgress: true,
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
