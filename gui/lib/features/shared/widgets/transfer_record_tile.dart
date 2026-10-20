import 'package:flutter/material.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_palette.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/core/utils/formatter.dart';
import 'package:flyx/features/shared/models/file.dart';
import 'package:flyx/features/shared/models/file_types.dart';
import 'package:flyx/features/shared/models/transfer_record.dart';
import 'package:flyx/features/shared/widgets/muted.dart';
import 'package:hugeicons/hugeicons.dart';

class TransferRecordGroup extends StatelessWidget {
  const TransferRecordGroup({super.key, required this.records});

  final List<TransferRecord> records;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Material(
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < records.length; i++) ...[
            if (i > 0) const Divider(),
            _TransferRecordRow(record: records[i]),
          ],
        ],
      ),
    );
  }
}

class _TransferRecordRow extends StatelessWidget {
  const _TransferRecordRow({required this.record});

  final TransferRecord record;

  static (String title, List<FileType> types) _resolveTransferDisplay(
    List<FileModel> files,
  ) {
    if (files.isEmpty) return ('Transfer', const [FileType.other]);
    if (files.length == 1) return (files.first.name, [files.first.type]);

    final types = files.map((f) => f.type).toSet().take(4).toList();
    if (types.length == 1) {
      final onlyType = types.first;
      return ('${files.length} ${onlyType.pluralLabel}', types);
    }

    return ('${files.first.name} + ${files.length - 1} more', types);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isIncomplete = record.state == TransferRecordState.incomplete;
    final isSent = record.direction == TransferDirection.sent;
    final files = record.files;
    final fileCount = files.length;

    final (displayTitle, types) = _resolveTransferDisplay(files);

    final (statusIcon, statusColor) = switch ((isIncomplete, isSent)) {
      (true, _) => (HugeIcons.strokeRoundedCancel01, scheme.error),
      (_, true) => (
        HugeIcons.strokeRoundedArrowUpRight01,
        context.appThemeColors.brand,
      ),
      _ => (HugeIcons.strokeRoundedArrowDownLeft01, AppPalette.green),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.card,
        vertical: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: AppRadius.icon,
            ),
            child: types.length == 1
                ? HugeIcon(
                    icon: types.first.icon,
                    size: 20,
                    color: scheme.onSurface,
                  )
                : _TypeMosaic(types: types),
          ),
          const SizedBox(width: AppSpace.gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: context.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    HugeIcon(
                      icon: statusIcon,
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Muted(
                        isIncomplete
                            ? '${record.peerName} · Canceled'
                            : record.peerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.gap),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatFileSize(record.totalBytes),
                style: context.textTheme.titleSmall,
              ),
              const SizedBox(height: 2),
              Muted(fileCount == 1 ? '1 file' : '$fileCount files'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeMosaic extends StatelessWidget {
  const _TypeMosaic({required this.types});

  final List<FileType> types;

  @override
  Widget build(BuildContext context) {
    final iconColor = context.colorScheme.onSurface;

    if (types.length == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(icon: types[0].icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          HugeIcon(icon: types[1].icon, size: 14, color: iconColor),
        ],
      );
    }

    Widget cell(int index) =>
        HugeIcon(icon: types[index].icon, size: 12, color: iconColor);

    if (types.length == 3) {
      return Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [cell(0), cell(1)],
            ),
            Center(child: cell(2)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [cell(0), cell(1)],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [cell(2), cell(3)],
          ),
        ],
      ),
    );
  }
}

class TransferRecordTile extends StatelessWidget {
  const TransferRecordTile({super.key, required this.record});

  final TransferRecord record;

  @override
  Widget build(BuildContext context) =>
      TransferRecordGroup(records: [record]);
}
