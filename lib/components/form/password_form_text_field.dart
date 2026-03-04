import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';

class PasswordVisibilityNotifier extends ChangeNotifier {
  bool _isObscure = true;

  bool get isObscure => _isObscure;
  void toggleVisibility() {
    _isObscure = !_isObscure;
    notifyListeners();
  }
}

class PasswordTextField extends StatelessWidget {
  const PasswordTextField({
    required this.controller,
    required this.passwordVisibilityNotifier,
    this.label,
    this.onChanged,
    this.validator,
    super.key,
  });

  final TextEditingController controller;
  final String? label;
  final PasswordVisibilityNotifier passwordVisibilityNotifier;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: passwordVisibilityNotifier,
      builder: (BuildContext context, Widget? child) {
        return CustomTextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          keyboardType: TextInputType.visiblePassword,
          label: label,
          obscureText: passwordVisibilityNotifier.isObscure,
          maxLines: 1,
          suffixIcon: IconButton(
            icon: Icon(
              passwordVisibilityNotifier.isObscure ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              passwordVisibilityNotifier.toggleVisibility();
            },
          ),
        );
      },
    );
  }
}
