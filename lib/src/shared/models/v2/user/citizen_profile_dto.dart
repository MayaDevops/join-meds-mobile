/// Citizen profile details DTO
class CitizenProfileDTO {
  final int? userId;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? profession;
  final String? currentPosition;
  final String? organization;
  final int? yearsOfExperience;
  final List<String>? skills;
  final List<String>? languages;
  final String? bio;
  final String? linkedInUrl;
  final String? profilePictureUrl;
  final bool? isVerified;
  final DateTime? lastActive;

  CitizenProfileDTO({
    this.userId,
    this.fullName,
    this.email,
    this.phone,
    this.profession,
    this.currentPosition,
    this.organization,
    this.yearsOfExperience,
    this.skills,
    this.languages,
    this.bio,
    this.linkedInUrl,
    this.profilePictureUrl,
    this.isVerified,
    this.lastActive,
  });

  factory CitizenProfileDTO.fromJson(Map<String, dynamic> json) {
    return CitizenProfileDTO(
      userId: json['user_id'] ?? json['userId'],
      fullName: json['full_name'] ?? json['fullName'],
      email: json['email'],
      phone: json['phone'],
      profession: json['profession'],
      currentPosition: json['current_position'] ?? json['currentPosition'],
      organization: json['organization'],
      yearsOfExperience:
          json['years_of_experience'] ?? json['yearsOfExperience'],
      skills: json['skills'] != null ? List<String>.from(json['skills']) : null,
      languages:
          json['languages'] != null ? List<String>.from(json['languages']) : null,
      bio: json['bio'],
      linkedInUrl: json['linkedin_url'] ?? json['linkedInUrl'],
      profilePictureUrl:
          json['profile_picture_url'] ?? json['profilePictureUrl'],
      isVerified: json['is_verified'] ?? json['isVerified'],
      lastActive: json['last_active'] != null
          ? DateTime.parse(json['last_active'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      if (fullName != null) 'full_name': fullName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (profession != null) 'profession': profession,
      if (currentPosition != null) 'current_position': currentPosition,
      if (organization != null) 'organization': organization,
      if (yearsOfExperience != null) 'years_of_experience': yearsOfExperience,
      if (skills != null) 'skills': skills,
      if (languages != null) 'languages': languages,
      if (bio != null) 'bio': bio,
      if (linkedInUrl != null) 'linkedin_url': linkedInUrl,
      if (profilePictureUrl != null) 'profile_picture_url': profilePictureUrl,
      if (isVerified != null) 'is_verified': isVerified,
      if (lastActive != null) 'last_active': lastActive!.toIso8601String(),
    };
  }
}
