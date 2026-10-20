import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flyx/core/di/service_locator.dart';
import 'package:flyx/core/media/images.dart';
import 'package:flyx/core/route/route_config.dart';
import 'package:flyx/core/route/route_navigation.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/features/shared/widgets/muted.dart';
import 'package:flyx/features/shared/widgets/responsive_content_wrapper.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeBrightness = Theme.of(context).brightness;
    return Scaffold(
      bottomNavigationBar: ResponsiveBottomBar(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: () async {
              await getIt<SharedPreferences>().setBool(kOnboardedPrefKey, true);
              if (context.mounted) {
                context.goTo(AppRoute.home);
              }
            },
            child: const Text('Get started'),
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: viewport.maxHeight),
              child: ResponsiveContentWrapper(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.screenH,
                  vertical: AppSpace.section,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: SvgPicture.asset(
                            AppImage.onboarding2,
                            fit: BoxFit.contain,
                            colorMapper: AppImage.colorMapper(themeBrightness),
                          ),
                        ),
                        const SizedBox(height: AppSpace.section),
                        Text(
                          'Send files.\nSkip the cloud.',
                          textAlign: TextAlign.center,
                          style: context.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.section),
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Feature(
                          icon: HugeIcons.strokeRoundedWifi01,
                          title: 'Nearby',
                          subtitle:
                              'Share over Wi-Fi or LAN, no internet needed',
                        ),
                        SizedBox(height: AppSpace.gap),
                        _Feature(
                          icon: HugeIcons.strokeRoundedGlobe02,
                          title: 'Anywhere',
                          subtitle: 'Connect with a 6-digit code',
                        ),
                        SizedBox(height: AppSpace.gap),
                        _Feature(
                          icon: HugeIcons.strokeRoundedLock,
                          title: 'Private',
                          subtitle:
                              'Direct device-to-device, nothing uploaded',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
    final scheme = context.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpace.card),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: AppRadius.card,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: AppRadius.icon,
            ),
            child: HugeIcon(
              icon: icon,
              color: scheme.onSurface,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpace.gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textTheme.titleSmall),
                const SizedBox(height: 2),
                Muted(subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
