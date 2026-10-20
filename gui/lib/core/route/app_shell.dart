import 'package:flutter/material.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_text_theme.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/features/home/presentation/view/home_screen.dart';
import 'package:flyx/features/setting/presentation/view/setting_screen.dart';
import 'package:flyx/features/transfer/presentation/view/transfer_screen.dart';
import 'package:hugeicons/hugeicons.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  static const _items = [
    (icon: HugeIcons.strokeRoundedHome01, label: 'Home'),
    (icon: HugeIcons.strokeRoundedFileSync, label: 'Transfers'),
    (icon: HugeIcons.strokeRoundedSettings01, label: 'Settings'),
  ];

  static const _pages = [
    HomeScreen(),
    TransferScreen(),
    SettingScreen(),
  ];

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialIndex;

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _index = widget.initialIndex;
    }
  }

  void _onSelect(int index) {
    if (_index == index) return;
    setState(() => _index = index);
  }

  Widget _buildSidebarItem(BuildContext context, int index) {
    final scheme = context.colorScheme;
    final item = AppShell._items[index];
    final selected = _index == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: () => _onSelect(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? scheme.surfaceContainerHigh
                      : Colors.transparent,
                  borderRadius: AppRadius.chip,
                ),
                child: HugeIcon(
                  icon: item.icon,
                  size: 22,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.label,
                style: (selected ? AppText.navLabelOn : AppText.navLabel)
                    .copyWith(
                      color: selected
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final body = IndexedStack(
      index: _index,
      children: AppShell._pages,
    );

    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _index != 0) {
          setState(() => _index = 0);
        }
      },
      child: context.isWide
          ? Scaffold(
              body: SafeArea(
                child: Row(
                  children: [
                    Container(
                      width: 92,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpace.section,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainer,
                        border: Border(
                          right: BorderSide(color: scheme.outlineVariant),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildSidebarItem(context, 0),
                          const SizedBox(height: AppSpace.card),
                          _buildSidebarItem(context, 1),
                          const Spacer(),
                          _buildSidebarItem(context, 2),
                        ],
                      ),
                    ),
                    Expanded(child: body),
                  ],
                ),
              ),
            )
          : Scaffold(
              bottomNavigationBar: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  border: Border(top: BorderSide(color: scheme.outlineVariant)),
                ),
                child: NavigationBar(
                  selectedIndex: _index,
                  backgroundColor: Colors.transparent,
                  onDestinationSelected: _onSelect,
                  destinations: AppShell._items
                      .map(
                        (item) => NavigationDestination(
                          icon: HugeIcon(
                            icon: item.icon,
                            size: 22,
                            color: scheme.onSurfaceVariant,
                          ),
                          selectedIcon: HugeIcon(
                            icon: item.icon,
                            size: 22,
                            color: scheme.primary,
                          ),
                          label: item.label,
                        ),
                      )
                      .toList(),
                ),
              ),
              body: SafeArea(child: body),
            ),
    );
  }
}
