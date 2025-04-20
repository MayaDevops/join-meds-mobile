class SignupRequest {
  final String username;
  final String password;
  final String confirmPassword;
  final String emailMobile;

  SignupRequest({
    required this.username,
    required this.password,
    required this.confirmPassword,
    required this.emailMobile,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'confirmPassword': confirmPassword,
      'emailMobile': emailMobile,
    };
  }
}
