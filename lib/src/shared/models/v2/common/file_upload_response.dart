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

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      fileUrl: json['file_url'] ?? json['fileUrl'] ?? '',
      fileName: json['file_name'] ?? json['fileName'] ?? '',
      fileSize: json['file_size'] ?? json['fileSize'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file_url': fileUrl,
      'file_name': fileName,
      if (fileSize != null) 'file_size': fileSize,
    };
  }
}
