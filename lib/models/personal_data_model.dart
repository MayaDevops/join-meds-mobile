class PersonalDataModel {
  final String? id;
  final String fullname;
  final String dob;
  final String email;
  final String address;
  final String aadhaarNo;

  PersonalDataModel({
    this.id,
    required this.fullname,
    required this.dob,
    required this.email,
    required this.address,
    required this.aadhaarNo,
  });

  Map<String, dynamic> toJson() => {
    "id": id ?? "3fa85f64-5717-4562-b3fc-2c963f66afa6", // optional
    "fullname": fullname,
    "dob": dob,
    "email": email,
    "address": address,
    "aadhaarNo": aadhaarNo,
  };
}