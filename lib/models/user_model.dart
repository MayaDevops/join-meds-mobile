class UserModel {
  String? fullname;
  String? emailMobile;
  String? profession;
  String? profileUrl;


  UserModel({this.fullname, this.emailMobile,this.profession,this.profileUrl});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullname: json['fullname'],
      emailMobile: json['emailMobile'],
      profession: json['profession'],
      profileUrl: json['profileUrl'],
    );
  }
}
