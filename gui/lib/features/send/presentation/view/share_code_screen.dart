import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class ShareCodeScreen extends StatefulWidget {
  const ShareCodeScreen({super.key});

  @override
  State<ShareCodeScreen> createState() => _ShareCodeScreenState();
}

class _ShareCodeScreenState extends State<ShareCodeScreen> {
  final _vm = getIt<SendViewModel>();
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _vm.generateShareCode(
      onPeerAccepted: () {
        if (mounted) context.replaceTo(AppRoute.activeTransfer);
      },
    );
  }

  @override
  void dispose() {
    _vm.cancelShareCode();
    super.dispose();
  }

  Future<void> _copyCode() async {
    final code = _vm.shareCode;
    if (code == null) return;
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copied to clipboard')),
    );
  }

  Future<void> _confirmCancel() async {
    if (_isDialogOpen) return;
    if (_vm.shareCode == null) {
      context.pop();
      return;
    }

    _isDialogOpen = true;
    final shouldCancel = await confirmCancelTransferDialog(
      context,
      message:
          'Do you really want to cancel this transfer? The current 6-digit code will stop working.',
    );
    _isDialogOpen = false;

    if (shouldCancel && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final brand = context.appThemeColors.brand;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmCancel();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Share Code'),
          leading: IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedChevronLeft,
              color: scheme.onSurface,
            ),
            onPressed: _confirmCancel,
          ),
        ),
        bottomNavigationBar: ResponsiveBottomBar(
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _confirmCancel,
              child: const Text('Cancel transfer'),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.card,
                      vertical: AppSpace.section,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainer,
                      borderRadius: AppRadius.card,
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: _vm.select(
                      (vm) => vm.shareCode,
                      (context, code) {
                        final isLoading = code == null;
                        return Column(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHigh,
                                borderRadius: AppRadius.card,
                                border: Border.all(color: scheme.outlineVariant),
                              ),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedKey01,
                                size: 24,
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpace.card),
                            Text(
                              'Share this 6-digit code',
                              style: context.textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Muted(
                              isLoading
                                  ? 'Requesting code from signaling server...'
                                  : 'Receiver enters this code to connect',
                            ),
                            const SizedBox(height: AppSpace.section),
                            SizedBox(
                              height: 54,
                              child: Center(
                                child: isLoading
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: brand,
                                        ),
                                      )
                                    : ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 360,
                                        ),
                                        child: Row(
                                          spacing: AppSpace.row,
                                          children: List.generate(6, (i) {
                                            return Expanded(
                                              child: Container(
                                                height: 54,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: scheme
                                                      .surfaceContainerHigh,
                                                  borderRadius: AppRadius.input,
                                                  border: Border.all(
                                                    color: scheme.outlineVariant,
                                                  ),
                                                ),
                                                child: Text(
                                                  code[i],
                                                  style: context
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: AppSpace.section),
                            OutlinedButton.icon(
                              onPressed: isLoading ? null : _copyCode,
                              icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedCopy01,
                                size: 18,
                                color: isLoading
                                    ? scheme.onSurfaceVariant
                                    : scheme.onSurface,
                              ),
                              label: const Text('Copy code'),
                            ),
                            if (!isLoading) ...[
                              const SizedBox(height: AppSpace.card),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: brand,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpace.row),
                                  const Muted(
                                    'Waiting for receiver to connect...',
                                  ),
                                ],
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpace.card),
                  _vm.select(
                    (vm) => vm.selectedFiles.toList(),
                    (context, files) => TransferFilesCard(
                      files: files,
                      title:
                          '${files.length} ${files.length == 1 ? 'file' : 'files'} ready',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
