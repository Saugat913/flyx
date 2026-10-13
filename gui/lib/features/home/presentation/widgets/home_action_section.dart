import 'package:flutter/material.dart';
import 'package:flyx/core/route/route_config.dart';
import 'package:flyx/core/route/route_navigation.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_palette.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/features/home/presentation/widgets/ripple_effect.dart';
import 'package:hugeicons/hugeicons.dart';

class HomeActionSection extends StatelessWidget {
  const HomeActionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ActionButton(
          isPrimary: true,
          title: 'Send Files',
          subtitle: 'Share to nearby devices or via 6-digit code.',
          icon: HugeIcons.strokeRoundedSend,
          onTap: () {
            context.pushTo(AppRoute.fileSelector);
          },
        ),
        SizedBox(height: AppSpace.card),
        _ActionButton(
          title: 'Receive Files',
          subtitle: 'Enter a code or wait for a nearby sender.',
          icon: HugeIcons.strokeRoundedDownload01,
          onTap: () {},
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  final String title;
  final String subtitle;
  final List<List<dynamic>> icon;
  final VoidCallback onTap;

  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isPrimary
        ? null
        : context.colorScheme.surfaceContainer;
    final border = isPrimary
        ? null
        : Border.all(color: context.colorScheme.outlineVariant);
    final gradient = isPrimary
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.appThemeColors.brand,
              context.appThemeColors.brandSecondary,
            ],
          )
        : null;
    final iconBackgroundColor = isPrimary
        ? AppPalette.neutral50.withValues(alpha: 0.16)
        : context.appThemeColors.brandSubtle;
    final iconColor = isPrimary
        ? AppPalette.neutral50
        : context.appThemeColors.brand;
    final foregroundColor = isPrimary ? AppPalette.neutral50 : null;

    return Material(
      borderRadius: AppRadius.card,
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: AppRadius.card,
          border: border,
          gradient: gradient,
          color: backgroundColor,
        ),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              if (isPrimary) const RippleEffect(),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.card,
                  vertical: AppSpace.card + AppSpace.row,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        borderRadius: AppRadius.button,
                      ),
                      alignment: Alignment.center,
                      child: HugeIcon(icon: icon, size: 22, color: iconColor),
                    ),
                    const SizedBox(width: AppSpace.gap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: foregroundColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: foregroundColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpace.row),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
