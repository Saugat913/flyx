import 'package:flutter/material.dart';
import 'package:flyx/core/route/route_config.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/features/shared/widgets/muted.dart';
import 'package:hugeicons/hugeicons.dart';

class TransferModeOption {
  final String title;
  final String subtitle;
  final String actionLabel;
  final AppRoute route;
  final List<List<dynamic>> icon;

  const TransferModeOption({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.route,
    required this.icon,
  });
}

class ModeSelectionList extends StatelessWidget {
  const ModeSelectionList({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<TransferModeOption> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return RadioGroup<int>(
      groupValue: selectedIndex,
      onChanged: (value) {
        if (value != null) onSelected(value);
      },
      child: ListView.separated(
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpace.gap),
        itemBuilder: (context, index) {
          final mode = options[index];
          final isSelected = index == selectedIndex;

          return Material(
            color: scheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.card,
              side: BorderSide(
                color: isSelected ? scheme.primary : scheme.outlineVariant,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => onSelected(index),
              child: Padding(
                padding: const EdgeInsets.all(AppSpace.card),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.icon,
                        color: isSelected
                            ? scheme.primary
                            : scheme.surfaceContainerHigh,
                      ),
                      child: HugeIcon(
                        icon: mode.icon,
                        size: 20,
                        color: isSelected
                            ? scheme.onPrimary
                            : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: AppSpace.gap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mode.title,
                            style: context.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Muted(mode.subtitle),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpace.row),
                    Radio<int>(value: index),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
