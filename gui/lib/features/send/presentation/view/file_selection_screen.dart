import 'package:flutter/material.dart';
import 'package:flyx/core/di/service_locator.dart';
import 'package:flyx/core/route/route_config.dart';
import 'package:flyx/core/route/route_navigation.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/core/utils/formatter.dart';
import 'package:flyx/core/viewmodel/view_model.dart';
import 'package:flyx/features/send/presentation/viewmodel/send_view_model.dart';
import 'package:flyx/features/shared/widgets/empty_state.dart';
import 'package:flyx/features/shared/widgets/muted.dart';
import 'package:flyx/features/shared/widgets/responsive_content_wrapper.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class FileSelectionScreen extends StatelessWidget {
  const FileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return getIt<SendViewModel>().watch((context, vm) {
      final selectedFiles = vm.selectedFiles.toList();
      final isEmpty = vm.isEmpty;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Select Files'),
          leading: IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedChevronLeft,
              color: scheme.onSurface,
            ),
            onPressed: () => context.pop(),
          ),
          actions: isEmpty
              ? null
              : [
                  TextButton(
                    onPressed: vm.clear,
                    child: const Text('Clear all'),
                  ),
                  const SizedBox(width: AppSpace.row),
                ],
        ),
        bottomNavigationBar: isEmpty
            ? null
            : ResponsiveBottomBar(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  border: Border(
                    top: BorderSide(color: scheme.outlineVariant),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${vm.selectedCount} ${vm.selectedCount == 1 ? 'file' : 'files'} selected',
                            style: context.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Muted(formatFileSize(vm.totalSize)),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        final expectedCount = await vm.pickFiles();
                        if (vm.selectedCount < expectedCount) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Some files were already added'),
                            ),
                          );
                        }
                      },
                      child: const Text('Add More'),
                    ),
                    const SizedBox(width: AppSpace.gap),
                    FilledButton(
                      onPressed: isEmpty
                          ? null
                          : () =>
                                context.pushTo(AppRoute.transferModeSelection),
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              ),
        body: SafeArea(
          child: ResponsiveContentWrapper(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.screenH,
              vertical: AppSpace.screenV,
            ),
            child: isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const EmptyState(
                          icon: HugeIcons.strokeRoundedFolder01,
                          title: 'Select files to send',
                          subtitle:
                              'Choose one or more files from your device.',
                        ),
                        const SizedBox(height: AppSpace.section),
                        FilledButton.icon(
                          onPressed: vm.pickFiles,
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedAdd01,
                            size: 18,
                            color: scheme.onPrimary,
                          ),
                          label: const Text('Browse files'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Material(
                      color: scheme.surfaceContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.card,
                        side: BorderSide(color: scheme.outlineVariant),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < selectedFiles.length; i++) ...[
                            if (i > 0) const Divider(),
                            Builder(
                              builder: (context) {
                                final file = selectedFiles[i];
                                return CheckboxListTile(
                                  secondary: Container(
                                    width: 40,
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: AppRadius.icon,
                                      color: scheme.surfaceContainerHigh,
                                    ),
                                    child: HugeIcon(
                                      icon: file.type.icon,
                                      size: 20,
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                  title: Text(
                                    file.name,
                                    style: context.textTheme.titleSmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Muted(formatFileSize(file.size)),
                                  value: true,
                                  onChanged: (_) => vm.removeFile(file),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      );
    });
  }
}
