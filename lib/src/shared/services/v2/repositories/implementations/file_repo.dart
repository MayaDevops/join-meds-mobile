import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/constants/v2_api_constants.dart';
import '../../../../models/v2/common/api_response.dart';
import '../../../../models/v2/common/file_upload_response.dart';
import '../../../api/api_client.dart';
import '../interfaces/i_file_repo.dart';

/// File repository implementation
class FileRepo implements IFileRepo {
  final ApiClient _apiClient;

  FileRepo(this._apiClient);

  @override
  Future<ApiResponse<FileUploadResponse>> uploadResume(
    String userId,
    File file, {
    void Function(int, int)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    return await _apiClient.uploadFile<FileUploadResponse>(
      V2ApiConstants.uploadResume(userId),
      data: formData,
      fromJson: (json) => FileUploadResponse.fromJson(json),
      onSendProgress: onProgress,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<FileUploadResponse>> uploadImage(
    String userId,
    File file, {
    void Function(int, int)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    return await _apiClient.uploadFile<FileUploadResponse>(
      V2ApiConstants.uploadImage(userId),
      data: formData,
      fromJson: (json) => FileUploadResponse.fromJson(json),
      onSendProgress: onProgress,
      cancelToken: cancelToken,
    );
  }

  @override
  String getResumeUrl(String filename) {
    return '${ApiConstants.baseUrl}${V2ApiConstants.downloadResume(filename)}';
  }

  @override
  String getImageUrl(String filename) {
    return '${ApiConstants.baseUrl}${V2ApiConstants.downloadImage(filename)}';
  }
}
