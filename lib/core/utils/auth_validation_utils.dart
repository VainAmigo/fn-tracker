class AuthValidationUtils {
  AuthValidationUtils._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите email';
    }

    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Некорректный email';
    }

    return null;
  }

  static String? password(
      String? value, {
        int minLength = 6,
      }) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }

    if (value.length < minLength) {
      return 'Минимум $minLength символов';
    }

    return null;
  }

  static String? confirmPassword(
      String? value,
      String originalPassword, {
        int minLength = 6,
      }) {
    if (value == null || value.isEmpty) {
      return 'Подтвердите пароль';
    }

    if (value.length < minLength) {
      return 'Минимум $minLength символов';
    }

    if (value != originalPassword) {
      return 'Пароли не совпадают';
    }

    return null;
  }
}