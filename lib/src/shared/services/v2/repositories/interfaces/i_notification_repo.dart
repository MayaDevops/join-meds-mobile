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

  /// Mark all notifications of a user as read
  /// (PUT /api/notifications/user/{userId}/read-all)
  Future<ApiResponse<void>> markAllAsReadForUser(
    String userId, {
    CancelToken? cancelToken,
  });

  /// Mark a single notification as read
  /// (PUT /api/notifications/{id}/read)
  Future<ApiResponse<void>> markAsRead(
    String notificationId, {
    CancelToken? cancelToken,
  });
}
