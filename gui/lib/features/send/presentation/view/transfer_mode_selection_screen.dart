import 'package:flutter/material.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class _TransferMode {
  final String title;
  final String subtitle;
  final List<List<dynamic>> icon;

  _TransferMode({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class TransferModeSelectionScreen extends StatefulWidget {
  const TransferModeSelectionScreen({super.key});

  @override
  State<TransferModeSelectionScreen> createState() =>
      _TransferModeSelectionScreenState();
}

class _TransferModeSelectionScreenState
    extends State<TransferModeSelectionScreen> {
  int _selectedMode = 0;

  final transferModes = [
    _TransferMode(
      title: "Nearby devices",
      subtitle: "Fastest option over the same WI-FI",
      icon: HugeIcons.strokeRoundedWifi01,
    ),
    _TransferMode(
      title: "6-digit code",
      subtitle: "Pair manually across networks",
      icon: HugeIcons.strokeRoundedKey01,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Mode'),
        leading: IconButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedChevronLeft),
          onPressed: () => context.pop(),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpace.screenH,
            vertical: AppSpace.screenV,
          ),
          child: FilledButton(onPressed: () {}, child: Text('Continue')),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpace.screenH,
            vertical: AppSpace.screenV,
          ),
          child: RadioGroup<int>(
            groupValue: _selectedMode,
            onChanged: (value) {
              setState(() {
                _selectedMode = value!;
              });
            },
            child: ListView.separated(
              itemCount: transferModes.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: AppSpace.gap),
              itemBuilder: (context, index) {
                final mode = transferModes[index];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.card,
                    color: context.colorScheme.surfaceContainer,
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.icon,
                        color: context.appThemeColors.brandSubtle,
                      ),
                      child: HugeIcon(
                        icon: mode.icon,
                        size: 24,
                        color: context.appThemeColors.brand,
                      ),
                    ),
                    title: Text(mode.title),
                    subtitle: Text(mode.subtitle),
                    trailing: Radio<int>(value: index),
                    onTap: () {
                      setState(() {
                        _selectedMode = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
