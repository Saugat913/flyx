import 'package:flutter/material.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_palette.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/core/theme/theme_controller.dart';
import 'package:hugeicons/hugeicons.dart';

final deviceName = ValueNotifier("Iphone 7"); 

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            vertical: AppSpace.screenV,
            horizontal: AppSpace.screenH,
          ),
          children: [
            Text("Settings", style: context.textTheme.titleLarge),
            SizedBox(height: AppSpace.gap),
            ProfileCard(),
            SizedBox(height: AppSpace.section),
            AppearanceSection(),
            SizedBox(height: AppSpace.section),
            TransferSection(),
            SizedBox(height: AppSpace.section),
            StorageSection(),
            SizedBox(height: AppSpace.section),
            AboutSection(),
          ],
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  Future<void> rename(BuildContext context) async {
    final c = TextEditingController(text: deviceName.value);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Rename device"),
        content: TextField(controller: c, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, c.text.trim()),
            child: Text("Save"),
          ),
        ],
      ),
    );
    c.dispose();
    if (name != null && name.isNotEmpty) deviceName.value = name;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.surfaceContainer,
      borderRadius: AppRadius.card,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => rename(context),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppSpace.gap,
            horizontal: AppSpace.row,
          ),
          child: ValueListenableBuilder(
            valueListenable: deviceName,
            builder: (context, name, _) => Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colorScheme.primaryFixedDim,
                  ),
                  child: Text(
                    name[0].toUpperCase(),
                    style: context.textTheme.titleSmall?.copyWith(
                      color: context.colorScheme.onPrimary,
                    ),
                  ),
                ),
                SizedBox(width: AppSpace.gap),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Device Name", style: context.textTheme.bodyLarge),
                    Text(name, style: context.textTheme.titleMedium),
                  ],
                ),
                Spacer(),
                HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textTheme.bodyLarge),
        SizedBox(height: AppSpace.gap),
        Material(
          color: context.colorScheme.surfaceContainer,
          borderRadius: AppRadius.card,
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Appearance", style: context.textTheme.bodyLarge),
        SizedBox(height: AppSpace.gap),
        ThemePicker(),
      ],
    );
  }
}

class ThemePicker extends StatelessWidget {
  const ThemePicker({super.key});

  static const _meta = {
    ThemeMode.dark: ('Dark', HugeIcons.strokeRoundedMoon02),
    ThemeMode.light: ('Light', HugeIcons.strokeRoundedSun03),
    ThemeMode.system: ('System', HugeIcons.strokeRoundedSmartPhone01),
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) => Row(
        spacing: AppSpace.gap,
        children: [
          for (final m in ThemeMode.values)
            Expanded(child: pickerTile(context, m)),
        ],
      ),
    );
  }

  Widget pickerTile(BuildContext context, ThemeMode mode) {
    final selected = themeController.themeMode == mode;
    final (label, icon) = _meta[mode]!;
    final scheme = context.colorScheme;

    return GestureDetector(
      onTap: () => themeController.setTheme(mode),
      child: Column(
        spacing: 6,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(borderRadius: AppRadius.card),
              foregroundDecoration: BoxDecoration(
                borderRadius: AppRadius.card,
                border: Border.all(
                  color: selected
                      ? context.appThemeColors.brand
                      : scheme.outlineVariant,
                  width: selected ? 2 : 1,
                ),
              ),
              child: switch (mode) {
                ThemeMode.dark => ColoredBox(color: AppPalette.black),
                ThemeMode.light => ColoredBox(color: AppPalette.white),
                ThemeMode.system => Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: ColoredBox(color: AppPalette.black)),
                    Expanded(child: ColoredBox(color: AppPalette.white)),
                  ],
                ),
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
            children: [
              HugeIcon(
                icon: icon,
                size: 16,
                color: selected ? scheme.primary : scheme.onSurface,
              ),
              Text(label, style: context.textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class TransferSection extends StatefulWidget {
  const TransferSection({super.key});

  @override
  State<TransferSection> createState() => _TransferSectionState();
}

class _TransferSectionState extends State<TransferSection> {
  bool autoAccept = false, trustedPeers = true, sounds = true;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: "Transfer",
      children: [
        SwitchListTile(
          secondary: HugeIcon(icon: HugeIcons.strokeRoundedBolt),
          title: Text("Auto-accept transfers"),
          subtitle: Text("Skip the confirmation prompt"),
          value: autoAccept,
          onChanged: (v) => setState(() => autoAccept = v),
        ),
        SwitchListTile(
          secondary: HugeIcon(icon: HugeIcons.strokeRoundedShield01),
          title: Text("Auto-accept trusted peers"),
          subtitle: Text("Devices you have paired before"),
          value: trustedPeers,
          onChanged: (v) => setState(() => trustedPeers = v),
        ),
        SwitchListTile(
          secondary: HugeIcon(icon: HugeIcons.strokeRoundedVolumeUp),
          title: Text("Transfer sounds"),
          value: sounds,
          onChanged: (v) => setState(() => sounds = v),
        ),
      ],
    );
  }
}

class StorageSection extends StatelessWidget {
  const StorageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: "Storage",
      children: [
        // ValueListenableBuilder(
        //   valueListenable: TransferRepository.instance.transfersNotifier,
        //   builder: (context, transfers, _) => ListTile(
        //     leading: HugeIcon(
        //       icon: HugeIcons.strokeRoundedCleaningBucket,
        //       color: context.colorScheme.error,
        //     ),
        //     title: Text(
        //       "Clear transfer history",
        //       style: TextStyle(color: context.colorScheme.error),
        //     ),
        //     subtitle: Text(
        //       transfers.isEmpty ? "Nothing to clear" : "${transfers.length} transfers",
        //     ),
        //     enabled: transfers.isNotEmpty,
        //     onTap: () {
        //       TransferRepository.instance.clearHistory();
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         SnackBar(content: Text("History cleared")),
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }
}

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  void soon(BuildContext context) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text("Coming soon")));

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: "About",
      children: [
        ListTile(
          leading: HugeIcon(icon: HugeIcons.strokeRoundedBadgeInfo),
          title: Text("Version"),
          trailing: Text("1.0.0"), 
        ),
        ListTile(
          leading: HugeIcon(icon: HugeIcons.strokeRoundedHelpCircle),
          title: Text("Help & support"),
          trailing: HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01),
          onTap: () => soon(context),
        ),
        ListTile(
          leading: HugeIcon(icon: HugeIcons.strokeRoundedFingerPrint),
          title: Text("Privacy policy"),
          trailing: HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01),
          onTap: () => soon(context),
        ),
      ],
    );
  }
}