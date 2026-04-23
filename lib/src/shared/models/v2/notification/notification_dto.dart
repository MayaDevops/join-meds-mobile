/// Notification DTO model
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
  });

  /// Create from JSON
  factory NotificationDTO.fromJson(Map<String, dynamic> json) {
    return NotificationDTO(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? json['message']?.toString() ?? '',
      type: json['type']?.toString(),
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'].toString())
              : DateTime.now(),
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'].toString())
          : json['read_at'] != null
              ? DateTime.parse(json['read_at'].toString())
              : null,
      actionUrl: json['actionUrl']?.toString() ?? json['action_url']?.toString(),
    );
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
