class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, [this.statusCode, this.data]);

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException([String message = 'No internet connection'])
      : super(message);
}

class TimeoutException extends ApiException {
  TimeoutException([String message = 'Connection timed out'])
      : super(message);
}

class BadRequestException extends ApiException {
  BadRequestException([String message = 'Bad request'])
      : super(message, 400);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Unauthorized'])
      : super(message, 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException([String message = 'Access forbidden'])
      : super(message, 403);
}

class NotFoundException extends ApiException {
  NotFoundException([String message = 'Resource not found'])
      : super(message, 404);
}

class ConflictException extends ApiException {
  ConflictException([String message = 'Conflict occurred'])
      : super(message, 409);
}

class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException([String message = 'Validation failed', this.errors])
      : super(message, 422, errors);
}

class ServerException extends ApiException {
  ServerException([String message = 'Server error occurred'])
      : super(message, 500);
}

class ServiceUnavailableException extends ApiException {
  ServiceUnavailableException([String message = 'Service temporarily unavailable'])
      : super(message, 503);
}
