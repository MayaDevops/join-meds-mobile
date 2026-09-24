import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../shared/services/v2/repositories/interfaces/i_notification_repo.dart';
import '../../../../shared/models/v2/notification/notification_dto.dart';

export '../../../../shared/models/v2/notification/notification_dto.dart';

/// Provider for managing the user's notifications
/// (GET /api/notifications/user/{userId})
class NotificationsProvider extends ChangeNotifier {
  final INotificationRepo _notificationRepo;

  NotificationsProvider(this._notificationRepo);

  List<NotificationDTO> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;
  String? _lastUserId;

  /// All notifications, newest first
  List<NotificationDTO> get notifications => _notifications;

  /// Unread notifications count (from the API's `unreadCount`)
  int get unreadCount => _unreadCount;

  /// Loading state
  bool get isLoading => _isLoading;

  /// Error message
  String? get error => _error;

  /// Has unread notifications
  bool get hasUnread => _unreadCount > 0;

  /// Fetch all notifications of the user
  Future<void> fetchNotifications(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (_isLoading) return;

    // Avoid fetching too frequently (cache for 1 minute per user)
    if (!forceRefresh &&
        _lastUserId == userId &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inMinutes < 1) {
      debugPrint('NotificationsProvider: Using cached notifications');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _notificationRepo.fetchUserNotifications(userId);

      if (response.success && response.data != null) {
        _notifications = List.of(response.data!.notifications)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _unreadCount = response.data!.unreadCount;
        _lastFetchTime = DateTime.now();
        _lastUserId = userId;
        _error = null;
      } else {
        _error = response.message;
      }
    } on DioException catch (e) {
      _error = e.message ?? 'Network error occurred';
      debugPrint('NotificationsProvider: Error fetching notifications - $e');
    } catch (e) {
      _error = 'An unexpected error occurred';
      debugPrint('NotificationsProvider: Unexpected error - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh notifications (force fetch)
  Future<void> refresh(String userId) async {
    await fetchNotifications(userId, forceRefresh: true);
  }

  /// Mark a notification as read (not wired to the API yet)
  Future<void> markAsRead(String notificationId) async {}

  /// Mark all notifications as read (not wired to the API yet)
  Future<void> markAllAsRead() async {}

  /// Remove a notification from the list
  void removeNotification(String notificationId) {
    final removed = _notifications.where((n) => n.id == notificationId);
    if (removed.isEmpty) return;
    if (!removed.first.isRead && _unreadCount > 0) _unreadCount--;
    _notifications = _notifications.where((n) => n.id != notificationId).toList();
    notifyListeners();
  }

  /// Clear all notifications (e.g. on logout)
  void clearNotifications() {
    _notifications = [];
    _unreadCount = 0;
    _lastFetchTime = null;
    _lastUserId = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
