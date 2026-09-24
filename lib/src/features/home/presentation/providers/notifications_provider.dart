import 'dart:async';

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

  /// Ids already known for [_lastUserId]; null until the first successful
  /// fetch, so notifications that existed before the app opened are never
  /// announced as "new".
  Set<String>? _seenIds;

  final StreamController<List<NotificationDTO>> _newNotificationsController =
      StreamController<List<NotificationDTO>>.broadcast();

  /// Emits unread notifications that arrived since the previous fetch
  /// (drives the in-app notification banner).
  Stream<List<NotificationDTO>> get newNotifications =>
      _newNotificationsController.stream;

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
        _error = null;
        _announceNewNotifications(userId);
        _lastUserId = userId;
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

  void _announceNewNotifications(String userId) {
    if (_lastUserId != userId) _seenIds = null;

    final seen = _seenIds;
    final fresh = seen == null
        ? const <NotificationDTO>[]
        : _notifications
            .where((n) => !n.isRead && !seen.contains(n.id))
            .toList();

    _seenIds = {...?seen, ..._notifications.map((n) => n.id)};

    if (fresh.isNotEmpty && !_newNotificationsController.isClosed) {
      _newNotificationsController.add(fresh);
    }
  }

  /// Refresh notifications (force fetch)
  Future<void> refresh(String userId) async {
    await fetchNotifications(userId, forceRefresh: true);
  }

  /// Mark a single notification as read (PUT /api/notifications/{id}/read).
  ///
  /// Updates the item and unread count immediately and restores them if the
  /// request fails. Returns whether it succeeded (true if already read).
  Future<bool> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && _notifications[index].isRead) return true;

    final previousNotifications = _notifications;
    final previousUnreadCount = _unreadCount;

    if (index != -1) {
      _notifications = List.of(_notifications)
        ..[index] = _notifications[index]
            .copyWith(isRead: true, readAt: DateTime.now());
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();
    }

    final response = await _notificationRepo.markAsRead(notificationId);
    if (!response.success) {
      _notifications = previousNotifications;
      _unreadCount = previousUnreadCount;
      debugPrint('NotificationsProvider: read failed - ${response.message}');
      notifyListeners();
    }
    return response.success;
  }

  bool _isMarkingAllRead = false;

  /// True while the read-all request is in flight
  bool get isMarkingAllRead => _isMarkingAllRead;

  /// Mark all notifications of the user as read
  /// (PUT /api/notifications/user/{userId}/read-all).
  ///
  /// Updates the list and unread count immediately and restores them if the
  /// request fails. Returns whether the API call succeeded.
  Future<bool> markAllAsRead(String userId) async {
    if (_isMarkingAllRead || !hasUnread) return true;

    final previousNotifications = _notifications;
    final previousUnreadCount = _unreadCount;

    _isMarkingAllRead = true;
    final now = DateTime.now();
    _notifications = _notifications
        .map((n) => n.isRead ? n : n.copyWith(isRead: true, readAt: now))
        .toList();
    _unreadCount = 0;
    notifyListeners();

    try {
      final response = await _notificationRepo.markAllAsReadForUser(userId);
      if (!response.success) {
        _notifications = previousNotifications;
        _unreadCount = previousUnreadCount;
        _error = response.message;
        debugPrint('NotificationsProvider: read-all failed - ${response.message}');
      }
      return response.success;
    } finally {
      _isMarkingAllRead = false;
      notifyListeners();
    }
  }

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
    _seenIds = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _newNotificationsController.close();
    super.dispose();
  }
}
