import 'package:flutter/material.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/features/home/presentation/widgets/home_action_section.dart';
import 'package:flyx/features/shared/widgets/branding.dart';
import 'package:flyx/features/shared/widgets/empty_state.dart';
import 'package:hugeicons/hugeicons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.screenH,
            vertical: AppSpace.screenV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Branding(),
              SizedBox(height: AppSpace.card),
              HomeActionSection(),
              SizedBox(height: AppSpace.section,),
              Text("Recent Activity",style: context.textTheme.titleMedium,),
              SizedBox(height: AppSpace.section + AppSpace.section,),
              EmptyState(icon: HugeIcons.strokeRoundedFileEmpty01, title: "No recent activity", subtitle: "Your recent files will appear here"),
            ],
          ),
        ),
      ),
    );
  }
}
