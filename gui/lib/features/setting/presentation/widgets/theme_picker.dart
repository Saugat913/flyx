import 'package:flutter/material.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_palette.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/core/theme/theme_controller.dart';
import 'package:hugeicons/hugeicons.dart';

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
            Expanded(child: _pickerTile(context, m)),
        ],
      ),
    );
  }

  Widget _pickerTile(BuildContext context, ThemeMode mode) {
    final selected = themeController.themeMode == mode;
    final (label, icon) = _meta[mode]!;
    final scheme = context.colorScheme;

    return GestureDetector(
      onTap: () => themeController.setTheme(mode),
      child: Column(
        spacing: 8,
        children: [
          SizedBox(
            height: 88,
            width: double.infinity,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(borderRadius: AppRadius.card),
              foregroundDecoration: BoxDecoration(
                borderRadius: AppRadius.card,
                border: Border.all(
                  color: selected ? scheme.primary : scheme.outlineVariant,
                  width: selected ? 2 : 1,
                ),
              ),
              child: switch (mode) {
                ThemeMode.dark => const ColoredBox(color: AppPalette.black),
                ThemeMode.light => const ColoredBox(color: AppPalette.white),
                ThemeMode.system => const Row(
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
            spacing: 5,
            children: [
              HugeIcon(
                icon: icon,
                size: 16,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
              Text(
                label,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
