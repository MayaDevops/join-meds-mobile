/// Work experience DTO
/// Maps to WorkExperienceResponse from Swagger API
class WorkExperienceDTO {
  final int? id;
  final int? userId;
  final String? institution;
  final String? position;
  final String? specialization;
  final String? startDate;
  final String? endDate;
  final bool? isCurrent;
  final String? description;
  final List<String>? responsibilities;
  final String? location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkExperienceDTO({
    this.id,
    this.userId,
    this.institution,
    this.position,
    this.specialization,
    this.startDate,
    this.endDate,
    this.isCurrent,
    this.description,
    this.responsibilities,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory WorkExperienceDTO.fromJson(Map<String, dynamic> json) {
    return WorkExperienceDTO(
      id: json['id'],
      userId: json['user_id'] ?? json['userId'],
      institution: json['institution'],
      position: json['position'],
      specialization: json['specialization'],
      startDate: json['start_date'] ?? json['startDate'],
      endDate: json['end_date'] ?? json['endDate'],
      isCurrent: json['is_current'] ?? json['isCurrent'] ?? false,
      description: json['description'],
      responsibilities: json['responsibilities'] != null
          ? List<String>.from(json['responsibilities'])
          : null,
      location: json['location'],
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
      if (institution != null) 'institution': institution,
      if (position != null) 'position': position,
      if (specialization != null) 'specialization': specialization,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (isCurrent != null) 'is_current': isCurrent,
      if (description != null) 'description': description,
      if (responsibilities != null) 'responsibilities': responsibilities,
      if (location != null) 'location': location,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
