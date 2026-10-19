import 'package:flutter/material.dart';
import 'package:flyx/core/di/service_locator.dart';
import 'package:flyx/core/route/route_config.dart';
import 'package:flyx/core/route/route_navigation.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/core/utils/formatter.dart';
import 'package:flyx/core/viewmodel/view_model.dart';
import 'package:flyx/features/send/presentation/viewmodel/send_view_model.dart';
import 'package:flyx/features/shared/widgets/muted.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class FileSelectionScreen extends StatelessWidget {
  const FileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return getIt<SendViewModel>().watch((context, vm) {
      final selectedFiles = vm.selectedFiles.toList();
      final isEmpty = vm.isEmpty;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Select Files'),
          leading: IconButton(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedChevronLeft),
            onPressed: () => context.pop(),
          ),
          actions: isEmpty
              ? null
              : [
                  TextButton(
                    onPressed: vm.clear,
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: AppSpace.gap),
                ],
        ),
        bottomNavigationBar: isEmpty
            ? null
            : SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.screenH,
                    vertical: AppSpace.screenV,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: context.colorScheme.outlineVariant,
                      ),
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
                              '${vm.selectedCount} selected',
                              style: context.textTheme.titleSmall,
                            ),
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
                                content: Text(
                                  'Some files were already added',
                                ),
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
                            : () {
                                context.pushTo(AppRoute.transferModeSelection);
                              },
                        child: const Text('Continue'),
                      ),
                    ],
                  ),
                ),
              ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.screenH,
              vertical: AppSpace.screenV,
            ),
            child: isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedFolder01,
                          size: 64,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: AppSpace.gap),
                        Text(
                          'Select files to send',
                          style: context.textTheme.titleMedium,
                        ),
                        const Muted('Choose one or more files from your device.'),
                        const SizedBox(height: AppSpace.section),
                        FilledButton(
                          onPressed: vm.pickFiles,
                          child: const Text('Browse files'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: selectedFiles.length,
                    itemBuilder: (context, index) {
                      final file = selectedFiles[index];

                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.icon,
                            color: context.appThemeColors.brandSubtle,
                          ),
                          child: HugeIcon(
                            icon: file.type.icon,
                            size: 24,
                            color: context.appThemeColors.brand,
                          ),
                        ),
                        title: Text(
                          file.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(formatFileSize(file.size)),
                        value: true,
                        onChanged: (_) => vm.removeFile(file),
                      );
                    },
                  ),
          ),
        ),
      );
    });
  }
}
