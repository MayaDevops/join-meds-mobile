class SignupRequest {
  final String orgName;
  final String officialEmail;
  final String officialPhone;
  final String incorporationNo;
  final String emailMobile;
  final String password;
  final String confirmPassword;
  final String createdAt;
  final String userType;

  SignupRequest({
    required this.orgName,
    required this.officialEmail,
    required this.officialPhone,
    required this.incorporationNo,
    required this.emailMobile,
    required this.password,
    required this.confirmPassword,
    required this.createdAt,
    required this.userType,
  });

  Map<String, dynamic> toJson() => {
    "orgName": orgName,
    "officialEmail": officialEmail,
    "officialPhone": officialPhone,
    "incorporationNo": incorporationNo,
    "emailMobile": emailMobile,
    "password": password,
    "confirmPassword": confirmPassword,
    "createdAt": createdAt,
    "userType": userType,
  };
}
