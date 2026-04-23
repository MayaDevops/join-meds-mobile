/// Request model for password reset
class ResetPasswordRequest {
  final String username;
  final String newPassword;
  final String? otp;

  ResetPasswordRequest({
    required this.username,
    required this.newPassword,
    this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'new_password': newPassword,
      if (otp != null) 'otp': otp,
    };
  }
}
