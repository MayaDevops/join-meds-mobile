/// Search parameters for job applications
class JobSearchParams {
  final int? userId;
  final int? jobId;
  final int? organizationId;
  final String? status;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? page;
  final int? pageSize;

  JobSearchParams({
    this.userId,
    this.jobId,
    this.organizationId,
    this.status,
    this.fromDate,
    this.toDate,
    this.page,
    this.pageSize,
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      if (userId != null) 'user_id': userId.toString(),
      if (jobId != null) 'job_id': jobId.toString(),
      if (organizationId != null) 'organization_id': organizationId.toString(),
      if (status != null) 'status': status,
      if (fromDate != null) 'from_date': fromDate!.toIso8601String(),
      if (toDate != null) 'to_date': toDate!.toIso8601String(),
      if (page != null) 'page': page.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
    };
  }
}
