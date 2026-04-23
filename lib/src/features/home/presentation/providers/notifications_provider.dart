import 'package:flutter/foundation.dart';

/// Provider for managing notifications state
/// NOTE: Notifications API has been disabled - always returns empty state
class NotificationsProvider extends ChangeNotifier {
  NotificationsProvider();

  final List<NotificationDTO> _notifications = [];
  bool _isLoading = false;
  String? _error;

  /// All notifications (always empty)
  List<NotificationDTO> get notifications => _notifications;

  /// Unread notifications count (always 0)
  int get unreadCount => 0;

  /// Loading state (always false)
  bool get isLoading => _isLoading;

  /// Error message (always null)
  String? get error => _error;

  /// Has unread notifications (always false)
  bool get hasUnread => false;

  /// Fetch notifications from API (no-op - notifications disabled)
  Future<void> fetchNotifications({
    bool forceRefresh = false,
  }) async {
    // Notifications API is disabled - no-op
    debugPrint('NotificationsProvider: Notifications API is disabled');
  }

  /// Mark a notification as read (no-op - notifications disabled)
  Future<void> markAsRead(String notificationId) async {
    // Notifications API is disabled - no-op
  }

  /// Mark all notifications as read (no-op - notifications disabled)
  Future<void> markAllAsRead() async {
    // Notifications API is disabled - no-op
  }

  /// Remove a notification from the list (no-op - notifications disabled)
  void removeNotification(String notificationId) {
    // Notifications API is disabled - no-op
  }

  /// Clear all notifications (no-op - notifications disabled)
  void clearNotifications() {
    // Notifications API is disabled - no-op
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh notifications (no-op - notifications disabled)
  Future<void> refresh() async {
    // Notifications API is disabled - no-op
  }

  @override
  void dispose() {
    _notifications.clear();
    super.dispose();
  }
}

/// Placeholder DTO class (kept for compatibility)
class NotificationDTO {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? actionUrl;

  NotificationDTO({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.actionUrl,
  });

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  NotificationDTO copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    String? actionUrl,
  }) {
    return NotificationDTO(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }
}
