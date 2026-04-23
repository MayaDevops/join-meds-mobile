/// Request model for sending OTP
class SendOtpRequest {
  final String phone;
  final String? purpose; // 'verification', 'reset_password', etc.

  SendOtpRequest({
    required this.phone,
    this.purpose,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      if (purpose != null) 'purpose': purpose,
    };
  }
}
