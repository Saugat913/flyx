import 'package:flutter/material.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    (icon: HugeIcons.strokeRoundedHome01, label: 'Home'),
    (icon: HugeIcons.strokeRoundedFileSync, label: 'Transfers'),
    (icon: HugeIcons.strokeRoundedSettings01, label: 'Setting'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          //NOTE: should override the background color to be transparent to show subtle top border
          backgroundColor: Colors.transparent,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          destinations: _items
              .map(
                (item) => NavigationDestination(
                  icon: HugeIcon(icon: item.icon, size: 24, color: context.colorScheme.primary),
                  selectedIcon: HugeIcon(icon: item.icon, size: 24),
                  label: item.label,
                ),
              )
              .toList(),
        ),
      ),
      body: SafeArea(child: navigationShell),
    );
  }
}
