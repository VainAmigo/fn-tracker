import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    super.key,
    required this.onPressed,
    this.child,
    this.text,
    this.backgroundColor,
    this.foregroundColor,
  });

  final void Function()? onPressed;
  final String? text;
  final Widget? child;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        foregroundColor: foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        elevation: 0,
      ),
      child: child ?? Text(text ?? ''),
    );
  }
}
