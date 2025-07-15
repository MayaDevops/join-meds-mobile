class OrganisationSignup {
  final String orgName;
  final String officialEmail;
  final String officialPhone;
  final String incorporationNo;
  final String emailMobile;
  final String password;
  final String confPassword;
  final String createdAt;
  final String userType;

  OrganisationSignup({
    required this.orgName,
    required this.officialEmail,
    required this.officialPhone,
    required this.incorporationNo,
    required this.emailMobile,
    required this.password,
   required this.confPassword,
    required this.createdAt,
    required this.userType,
  });

  Map<String, dynamic> toJson() => {
    "orgName": orgName,
    "officialEmail": officialEmail,
    "officialPhone": officialPhone,
    "incorporationNo": incorporationNo,
    "emailMobile": emailMobile,
    "createdAt": createdAt,
    "password": password,
    "confPassword": confPassword,
    "userType": userType,
  };
}
