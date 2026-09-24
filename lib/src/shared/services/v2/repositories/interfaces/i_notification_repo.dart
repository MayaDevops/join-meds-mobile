import 'package:dio/dio.dart';
import '../../../../models/v2/common/api_response.dart';
import '../../../../models/v2/notification/notification_dto.dart';

/// Notification repository interface
abstract class INotificationRepo {
  /// Fetch all notifications of a user (GET /api/notifications/user/{userId})
  Future<ApiResponse<NotificationListDTO>> fetchUserNotifications(
    String userId, {
    CancelToken? cancelToken,
  });
}
