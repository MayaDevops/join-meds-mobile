/// Job application DTO
/// Maps to the new job-applied API response
class JobAppliedDTO {
  final String? id;  // UUID format
  final String? userId;  // UUID format
  final String? orgId;  // UUID format
  final String? orgName;  // Organization name
  final String? fullname;  // Applicant full name
  final String? hiringFor;  // Job title
  final String? natureJob;  // Job type (full-time, part-time, etc.)
  final String? emailMobile;  // Email or mobile
  final String? email;  // Email address
  final String? jobId;  // UUID format
  final String? resumeId;  // Resume ID
  final DateTime? submittedAt;  // Submission date
  final String? payFrom;  // Minimum salary
  final String? payTo;  // Maximum salary
  final String? payRange;  // Salary range description
  final String? status;  // Application status: 'pending', 'reviewed', 'accepted', 'rejected'
  final DateTime? createdAt;  // Record creation timestamp

  JobAppliedDTO({
    this.id,
    this.userId,
    this.orgId,
    this.orgName,
    this.fullname,
    this.hiringFor,
    this.natureJob,
    this.emailMobile,
    this.email,
    this.jobId,
    this.resumeId,
    this.submittedAt,
    this.payFrom,
    this.payTo,
    this.payRange,
    this.status,
    this.createdAt,
  });

  factory JobAppliedDTO.fromJson(Map<String, dynamic> json) {
    return JobAppliedDTO(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      orgId: json['orgId']?.toString(),
      orgName: json['orgName'],
      fullname: json['fullname'],
      hiringFor: json['hiringFor'],
      natureJob: json['natureJob'],
      emailMobile: json['emailMobile'],
      email: json['email'],
      jobId: json['jobId']?.toString(),
      resumeId: json['resumeId'],
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'])
          : null,
      payFrom: json['payFrom'],
      payTo: json['payTo'],
      payRange: json['payRange'],
      status: json['status'],
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
      if (orgName != null) 'orgName': orgName,
      if (fullname != null) 'fullname': fullname,
      if (hiringFor != null) 'hiringFor': hiringFor,
      if (natureJob != null) 'natureJob': natureJob,
      if (emailMobile != null) 'emailMobile': emailMobile,
      if (email != null) 'email': email,
      if (jobId != null) 'jobId': jobId,
      if (resumeId != null) 'resumeId': resumeId,
      if (submittedAt != null) 'submittedAt': submittedAt!.toIso8601String(),
      if (payFrom != null) 'payFrom': payFrom,
      if (payTo != null) 'payTo': payTo,
      if (payRange != null) 'payRange': payRange,
      if (status != null) 'status': status,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  /// Helper method to get display salary
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

  /// Helper method to format job type
  String getJobTypeDisplay() {
    return natureJob ?? 'Full Time';
  }

  /// Get status color for badge
  int getStatusColor() {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return 0xFF4CAF50; // Green
      case 'rejected':
        return 0xFFF44336; // Red
      case 'reviewed':
        return 0xFF2196F3; // Blue
      case 'pending':
      default:
        return 0xFFFFC107; // Yellow/Amber
    }
  }

  /// Get status display text
  String getStatusText() {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'reviewed':
        return 'Reviewed';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }
}
