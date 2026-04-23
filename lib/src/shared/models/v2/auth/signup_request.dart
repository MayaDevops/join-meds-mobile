/// Request model for user signup
class SignupRequest {
  final String username;
  final String password;
  final String? organizationName;
  final String? phone;
  final String? email;

  SignupRequest({
    required this.username,
    required this.password,
    this.organizationName,
    this.phone,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      if (organizationName != null) 'organization_name': organizationName,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
    };
  }
}
