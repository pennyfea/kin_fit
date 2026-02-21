import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/extensions/context_extensions.dart';

import '../../../routing/routes.dart';

/// Shell scaffold that provides persistent bottom navigation across tabs.
///
/// Uses [StatefulNavigationShell] from GoRouter to preserve state
/// across tab switches via IndexedStack.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: context.colorScheme.outlineVariant.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Feed tab
                _NavItem(
                  icon: Icons.dynamic_feed_outlined,
                  activeIcon: Icons.dynamic_feed,
                  label: 'Feed',
                  isSelected: navigationShell.currentIndex == 0,
                  onTap: () => _onTabTap(0),
                  color: theme.colorScheme.primary,
                ),

                // Groups tab
                _NavItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  label: 'Groups',
                  isSelected: navigationShell.currentIndex == 1,
                  onTap: () => _onTabTap(1),
                  color: theme.colorScheme.primary,
                ),

                // Center camera button
                _CameraButton(
                  onTap: () => context.push(Routes.camera),
                  color: theme.colorScheme.primary,
                ),

                // Stats tab
                _NavItem(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart,
                  label: 'Stats',
                  isSelected: navigationShell.currentIndex == 2,
                  onTap: () => _onTabTap(2),
                  color: theme.colorScheme.primary,
                ),

                // Profile tab
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  isSelected: navigationShell.currentIndex == 3,
                  onTap: () => _onTabTap(3),
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTabTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? color
                  : context.colorScheme.onSurface.withValues(alpha: 0.4),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? color
                    : context.colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraButton extends StatelessWidget {
  const _CameraButton({required this.onTap, required this.color});

  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 3),
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
