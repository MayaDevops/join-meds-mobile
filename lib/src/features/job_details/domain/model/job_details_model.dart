
/// Model for job details
class JobDetailsModel {
  final String? id;
  final String? userId;
  final String? orgId;
  final String? hiringFor;
  final String? yearExp;
  final String? skills;
  final String? natureJob;
  final String? payFrom;
  final String? payTo;
  final String? payRange;
  final String? jobDesc;
  final String? orgName;
  final DateTime? createdAt;

  const JobDetailsModel({
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

  /// Create from JSON
  factory JobDetailsModel.fromJson(Map<String, dynamic> json) {
    return JobDetailsModel(
      id: json['id'] ??
          json['_id'],
      userId: json['userId'] ??
          json['user_id'],
      orgId: json['orgId'] ??
          json['org_id'],
      hiringFor: json['hiringFor'] ??
          json['hiring_for'],
      yearExp: json['yearExp'] ??
          json['year_exp'],
      skills: json['skills'],
      natureJob: json['natureJob'] ??
          json['nature_job'],
      payFrom: json['payFrom'] ??
          json['pay_from'],
      payTo: json['payTo'] ??
          json['pay_to'],
      payRange: json['payRange'] ??
          json['pay_range'],
      jobDesc: json['jobDesc'] ??
          json['job_desc'],
      orgName: json['orgName'] ??
          json['org_name'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'orgId': orgId,
      'hiringFor': hiringFor,
      'yearExp': yearExp,
      'skills': skills,
      'natureJob': natureJob,
      'payFrom': payFrom,
      'payTo': payTo,
      'payRange': payRange,
      'jobDesc': jobDesc,
      'orgName': orgName,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  JobDetailsModel copyWith({
    String? id,
    String? userId,
    String? orgId,
    String? hiringFor,
    String? yearExp,
    String? skills,
    String? natureJob,
    String? payFrom,
    String? payTo,
    String? payRange,
    String? jobDesc,
    String? orgName,
    DateTime? createdAt,
  }) {
    return JobDetailsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orgId: orgId ?? this.orgId,
      hiringFor: hiringFor ?? this.hiringFor,
      yearExp: yearExp ?? this.yearExp,
      skills: skills ?? this.skills,
      natureJob: natureJob ?? this.natureJob,
      payFrom: payFrom ?? this.payFrom,
      payTo: payTo ?? this.payTo,
      payRange: payRange ?? this.payRange,
      jobDesc: jobDesc ?? this.jobDesc,
      orgName: orgName ?? this.orgName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if salary range is available
  bool get hasSalary =>
      (payFrom != null && payFrom!.isNotEmpty) ||
          (payTo != null && payTo!.isNotEmpty);

  /// Formatted salary for UI
  String get formattedSalary {
    if (payRange != null && payRange!.isNotEmpty) {
      return payRange!;
    }
    if (payFrom != null && payTo != null) {
      return '$payFrom - $payTo';
    }
    return 'Not disclosed';
  }

  @override
  String toString() {
    return 'JobDetailsModel(id: $id, hiringFor: $hiringFor, orgName: $orgName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JobDetailsModel &&
        other.id == id &&
        other.userId == userId &&
        other.orgId == orgId &&
        other.hiringFor == hiringFor &&
        other.yearExp == yearExp &&
        other.skills == skills &&
        other.natureJob == natureJob &&
        other.payFrom == payFrom &&
        other.payTo == payTo &&
        other.payRange == payRange &&
        other.jobDesc == jobDesc &&
        other.orgName == orgName;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      orgId,
      hiringFor,
      yearExp,
      skills,
      natureJob,
      payFrom,
      payTo,
      payRange,
      jobDesc,
      orgName,
    );
  }
}
