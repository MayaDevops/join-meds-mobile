/// Response model for OTP operations
class OtpResponse {
  final bool verified;
  final String? message;
  final int? expiresIn; // seconds until OTP expires
  final DateTime? sentAt;

  OtpResponse({
    required this.verified,
    this.message,
    this.expiresIn,
    this.sentAt,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      verified: json['verified'] ?? false,
      message: json['message'],
      expiresIn: json['expires_in'] ?? json['expiresIn'],
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verified': verified,
      if (message != null) 'message': message,
      if (expiresIn != null) 'expires_in': expiresIn,
      if (sentAt != null) 'sent_at': sentAt!.toIso8601String(),
    };
  }
}
