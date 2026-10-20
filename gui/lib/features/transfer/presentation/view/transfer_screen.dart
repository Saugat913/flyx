import 'package:flutter/material.dart';
import 'package:flyx/core/di/service_locator.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/core/viewmodel/view_model.dart';
import 'package:flyx/features/shared/models/transfer_record.dart';
import 'package:flyx/features/shared/widgets/empty_state.dart';
import 'package:flyx/features/shared/widgets/responsive_content_wrapper.dart';
import 'package:flyx/features/shared/widgets/transfer_record_tile.dart';
import 'package:flyx/features/transfer/presentation/viewmodel/transfer_history_view_model.dart';
import 'package:hugeicons/hugeicons.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = getIt<TransferHistoryViewModel>();
    final scheme = context.colorScheme;

    return Scaffold(
      body: ResponsiveContentWrapper(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpace.screenV,
          horizontal: AppSpace.screenH,
        ),
        child: vm.watch((context, vm) {
          final records = vm.filteredRecords;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Transfers', style: context.textTheme.titleLarge),
              const SizedBox(height: AppSpace.card),
              // Filter tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: AppSpace.row,
                  children: TransferHistoryFilter.values.map((filter) {
                    final isSelected = filter == vm.filter;
                    return GestureDetector(
                      onTap: () => vm.setFilter(filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.chip,
                          color: isSelected
                              ? scheme.primary
                              : scheme.surfaceContainer,
                          border: Border.all(
                            color: isSelected
                                ? scheme.primary
                                : scheme.outlineVariant,
                          ),
                        ),
                        child: Text(
                          filter.label,
                          style: context.textTheme.labelLarge?.copyWith(
                            color: isSelected
                                ? scheme.onPrimary
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpace.section),
              Text('History', style: context.textTheme.titleMedium),
              const SizedBox(height: AppSpace.gap),
              Expanded(
                child: records.isEmpty
                    ? const Center(
                        child: EmptyState(
                          title: 'No transfers yet',
                          subtitle:
                              'Files you send or receive will appear here.',
                          icon: HugeIcons.strokeRoundedInbox,
                        ),
                      )
                    : SingleChildScrollView(
                        child: TransferRecordGroup(records: records),
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
