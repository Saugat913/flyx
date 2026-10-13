import 'package:flutter/material.dart';
import 'package:flyx/core/di/service_locator.dart';
import 'package:flyx/core/services/file_picker_service.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/core/utils/formatter.dart';
import 'package:flyx/features/send/presentation/viewmodel/send_view_model.dart';
import 'package:flyx/features/shared/widgets/muted.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class FileSelectionScreen extends StatelessWidget {
  const FileSelectionScreen({super.key});

  Future<int> _pickFiles(BuildContext context) async {
    SendViewModel sendViewModel = getIt<SendViewModel>();
    final filePickerService = getIt<FilePickerService>();
    final files = await filePickerService.pickFiles();

    final previousCount = sendViewModel.selectedFilesCount;
    sendViewModel.addFiles(files);

    return previousCount + files.length;
  }

  @override
  Widget build(BuildContext context) {
    SendViewModel sendViewModel = getIt<SendViewModel>();

    return ValueListenableBuilder(
      valueListenable: sendViewModel.selectedFiles,
      builder: (context, files, _) {
        final selectedFiles = files.toList();
        final isEmpty = selectedFiles.isEmpty;
        final totalSize = selectedFiles.fold<int>(
          0,
          (sum, file) => sum + file.size,
        );

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
                      onPressed: sendViewModel.clear,
                      child: const Text('Clear'),
                    ),
                    SizedBox(width: AppSpace.gap),
                  ],
          ),
          bottomNavigationBar: isEmpty
              ? null
              : SafeArea(
                  child: Container(
                    padding: EdgeInsets.symmetric(
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
                                '${selectedFiles.length} selected',
                                style: context.textTheme.titleSmall,
                              ),
                              Muted(formatFileSize(totalSize)),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            final pickedCount = await _pickFiles(context);
                            if (sendViewModel.selectedFilesCount <
                                pickedCount) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Some files were already added',
                                  ),
                                ),
                              );
                              return;
                            }
                          },
                          child: const Text('Add More'),
                        ),
                        SizedBox(width: AppSpace.gap),
                        FilledButton(
                          onPressed: isEmpty ? null : () {},
                          child: const Text('Continue'),
                        ),
                      ],
                    ),
                  ),
                ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
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
                          SizedBox(height: AppSpace.gap),
                          Text(
                            'Select files to send',
                            style: context.textTheme.titleMedium,
                          ),
                          Muted('Choose one or more files from your device.'),
                          SizedBox(height: AppSpace.section),
                          FilledButton(
                            onPressed: () async {
                              await _pickFiles(context);
                            },
                            child: Text('Browse files'),
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
                            padding: EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              borderRadius: AppRadius.card,
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
                          onChanged: (_) {
                            sendViewModel.removeFile(file);
                          },
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );
  }
}
