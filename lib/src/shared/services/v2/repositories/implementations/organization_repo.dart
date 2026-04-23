import 'package:dio/dio.dart';
import '../../../../../core/constants/v2_api_constants.dart';
import '../../../../models/v2/organization/org_details_dto.dart';
import '../../../../models/v2/common/api_response.dart';
import '../../../api/api_client.dart';
import '../interfaces/i_organization_repo.dart';

/// Organization repository implementation
class OrganizationRepo implements IOrganizationRepo {
  final ApiClient _apiClient;

  OrganizationRepo(this._apiClient);

  @override
  Future<ApiResponse<OrgDetailsDTO>> saveOrg(
    OrgDetailsDTO org, {
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.postTyped<OrgDetailsDTO>(
      V2ApiConstants.saveOrg,
      data: org.toJson(),
      fromJson: (json) => OrgDetailsDTO.fromJson(json),
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<OrgDetailsDTO>> updateOrg(
    int id,
    OrgDetailsDTO org, {
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.putTyped<OrgDetailsDTO>(
      V2ApiConstants.updateOrg(id),
      data: org.toJson(),
      fromJson: (json) => OrgDetailsDTO.fromJson(json),
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<OrgDetailsDTO>> fetchOrg(
    int id, {
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.getTyped<OrgDetailsDTO>(
      V2ApiConstants.fetchOrg(id),
      fromJson: (json) => OrgDetailsDTO.fromJson(json),
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<List<OrgDetailsDTO>>> fetchAllOrgs({
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.getList<OrgDetailsDTO>(
      V2ApiConstants.fetchAllOrgs,
      fromJson: (json) => OrgDetailsDTO.fromJson(json),
      cancelToken: cancelToken,
    );
  }
}
