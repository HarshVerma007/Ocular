import 'package:flutter/material.dart';

/// App-wide constants — simplified for clean user journey.
class AppConstants {
  AppConstants._();

  // ─── Spacing ─────────────────────────────────────────────────────
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 12.0;
  static const double spacingLG = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacingHuge = 32.0;

  // ─── Border Radii ────────────────────────────────────────────────
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusFull = 100.0;

  // ─── Sizing ──────────────────────────────────────────────────────
  static const double searchBarHeight = 56.0;
  static const double bottomNavHeight = 64.0;

  // ─── Animation Durations ─────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 400);
  static const Duration animSlow = Duration(milliseconds: 600);

  // ─── Time Filters (simple) ───────────────────────────────────────
  static const List<String> timeFilters = [
    'All',
    'Today',
    'This Week',
    'This Month',
  ];

  // ─── Bottom Nav ──────────────────────────────────────────────────
  static const List<NavItem> navItems = [
    NavItem(label: 'Home', icon: Icons.home_rounded, activeIcon: Icons.home_rounded),
    NavItem(label: 'Search', icon: Icons.search_rounded, activeIcon: Icons.search_rounded),
    NavItem(label: 'Settings', icon: Icons.tune_rounded, activeIcon: Icons.tune_rounded),
  ];
}

/// Model for bottom navigation item data.
class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
