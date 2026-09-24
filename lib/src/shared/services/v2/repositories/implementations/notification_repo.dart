import 'package:dio/dio.dart';
import '../../../../../core/constants/v2_api_constants.dart';
import '../../../../models/v2/common/api_response.dart';
import '../../../../models/v2/notification/notification_dto.dart';
import '../../../api/api_client.dart';
import '../interfaces/i_notification_repo.dart';

/// Notification repository implementation
class NotificationRepo implements INotificationRepo {
  final ApiClient _apiClient;

  NotificationRepo(this._apiClient);

  @override
  Future<ApiResponse<NotificationListDTO>> fetchUserNotifications(
    String userId, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _apiClient.get(
        V2ApiConstants.fetchUserNotifications(userId),
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        // Documented shape: { unreadCount, notifications: [...] }
        if (data is Map<String, dynamic>) {
          // Tolerate the list being wrapped in a { data: {...} } envelope
          final payload = data['notifications'] == null &&
                  data['data'] is Map<String, dynamic>
              ? data['data'] as Map<String, dynamic>
              : data;
          return ApiResponse<NotificationListDTO>(
            success: true,
            message: 'Notifications fetched successfully',
            data: NotificationListDTO.fromJson(payload),
          );
        }

        // Handle direct array response
        if (data is List) {
          return ApiResponse<NotificationListDTO>(
            success: true,
            message: 'Notifications fetched successfully',
            data: NotificationListDTO.fromJson({'notifications': data}),
          );
        }
      }

      return ApiResponse<NotificationListDTO>(
        success: false,
        message: 'Failed to fetch notifications',
        data: null,
      );
    } catch (e) {
      return ApiResponse<NotificationListDTO>(
        success: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }
}
