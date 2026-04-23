import 'package:dio/dio.dart';
import '../../../../models/v2/organization/org_details_dto.dart';
import '../../../../models/v2/common/api_response.dart';

/// Organization repository interface
abstract class IOrganizationRepo {
  /// Save organization details
  Future<ApiResponse<OrgDetailsDTO>> saveOrg(
    OrgDetailsDTO org, {
    CancelToken? cancelToken,
  });

  /// Update organization details
  Future<ApiResponse<OrgDetailsDTO>> updateOrg(
    int id,
    OrgDetailsDTO org, {
    CancelToken? cancelToken,
  });

  /// Fetch organization by ID
  Future<ApiResponse<OrgDetailsDTO>> fetchOrg(
    int id, {
    CancelToken? cancelToken,
  });

  /// Fetch all organizations
  Future<ApiResponse<List<OrgDetailsDTO>>> fetchAllOrgs({
    CancelToken? cancelToken,
  });
}
