import 'package:flutter/material.dart';

final mainBottomNavDestinations = [
  const BottomNavDestination(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    label: 'Главная',
  ),
  const BottomNavDestination(
    icon: Icons.account_balance_wallet_outlined,
    selectedIcon: Icons.account_balance_wallet_rounded,
    label: 'Бюджет',
  ),
  const BottomNavDestination(
    icon: Icons.add_circle_outline,
    selectedIcon: Icons.add_circle_rounded,
    label: 'Аналитика',
  ),
  const BottomNavDestination(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
    label: 'Настройки',
  ),
];

class BottomNavDestination {
  const BottomNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
