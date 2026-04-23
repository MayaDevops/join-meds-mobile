/// Job details DTO
/// Maps to the new org-job API response
class JobDetailsDTO {
  final String? id;  // UUID format
  final String? userId;  // UUID format
  final String? orgId;  // UUID format
  final String? hiringFor;  // Job title/position
  final String? yearExp;  // Years of experience required
  final String? skills;  // Skills required (comma-separated or description)
  final String? natureJob;  // Nature of job (full-time, part-time, etc.)
  final String? payFrom;  // Minimum salary
  final String? payTo;  // Maximum salary
  final String? payRange;  // Salary range description
  final String? jobDesc;  // Job description
  final String? orgName;  // Organization name
  final DateTime? createdAt;

  JobDetailsDTO({
    this.id,
    this.userId,
    this.orgId,
    this.hiringFor,
    this.yearExp,
    this.skills,
    this.natureJob,
    this.payFrom,
    this.payTo,
    this.payRange,
    this.jobDesc,
    this.orgName,
    this.createdAt,
  });

  factory JobDetailsDTO.fromJson(Map<String, dynamic> json) {
    return JobDetailsDTO(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      orgId: json['orgId']?.toString(),
      hiringFor: json['hiringFor'],
      yearExp: json['yearExp'],
      skills: json['skills'],
      natureJob: json['natureJob'],
      payFrom: json['payFrom'],
      payTo: json['payTo'],
      payRange: json['payRange'],
      jobDesc: json['jobDesc'],
      orgName: json['orgName'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      if (orgId != null) 'orgId': orgId,
      if (hiringFor != null) 'hiringFor': hiringFor,
      if (yearExp != null) 'yearExp': yearExp,
      if (skills != null) 'skills': skills,
      if (natureJob != null) 'natureJob': natureJob,
      if (payFrom != null) 'payFrom': payFrom,
      if (payTo != null) 'payTo': payTo,
      if (payRange != null) 'payRange': payRange,
      if (jobDesc != null) 'jobDesc': jobDesc,
      if (orgName != null) 'orgName': orgName,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  // Helper method to get display salary
  String getSalaryDisplay() {
    if (payRange != null && payRange!.isNotEmpty) {
      return payRange!;
    }
    if (payFrom != null && payTo != null) {
      return '$payFrom - $payTo';
    }
    if (payTo != null) {
      return 'Up to $payTo';
    }
    if (payFrom != null) {
      return 'From $payFrom';
    }
    return 'Negotiable';
  }

  // Helper method to format job type
  String getJobTypeDisplay() {
    return natureJob ?? 'Full Time';
  }
}
