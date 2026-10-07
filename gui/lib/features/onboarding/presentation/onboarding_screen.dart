import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flyx/core/media/images.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/features/shared/widgets/responsive_content_wrapper.dart';
import 'package:hugeicons/hugeicons.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      Flexible(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 200,
                            maxWidth: 200,
                          ),
                          child: SvgPicture.asset(
                            AppImage.logo,
                            fit: BoxFit.contain,
                          ),
                        ),
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
                      const _Feature(
                        icon: HugeIcons.strokeRoundedGlobe02,
                        title: 'Anywhere',
                        subtitle: 'Connect with a 6-digit code',
                      ),
                      const _Feature(
                        icon: HugeIcons.strokeRoundedLock,
                        title: 'Private',
                        subtitle: 'Direct device-to-device, nothing uploaded',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpace.section),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {},
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.appThemeColors.brandSubtle,
              borderRadius: AppRadius.icon,
            ),
            child: HugeIcon(icon: icon, color: context.appThemeColors.brand, size: 24),
          ),
           SizedBox(width: AppSpace.gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
