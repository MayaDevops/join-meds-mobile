/// Response model for authentication operations
class AuthResponse {
  final int? userId;
  final String? username;
  final String? email;
  final String? phone;
  final String? token;
  final String? refreshToken;
  final String? organizationName;
  final DateTime? createdAt;

  AuthResponse({
    this.userId,
    this.username,
    this.email,
    this.phone,
    this.token,
    this.refreshToken,
    this.organizationName,
    this.createdAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['user_id'] ?? json['userId'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      token: json['token'],
      refreshToken: json['refresh_token'] ?? json['refreshToken'],
      organizationName: json['organization_name'] ?? json['organizationName'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (token != null) 'token': token,
      if (refreshToken != null) 'refresh_token': refreshToken,
      if (organizationName != null) 'organization_name': organizationName,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
