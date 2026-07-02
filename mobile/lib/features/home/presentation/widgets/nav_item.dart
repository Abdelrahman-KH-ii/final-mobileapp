import 'package:flutter/material.dart';

class NavItem {
  final String key;
  final IconData icon;
  final IconData activeIcon;

  const NavItem({
    required this.key,
    required this.icon,
    required this.activeIcon,
  });
}

const navItems = [
  NavItem(
    key: 'dashboard',
    icon: Icons.grid_view_rounded,
    activeIcon: Icons.grid_view_rounded,
  ),
  NavItem(
    key: 'my_farm',
    icon: Icons.eco_outlined,
    activeIcon: Icons.eco_rounded,
  ),
  NavItem(
    key: 'ai_models',
    icon: Icons.smart_toy_rounded,
    activeIcon: Icons.smart_toy_rounded,
  ),
  NavItem(
    key: 'market',
    icon: Icons.show_chart_rounded,
    activeIcon: Icons.show_chart_rounded,
  ),
];
