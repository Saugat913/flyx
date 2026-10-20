import 'package:flutter/material.dart';
import 'package:flyx/core/di/service_locator.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/core/viewmodel/view_model.dart';
import 'package:flyx/features/setting/presentation/widgets/profile_card.dart';
import 'package:flyx/features/setting/presentation/widgets/settings_group.dart';
import 'package:flyx/features/setting/presentation/widgets/theme_picker.dart';
import 'package:flyx/features/shared/widgets/responsive_content_wrapper.dart';
import 'package:flyx/features/transfer/presentation/viewmodel/transfer_history_view_model.dart';
import 'package:hugeicons/hugeicons.dart';

export 'package:flyx/features/setting/presentation/widgets/profile_card.dart'
    show deviceName;

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  void _soon(BuildContext context) => ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Coming soon')));

  Widget _leadingIcon(BuildContext context, List<List<dynamic>> icon) {
    final scheme = context.colorScheme;
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: AppRadius.icon,
      ),
      child: HugeIcon(icon: icon, size: 20, color: scheme.onSurface),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = getIt<TransferHistoryViewModel>();
    final scheme = context.colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        child: ResponsiveContentWrapper(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpace.screenV,
            horizontal: AppSpace.screenH,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Settings', style: context.textTheme.titleLarge),
              const SizedBox(height: AppSpace.card),
              const ProfileCard(),
              const SizedBox(height: AppSpace.section),
              Text('Appearance', style: context.textTheme.titleSmall),
              const SizedBox(height: AppSpace.gap),
              const ThemePicker(),
              const SizedBox(height: AppSpace.section),
              vm.watch(
                (context, vm) => SettingsGroup(
                  title: 'Transfer',
                  children: [
                    SwitchListTile(
                      secondary: _leadingIcon(
                        context,
                        HugeIcons.strokeRoundedBolt,
                      ),
                      title: Text(
                        'Auto-accept transfers',
                        style: context.textTheme.titleSmall,
                      ),
                      subtitle: Text(
                        'Skip the confirmation prompt',
                        style: context.textTheme.bodySmall,
                      ),
                      value: vm.autoAccept,
                      onChanged: vm.setAutoAccept,
                    ),
                    SwitchListTile(
                      secondary: _leadingIcon(
                        context,
                        HugeIcons.strokeRoundedShield01,
                      ),
                      title: Text(
                        'Auto-accept trusted peers',
                        style: context.textTheme.titleSmall,
                      ),
                      subtitle: Text(
                        'Devices you have paired before',
                        style: context.textTheme.bodySmall,
                      ),
                      value: vm.trustedPeers,
                      onChanged: vm.setTrustedPeers,
                    ),
                    SwitchListTile(
                      secondary: _leadingIcon(
                        context,
                        HugeIcons.strokeRoundedVolumeUp,
                      ),
                      title: Text(
                        'Transfer sounds',
                        style: context.textTheme.titleSmall,
                      ),
                      value: vm.transferSounds,
                      onChanged: vm.setTransferSounds,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.section),
              vm.select(
                (vm) => vm.records.length,
                (context, count) => SettingsGroup(
                  title: 'Storage',
                  children: [
                    ListTile(
                      leading: _leadingIcon(
                        context,
                        HugeIcons.strokeRoundedDownload04,
                      ),
                      title: Text(
                        'Save received to',
                        style: context.textTheme.titleSmall,
                      ),
                      trailing: Text(
                        'Downloads/Flyx',
                        style: context.textTheme.bodySmall,
                      ),
                    ),
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: scheme.errorContainer,
                          borderRadius: AppRadius.icon,
                        ),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedDelete02,
                          size: 20,
                          color: scheme.error,
                        ),
                      ),
                      title: Text(
                        'Clear transfer history',
                        style: context.textTheme.titleSmall?.copyWith(
                          color: scheme.error,
                        ),
                      ),
                      subtitle: Text(
                        count == 0
                            ? 'Nothing to clear'
                            : '$count ${count == 1 ? 'transfer' : 'transfers'}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: scheme.error.withValues(alpha: 0.8),
                        ),
                      ),
                      enabled: count > 0,
                      onTap: () {
                        vm.clearHistory();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Transfer history cleared'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.section),
              SettingsGroup(
                title: 'About',
                children: [
                  ListTile(
                    leading: _leadingIcon(
                      context,
                      HugeIcons.strokeRoundedBadgeInfo,
                    ),
                    title: Text('Version', style: context.textTheme.titleSmall),
                    trailing: Text(
                      '1.0.0',
                      style: context.textTheme.bodySmall,
                    ),
                  ),
                  ListTile(
                    leading: _leadingIcon(
                      context,
                      HugeIcons.strokeRoundedHelpCircle,
                    ),
                    title: Text(
                      'Help & support',
                      style: context.textTheme.titleSmall,
                    ),
                    trailing: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      size: 18,
                      color: scheme.onSurfaceVariant,
                    ),
                    onTap: () => _soon(context),
                  ),
                  ListTile(
                    leading: _leadingIcon(
                      context,
                      HugeIcons.strokeRoundedFingerPrint,
                    ),
                    title: Text(
                      'Privacy policy',
                      style: context.textTheme.titleSmall,
                    ),
                    trailing: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      size: 18,
                      color: scheme.onSurfaceVariant,
                    ),
                    onTap: () => _soon(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
