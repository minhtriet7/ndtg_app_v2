class Validators {
  const Validators._();

  static String? Function(String?) get validateEmail => email;
  static String? Function(String?) get validatePassword => password;

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required.';
    final valid = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text);
    if (!valid) return 'Please enter a valid email address.';
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Password is required.';
    if (text.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Confirm password is required.';
    if (value != password) return 'Passwords do not match.';
    return null;
  }

  static String? validateRequired(
      String? value, {
        String fieldName = 'This field',
        String? label,
      }) {
    final name = label ?? fieldName;
    if (value == null || value.trim().isEmpty) {
      return '$name is required.';
    }
    return null;
  }

  static String? Function(String?) required(String fieldName) {
    return (value) => validateRequired(value, fieldName: fieldName);
  }

  static String? validateNumber(
      String? value, {
        String fieldName = 'Value',
        double? min,
        double? max,
      }) {
    final requiredError = validateRequired(value, fieldName: fieldName);
    if (requiredError != null) return requiredError;

    final number = double.tryParse(value!.trim());
    if (number == null) return '$fieldName must be a valid number.';
    if (min != null && number < min) return '$fieldName must be at least $min.';
    if (max != null && number > max) return '$fieldName must be at most $max.';
    return null;
  }
}