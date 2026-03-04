import 'package:flutter/material.dart';

class AppTextStyles {
  /// Headlines
  static TextStyle tabTitle(BuildContext context, {Color? color}) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      color: color ?? theme.colorScheme.onSurface,
    );
  }

  static TextStyle tabSubTitle(BuildContext context, {Color? color}) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: color ?? theme.colorScheme.onSecondary,
    );
  }

  static TextStyle sectionTitle(BuildContext context, {Color? color}) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: color ?? theme.colorScheme.onSecondary,
    );
  }

  static TextStyle modalSheetTitle(BuildContext context, {Color? color}) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: color ?? theme.colorScheme.onSurface,
    );
  }

  /// Body
  static TextStyle listTileTitle(BuildContext context, {Color? color}) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: color ?? theme.colorScheme.onSurface,
    );
  }

  static TextStyle listTileSubtitle(BuildContext context, {Color? color}) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color ?? theme.colorScheme.onSecondary,
    );
  }

  static TextStyle segmentedButtonLabel(BuildContext context, {Color? color}) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: color ?? theme.colorScheme.onSecondary,
    );
  }

  static TextStyle amountDisplayTitle(BuildContext context, {Color? color}) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w400,
      color: color ?? theme.colorScheme.onSurface,
    );
  }

  static TextStyle amountDisplayAmount(BuildContext context, {Color? color}) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 44,
      fontWeight: FontWeight.w700,
      color: color ?? theme.colorScheme.onSurface,
    );
  }

  static TextStyle text16w400(BuildContext context, {Color? color}) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: color ?? theme.colorScheme.onSurface,
    );
  }
}
