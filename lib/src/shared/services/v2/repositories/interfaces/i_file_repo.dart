import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../models/v2/common/api_response.dart';
import '../../../../models/v2/common/file_upload_response.dart';

/// File repository interface
abstract class IFileRepo {
  /// Upload resume file
  Future<ApiResponse<FileUploadResponse>> uploadResume(
    int userId,
    File file, {
    void Function(int, int)? onProgress,
    CancelToken? cancelToken,
  });

  /// Upload profile image
  Future<ApiResponse<FileUploadResponse>> uploadImage(
    int userId,
    File file, {
    void Function(int, int)? onProgress,
    CancelToken? cancelToken,
  });

  /// Get resume URL
  String getResumeUrl(String filename);

  /// Get image URL
  String getImageUrl(String filename);
}
