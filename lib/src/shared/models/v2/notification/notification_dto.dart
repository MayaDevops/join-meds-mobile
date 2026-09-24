/// Notification DTO model
///
/// Maps `NotificationResponse` from GET /api/notifications/user/{userId}:
/// `{ id, orgId, userId, jobId, candidateName, message, type, read, createdAt }`.
/// The API has no title, so [title] falls back to a readable form of [type].
class NotificationDTO {
  final String id;
  final String title;
  final String body;
  final String? type; // 'job_match', 'application_update', 'system', etc.
  final Map<String, dynamic>? data; // Additional data payload
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? actionUrl; // URL to navigate when tapped
  final String? orgId;
  final String? userId;
  final String? jobId;
  final String? candidateName;

  const NotificationDTO({
    required this.id,
    required this.title,
    required this.body,
    this.type,
    this.data,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
    this.actionUrl,
    this.orgId,
    this.userId,
    this.jobId,
    this.candidateName,
  });

  /// Create from JSON
  factory NotificationDTO.fromJson(Map<String, dynamic> json) {
    final type = json['type']?.toString();
    return NotificationDTO(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? _titleFromType(type),
      body: json['body']?.toString() ?? json['message']?.toString() ?? '',
      type: type,
      data: json['data'] as Map<String, dynamic>?,
      isRead: (json['read'] ?? json['isRead'] ?? json['is_read']) == true,
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']) ??
          DateTime.now(),
      readAt: _parseDate(json['readAt'] ?? json['read_at']),
      actionUrl: json['actionUrl']?.toString() ?? json['action_url']?.toString(),
      orgId: json['orgId']?.toString(),
      userId: json['userId']?.toString(),
      jobId: json['jobId']?.toString(),
      candidateName: json['candidateName']?.toString(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  /// "APPLICATION_STATUS" / "job_match" -> "Application Status" / "Job Match"
  static String _titleFromType(String? type) {
    if (type == null || type.trim().isEmpty) return 'Notification';
    return type
        .split(RegExp(r'[_\-\s]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'actionUrl': actionUrl,
      'orgId': orgId,
      'userId': userId,
      'jobId': jobId,
      'candidateName': candidateName,
    };
  }

  /// Create a copy with modified fields
  NotificationDTO copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    String? actionUrl,
    String? orgId,
    String? userId,
    String? jobId,
    String? candidateName,
  }) {
    return NotificationDTO(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      actionUrl: actionUrl ?? this.actionUrl,
      orgId: orgId ?? this.orgId,
      userId: userId ?? this.userId,
      jobId: jobId ?? this.jobId,
      candidateName: candidateName ?? this.candidateName,
    );
  }

  /// Get formatted time ago string (e.g., "2 hours ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  String toString() {
    return 'NotificationDTO(id: $id, title: $title, isRead: $isRead, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationDTO && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Response of GET /api/notifications/user/{userId}:
/// `{ unreadCount, notifications: [NotificationResponse] }`
class NotificationListDTO {
  final int unreadCount;
  final List<NotificationDTO> notifications;

  const NotificationListDTO({
    required this.unreadCount,
    required this.notifications,
  });

  factory NotificationListDTO.fromJson(Map<String, dynamic> json) {
    final notifications = (json['notifications'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(NotificationDTO.fromJson)
        .toList();
    final unread = json['unreadCount'];
    return NotificationListDTO(
      unreadCount: unread is num
          ? unread.toInt()
          : notifications.where((n) => !n.isRead).length,
      notifications: notifications,
    );
  }
}
