import 'package:flutter/material.dart';
import 'package:fn_tracker/theme/themes.dart';

class SelectableCard extends StatelessWidget {
  const SelectableCard({
    this.child,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.selectedBackgroundColor,
    this.selectedBorderColor,
    this.isSelected = false,
    this.height,
    this.width,
    super.key,
  });

  final Widget? child;
  final void Function()? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? selectedBackgroundColor;
  final Color? selectedBorderColor;
  final bool isSelected;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final backgroundColor = this.backgroundColor ?? colorScheme.secondary;
    final borderColor = this.borderColor ?? colorScheme.secondary;
    final selectedBackgroundColor =
        this.selectedBackgroundColor ?? colorScheme.secondary;
    final selectedBorderColor =
        this.selectedBorderColor ?? colorScheme.secondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: isSelected ? selectedBackgroundColor : backgroundColor,
          border: Border.all(
            width: 1,
            color: isSelected ? selectedBorderColor : borderColor,
          ),
          borderRadius: isSelected
              ? BorderRadius.circular(AppSizing.borderRadius100)
              : BorderRadius.circular(AppSizing.borderRadius8),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
