/// Organization details DTO
/// Maps to JoinMedsOrgDetails from Swagger API
class OrgDetailsDTO {
  final int? id;
  final String? organizationName;
  final String? organizationType;
  final String? description;
  final String? industry;
  final String? website;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? logoUrl;
  final int? employeeCount;
  final List<String>? skillsRequired;
  final String? minSalary;
  final String? maxSalary;
  final bool? isVerified;
  final DateTime? foundedDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrgDetailsDTO({
    this.id,
    this.organizationName,
    this.organizationType,
    this.description,
    this.industry,
    this.website,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.logoUrl,
    this.employeeCount,
    this.skillsRequired,
    this.minSalary,
    this.maxSalary,
    this.isVerified,
    this.foundedDate,
    this.createdAt,
    this.updatedAt,
  });

  factory OrgDetailsDTO.fromJson(Map<String, dynamic> json) {
    return OrgDetailsDTO(
      id: json['id'],
      organizationName:
          json['organization_name'] ?? json['organizationName'],
      organizationType:
          json['organization_type'] ?? json['organizationType'],
      description: json['description'],
      industry: json['industry'],
      website: json['website'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postal_code'] ?? json['postalCode'],
      logoUrl: json['logo_url'] ?? json['logoUrl'],
      employeeCount: json['employee_count'] ?? json['employeeCount'],
      skillsRequired: json['skills_required'] != null
          ? List<String>.from(json['skills_required'])
          : null,
      minSalary: json['min_salary'] ?? json['minSalary'],
      maxSalary: json['max_salary'] ?? json['maxSalary'],
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
      foundedDate: json['founded_date'] != null
          ? DateTime.parse(json['founded_date'])
          : null,
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
      if (organizationName != null) 'organization_name': organizationName,
      if (organizationType != null) 'organization_type': organizationType,
      if (description != null) 'description': description,
      if (industry != null) 'industry': industry,
      if (website != null) 'website': website,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (postalCode != null) 'postal_code': postalCode,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (employeeCount != null) 'employee_count': employeeCount,
      if (skillsRequired != null) 'skills_required': skillsRequired,
      if (minSalary != null) 'min_salary': minSalary,
      if (maxSalary != null) 'max_salary': maxSalary,
      if (isVerified != null) 'is_verified': isVerified,
      if (foundedDate != null) 'founded_date': foundedDate!.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
