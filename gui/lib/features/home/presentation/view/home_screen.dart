import 'package:flutter/material.dart';
import 'package:flyx/core/di/service_locator.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/core/viewmodel/view_model.dart';
import 'package:flyx/features/home/presentation/widgets/branding.dart';
import 'package:flyx/features/home/presentation/widgets/home_action_section.dart';
import 'package:flyx/features/shared/widgets/empty_state.dart';
import 'package:flyx/features/shared/widgets/responsive_content_wrapper.dart';
import 'package:flyx/features/shared/widgets/transfer_record_tile.dart';
import 'package:flyx/features/transfer/presentation/viewmodel/transfer_history_view_model.dart';
import 'package:hugeicons/hugeicons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyVm = getIt<TransferHistoryViewModel>();

    return Scaffold(
      body: SingleChildScrollView(
        child: ResponsiveContentWrapper(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.screenH,
            vertical: AppSpace.screenV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Branding(),
              const SizedBox(height: AppSpace.card),
              const HomeActionSection(),
              const SizedBox(height: AppSpace.section),
              Text('Recent Activity', style: context.textTheme.titleMedium),
              const SizedBox(height: AppSpace.gap),
              historyVm.select(
                (vm) => vm.records.take(5).toList(),
                (context, recent) {
                  if (recent.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: AppSpace.section),
                      child: EmptyState(
                        icon: HugeIcons.strokeRoundedFileEmpty01,
                        title: 'No recent activity',
                        subtitle: 'Your recent files will appear here',
                      ),
                    );
                  }
                  return TransferRecordGroup(records: recent);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
