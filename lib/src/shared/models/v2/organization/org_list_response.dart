import 'org_details_dto.dart';

/// Response model for organization list
class OrgListResponse {
  final List<OrgDetailsDTO> organizations;
  final int total;
  final int page;
  final int pageSize;

  OrgListResponse({
    required this.organizations,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory OrgListResponse.fromJson(Map<String, dynamic> json) {
    return OrgListResponse(
      organizations: json['organizations'] != null
          ? (json['organizations'] as List)
              .map((org) => OrgDetailsDTO.fromJson(org))
              .toList()
          : [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? json['pageSize'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organizations': organizations.map((org) => org.toJson()).toList(),
      'total': total,
      'page': page,
      'page_size': pageSize,
    };
  }
}
