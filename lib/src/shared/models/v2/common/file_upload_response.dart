/// Response model for file upload operations
class FileUploadResponse {
  final String fileUrl;
  final String fileName;
  final int? fileSize;

  FileUploadResponse({
    required this.fileUrl,
    required this.fileName,
    this.fileSize,
  });

  /// The resume/image upload endpoints respond with a bare string body -- the
  /// generated file id -- not a JSON object (swagger: 200 -> type: string).
  /// A JSON object is still accepted so the model keeps working if the backend
  /// starts returning a richer payload.
  factory FileUploadResponse.fromJson(dynamic json) {
    if (json is String) {
      return FileUploadResponse(fileUrl: json, fileName: json);
    }
    if (json is Map<String, dynamic>) {
      return FileUploadResponse(
        fileUrl: json['file_url'] ?? json['fileUrl'] ?? '',
        fileName: json['file_name'] ?? json['fileName'] ?? '',
        fileSize: json['file_size'] ?? json['fileSize'],
      );
    }
    return FileUploadResponse(fileUrl: '', fileName: '');
  }

  /// The stored file id, which is what the API actually hands back on upload.
  String get fileId => fileName.isNotEmpty ? fileName : fileUrl;

  Map<String, dynamic> toJson() {
    return {
      'file_url': fileUrl,
      'file_name': fileName,
      if (fileSize != null) 'file_size': fileSize,
    };
  }
}
