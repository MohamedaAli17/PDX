/// ============================================================
/// FILE: bottom_nav.dart
/// PURPOSE: Persistent 5-tab bottom navigation bar and the scaffold
///          shell that wraps all primary screens via go_router.
/// AUTHOR:
/// LAST UPDATED:
/// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdx_airport/theme/app_theme.dart';

/// Renders the 5-tab bottom navigation bar (Home, Flights, Map, Offers, My PDX).
/// Manages no internal state — [currentIndex] and [onTap] are controlled
/// by the parent [PdxBottomNavShell].
class PdxBottomNav extends StatelessWidget {
  const PdxBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  // Index of the currently active tab — matches go_router branch order
  final int currentIndex;

  // Callback fired when the user taps a tab; receives the new tab index
  final ValueChanged<int> onTap;

  // Static tab definitions — order must match StatefulShellBranch order in main.dart
  static const _tabs = [
    _NavTab(label: 'Home', icon: Icons.home_outlined, route: '/'),
    _NavTab(
      label: 'Flights',
      icon: Icons.flight_takeoff,
      route: '/flights',
    ),
    _NavTab(label: 'Map', icon: Icons.map_outlined, route: '/map'),
    _NavTab(
      label: 'Offers',
      icon: Icons.local_offer_outlined,
      route: '/offers',
    ),
    _NavTab(
      label: 'My PDX',
      icon: Icons.person_outline,
      route: '/mypdx',
    ),
  ];

  /// Maps a go_router location string to the corresponding tab index.
  /// [location] is the current route path (e.g. '/flights').
  /// Returns the matching tab index, or 0 (Home) if no match is found.
  static int indexForLocation(String location) {
    // Strip trailing slash so '/flights/' matches '/flights'
    final normalizedLocation = location.endsWith('/') && location.length > 1
        ? location.substring(0, location.length - 1)
        : location;

    for (var tabIndex = 0; tabIndex < _tabs.length; tabIndex++) {
      if (_tabs[tabIndex].route == normalizedLocation ||
          _tabs[tabIndex].route == location) {
        return tabIndex;
      }
    }
    return 0;
  }

  /// Builds the bottom nav bar with PDX green selected state and grey unselected state.
  /// Returns a [Container] wrapping a [BottomNavigationBar] inside a [SafeArea].
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bottomNavBackground,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          selectedItemColor: AppColors.bottomNavSelected,
          unselectedItemColor: AppColors.bottomNavUnselected,
          selectedLabelStyle: AppTypography.caption(AppColors.bottomNavSelected)
              .copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              AppTypography.caption(AppColors.bottomNavUnselected),
          items: [
            for (final navTab in _tabs)
              BottomNavigationBarItem(
                icon: Icon(navTab.icon),
                activeIcon: Icon(navTab.icon),
                label: navTab.label,
              ),
          ],
        ),
      ),
    );
  }
}

/// Scaffold wrapper that keeps the bottom nav visible across all tab routes.
/// Holds a [StatefulNavigationShell] from go_router and delegates tab
/// switching via [navigationShell.goBranch].
class PdxBottomNavShell extends StatelessWidget {
  const PdxBottomNavShell({
    super.key,
    required this.navigationShell,
  });

  // go_router shell that owns each tab's navigator stack
  final StatefulNavigationShell navigationShell;

  /// Handles bottom nav tap — switches to the branch at [selectedTabIndex].
  /// [selectedTabIndex] is the index of the tapped tab (0–4).
  /// Re-tapping the active tab resets that branch to its initial route.
  void _onTabSelected(int selectedTabIndex) {
    navigationShell.goBranch(
      selectedTabIndex,
      initialLocation: selectedTabIndex == navigationShell.currentIndex,
    );
  }

  /// Builds a [Scaffold] with the active tab body and persistent bottom nav.
  /// Returns the shell scaffold widget tree.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: PdxBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}

/// Internal data class describing a single bottom nav tab.
/// Holds the display label, Material icon, and go_router path.
class _NavTab {
  const _NavTab({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}
