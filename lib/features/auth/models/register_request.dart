class RegisterRequest {
  final String email;
  final String password;
  final String fullName;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email.trim(),
      'password': password,
      'full_name': fullName.trim(),
      'name': fullName.trim(),
    };
  }
}
