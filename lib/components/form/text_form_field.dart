import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    this.readOnly = false,
    this.autofocus = false,
    this.onTap,
    this.controller,
    this.hintText,
    this.label,
    this.shadowColor,
    this.elevation,
    this.maxLines,
    this.suffixIcon,
    this.keyboardType,
    this.suffixText,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.prefixText,
    this.inputFormatters,
    this.prefix,
    this.obscureText,
    super.key,
  });

  final void Function()? onTap;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final String? hintText;
  final String? label;
  final Color? shadowColor;
  final double? elevation;
  final int? maxLines;
  final Widget? suffixIcon;
  final bool readOnly;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final String? suffixText;
  final String? Function(String?)? validator;
  final bool autofocus;
  final Widget? prefix;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;
  final bool? obscureText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: label != null ? 16 : 0),
      child: TextFormField(
        validator: validator,
        onTap: onTap,
        onChanged: onChanged,
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        keyboardType: keyboardType,
        autofocus: autofocus,
        inputFormatters: inputFormatters,
        obscureText: obscureText ?? false,
        decoration: InputDecoration(
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,
          prefix: prefix,
          hintText: hintText,
          labelText: label,
          suffixIcon: suffixIcon,
          suffixText: suffixText,
          prefixText: prefixText,
          prefixIcon: prefixIcon,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}
