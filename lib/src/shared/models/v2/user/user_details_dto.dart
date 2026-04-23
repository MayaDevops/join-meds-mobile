/// Comprehensive user details DTO
/// Maps to UserDetailsDTO from Swagger API
class UserDetailsDTO {
  final int? id;
  final int? userId;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final String? profession;
  final List<String>? qualifications;
  final List<String>? certifications;
  final String? experience;
  final String? currentLocation;
  final List<String>? preferredLocations;
  final String? salaryExpectation;
  final String? availability;
  final String? profilePictureUrl;
  final String? resumeUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserDetailsDTO({
    this.id,
    this.userId,
    this.fullName,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.profession,
    this.qualifications,
    this.certifications,
    this.experience,
    this.currentLocation,
    this.preferredLocations,
    this.salaryExpectation,
    this.availability,
    this.profilePictureUrl,
    this.resumeUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserDetailsDTO.fromJson(Map<String, dynamic> json) {
    return UserDetailsDTO(
      id: json['id'],
      userId: json['user_id'] ?? json['userId'],
      fullName: json['full_name'] ?? json['fullName'],
      email: json['email'],
      phone: json['phone'],
      dateOfBirth: json['date_of_birth'] ?? json['dateOfBirth'],
      gender: json['gender'],
      profession: json['profession'],
      qualifications: json['qualifications'] != null
          ? List<String>.from(json['qualifications'])
          : null,
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications'])
          : null,
      experience: json['experience'],
      currentLocation: json['current_location'] ?? json['currentLocation'],
      preferredLocations: json['preferred_locations'] != null
          ? List<String>.from(json['preferred_locations'])
          : null,
      salaryExpectation:
          json['salary_expectation'] ?? json['salaryExpectation'],
      availability: json['availability'],
      profilePictureUrl:
          json['profile_picture_url'] ?? json['profilePictureUrl'],
      resumeUrl: json['resume_url'] ?? json['resumeUrl'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (fullName != null) 'full_name': fullName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (profession != null) 'profession': profession,
      if (qualifications != null) 'qualifications': qualifications,
      if (certifications != null) 'certifications': certifications,
      if (experience != null) 'experience': experience,
      if (currentLocation != null) 'current_location': currentLocation,
      if (preferredLocations != null) 'preferred_locations': preferredLocations,
      if (salaryExpectation != null) 'salary_expectation': salaryExpectation,
      if (availability != null) 'availability': availability,
      if (profilePictureUrl != null) 'profile_picture_url': profilePictureUrl,
      if (resumeUrl != null) 'resume_url': resumeUrl,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
