class PersonalDataModel {
  final String? dob;
  final String? fullname;
  final String? email;
  final String? address;
  final String? aadhaarNo;
  final String? photoId;
  final String? resumeId;
  final String? profession;
  final String? academicStatus;
  final String? pgStatus;
  final String? speciality;
  final String? phdStatus;
  final String? workExperience;
  final String? clinicalNonclinical;
  final String? countryPreffered;
  final String? foreignTest;
  final String? foreignTestDetails;
  final String? foreignCountryExp;
  final String? languageTest;
  final String? languageTestCleared;
  final String? passportNumber;
  final String? certification;
  final String? userId;

  PersonalDataModel({
    this.dob,
    this.fullname,
    this.email,
    this.address,
    this.aadhaarNo,
    this.photoId,
    this.resumeId,
    this.profession,
    this.academicStatus,
    this.pgStatus,
    this.speciality,
    this.phdStatus,
    this.workExperience,
    this.clinicalNonclinical,
    this.countryPreffered,
    this.foreignTest,
    this.foreignTestDetails,
    this.foreignCountryExp,
    this.languageTest,
    this.languageTestCleared,
    this.passportNumber,
    this.certification,
    this.userId,
  });

  factory PersonalDataModel.fromJson(Map<String, dynamic> json) {
    return PersonalDataModel(
      dob: json['dob'],
      fullname: json['fullname'],
      email: json['email'],
      address: json['address'],
      aadhaarNo: json['aadhaarNo'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'dob': dob,
      'email': email,
      'address': address,
      'aadhaarNo': aadhaarNo,
      'userId': userId
    };
  }
}
