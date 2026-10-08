import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flyx/core/media/images.dart';
import 'package:flyx/core/route/route_config.dart';
import 'package:flyx/core/route/route_navigation.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/features/shared/widgets/responsive_content_wrapper.dart';
import 'package:hugeicons/hugeicons.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeBrightness = Theme.of(context).brightness;
    return Scaffold(
      body: SafeArea(
        child: ResponsiveContentWrapper(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final size = (constraints.maxWidth * 0.6).clamp(
                            160.0,
                            240.0,
                          );
                          return SizedBox(
                            width: size,
                            height: size,
                            child: SvgPicture.asset(
                              AppImage.onboarding2,
                              fit: BoxFit.contain,
                              colorMapper: AppImage.colorMapper(themeBrightness),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpace.section),
                      Text(
                        'Send files.\nSkip the cloud.',
                        textAlign: TextAlign.center,
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _Feature(
                        icon: HugeIcons.strokeRoundedWifi01,
                        title: 'Nearby',
                        subtitle: 'Share over Wi-Fi or LAN, no internet needed',
                      ),
                      SizedBox(height: AppSpace.card),
                      const _Feature(
                        icon: HugeIcons.strokeRoundedGlobe02,
                        title: 'Anywhere',
                        subtitle: 'Connect with a 6-digit code',
                      ),
                      SizedBox(height: AppSpace.card),
                      const _Feature(
                        icon: HugeIcons.strokeRoundedLock,
                        title: 'Private',
                        subtitle: 'Direct device-to-device, nothing uploaded',
                      ),
                      SizedBox(height: AppSpace.card),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpace.section),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {
                      context.pushTo(AppRoute.home);
                    },
                    child: const Text('Get started'),
                  ),
                ),
                const SizedBox(height: AppSpace.section),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final List<List<dynamic>> icon;
  final String title, subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.appThemeColors.brandSubtle,
            borderRadius: AppRadius.icon,
          ),
          child: HugeIcon(
            icon: icon,
            color: context.appThemeColors.brand,
            size: 24,
          ),
        ),
        SizedBox(width: AppSpace.gap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(subtitle, style: context.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
