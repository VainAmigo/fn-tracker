import 'package:flutter/material.dart';
import 'package:fn_tracker/l10n/l10.dart';

List<BottomNavDestination> mainBottomNavDestinations(BuildContext context) {
  final l10n = context.l10n;
  return [
    BottomNavDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: l10n.home,
    ),
    BottomNavDestination(
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet_rounded,
      label: l10n.finance,
    ),
    BottomNavDestination(
      icon: Icons.add_circle_outline,
      selectedIcon: Icons.add_circle_rounded,
      label: l10n.analytics,
    ),
    BottomNavDestination(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      label: l10n.settings,
    ),
  ];
}

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
