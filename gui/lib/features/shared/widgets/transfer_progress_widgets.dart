import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/core/utils/formatter.dart';
import 'package:flyx/features/shared/models/file.dart';
import 'package:flyx/features/shared/widgets/muted.dart';
import 'package:hugeicons/hugeicons.dart';

Future<bool> confirmCancelTransferDialog(
  BuildContext context, {
  required String message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Cancel transfer?'),
      content: Text(message),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Stay'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: dialogContext.colorScheme.error,
            foregroundColor: dialogContext.colorScheme.onError,
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Cancel transfer'),
        ),
      ],
    ),
  );
  return result == true;
}

class TransferCircularGauge extends StatelessWidget {
  const TransferCircularGauge({
    super.key,
    required this.progress,
    required this.activeIcon,
    this.isWaiting = false,
    this.isCompleted = false,
    this.centerLabel,
  });

  final double progress;
  final List<List<dynamic>> activeIcon;
  final bool isWaiting;
  final bool isCompleted;
  final String? centerLabel;

  @override
  Widget build(BuildContext context) {
    final brand = context.appThemeColors.brand;
    final scheme = context.colorScheme;

    return SizedBox.square(
      dimension: 180,
      child: CustomPaint(
        painter: _GaugePainter(
          progress: progress,
          brand: brand,
          trackColor: scheme.outlineVariant,
        ),
        child: Center(
          child: isWaiting
              ? SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.8,
                    color: brand,
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.appThemeColors.brandSubtle,
                        shape: BoxShape.circle,
                      ),
                      child: HugeIcon(
                        icon: isCompleted
                            ? HugeIcons.strokeRoundedTick02
                            : activeIcon,
                        color: brand,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      centerLabel ?? '${(progress * 100).round()}%',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontSize: centerLabel != null ? 22 : 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({
    required this.progress,
    required this.brand,
    required this.trackColor,
  });

  final double progress;
  final Color brand;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 9.0;
    final center = size.center(Offset.zero);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final arcPaint = Paint()
        ..color = brand
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.progress != progress ||
      old.brand != brand ||
      old.trackColor != trackColor;
}

class TransferStatsCard extends StatelessWidget {
  const TransferStatsCard({
    super.key,
    required this.fileCount,
    required this.totalBytes,
    required this.processedBytes,
    required this.speedBytesPerSec,
    this.processedLabel = 'Transferred',
  });

  final int fileCount;
  final int totalBytes;
  final int processedBytes;
  final int speedBytesPerSec;
  final String processedLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: AppRadius.card,
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _Row(
            label: 'Files',
            value: '$fileCount ${fileCount == 1 ? 'file' : 'files'}',
          ),
          const Divider(),
          _Row(label: 'Size', value: formatFileSize(totalBytes)),
          const Divider(),
          _Row(label: processedLabel, value: formatFileSize(processedBytes)),
          const Divider(),
          _Row(
            label: 'Speed',
            value: speedBytesPerSec > 0
                ? '${formatFileSize(speedBytesPerSec)}/s'
                : '—',
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.card,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Muted(label),
          Text(value, style: context.textTheme.titleSmall),
        ],
      ),
    );
  }
}

class TransferFilesCard extends StatelessWidget {
  const TransferFilesCard({
    super.key,
    required this.files,
    this.title = 'Files',
    this.fileProgress,
    this.showProgress = false,
  });

  final List<FileModel> files;
  final String title;
  final Map<FileModel, double>? fileProgress;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return const SizedBox.shrink();
    final brand = context.appThemeColors.brand;
    final scheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textTheme.titleSmall),
        const SizedBox(height: AppSpace.gap),
        Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: AppRadius.card,
            border: Border.all(color: scheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (int i = 0; i < files.length; i++) ...[
                if (i > 0) const Divider(),
                Builder(
                  builder: (context) {
                    final file = files[i];
                    final prog = fileProgress?[file] ?? 0.0;
                    final percent = (prog * 100).round();

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.card,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerHigh,
                                  borderRadius: AppRadius.icon,
                                ),
                                child: HugeIcon(
                                  icon: file.type.icon,
                                  size: 20,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: AppSpace.gap),
                              Expanded(
                                child: Text(
                                  file.name,
                                  style: context.textTheme.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSpace.row),
                              Muted(
                                showProgress
                                    ? '$percent% · ${formatFileSize(file.size)}'
                                    : formatFileSize(file.size),
                              ),
                            ],
                          ),
                          if (showProgress) ...[
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: AppRadius.chip,
                              child: LinearProgressIndicator(
                                value: prog,
                                minHeight: 5,
                                backgroundColor: scheme.surfaceContainerHigh,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  brand,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
