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
    final sendBtn = _ActionButton(
      isPrimary: true,
      title: 'Send Files',
      subtitle: 'Share to nearby devices or via 6-digit code.',
      icon: HugeIcons.strokeRoundedSend,
      onTap: () => context.pushTo(AppRoute.fileSelector),
    );

    final receiveBtn = _ActionButton(
      title: 'Receive Files',
      subtitle: 'Enter a code or wait for a nearby sender.',
      icon: HugeIcons.strokeRoundedDownload01,
      onTap: () => context.pushTo(AppRoute.receiveModeSelection),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 520) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: sendBtn),
                const SizedBox(width: AppSpace.gap),
                Expanded(child: receiveBtn),
              ],
            ),
          );
        }
        return Column(
          children: [
            sendBtn,
            const SizedBox(height: AppSpace.gap),
            receiveBtn,
          ],
        );
      },
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
    final scheme = context.colorScheme;

    final backgroundColor = isPrimary ? null : scheme.surfaceContainer;
    final border = isPrimary
        ? null
        : Border.all(color: scheme.outlineVariant);
    final gradient = isPrimary
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppPalette.cyanDark,
              AppPalette.cyan,
            ],
          )
        : null;
    final iconBackgroundColor = isPrimary
        ? AppPalette.white.withValues(alpha: 0.18)
        : scheme.surfaceContainerHigh;
    final iconColor = isPrimary ? AppPalette.white : scheme.onSurface;
    final titleColor = isPrimary ? AppPalette.white : scheme.onSurface;
    final subtitleColor = isPrimary
        ? AppPalette.white.withValues(alpha: 0.88)
        : scheme.onSurfaceVariant;

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
                padding: const EdgeInsets.all(AppSpace.card),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        borderRadius: AppRadius.icon,
                      ),
                      alignment: Alignment.center,
                      child: HugeIcon(icon: icon, size: 20, color: iconColor),
                    ),
                    const SizedBox(width: AppSpace.gap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: titleColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpace.row),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      size: 18,
                      color: subtitleColor,
                    ),
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
