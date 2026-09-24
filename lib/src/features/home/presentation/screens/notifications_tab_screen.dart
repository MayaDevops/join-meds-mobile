import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../providers/notifications_provider.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../../shared/services/storage/local_storage_service.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/theme/app_colors.dart';

/// Notifications tab screen showing all notifications of the user
class NotificationsTabScreen extends StatefulWidget {
  const NotificationsTabScreen({super.key});

  @override
  State<NotificationsTabScreen> createState() => _NotificationsTabScreenState();
}

class _NotificationsTabScreenState extends State<NotificationsTabScreen> {
  late final NotificationsProvider _notificationsProvider;

  /// Notifications that were unread when seen on this screen. They stay
  /// highlighted for this visit even after being marked as read.
  final Set<String> _newThisVisit = {};

  /// Stops automatic retries after a failed read-all (the "Mark all read"
  /// button stays available for a manual retry).
  bool _autoMarkFailed = false;
  bool _autoMarkScheduled = false;

  @override
  void initState() {
    super.initState();
    _notificationsProvider = context.read<NotificationsProvider>();
    // Opening the screen marks everything as read - including notifications
    // that land from a fetch/poll while the screen is open.
    _notificationsProvider.addListener(_autoMarkAllAsRead);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  @override
  void dispose() {
    _notificationsProvider.removeListener(_autoMarkAllAsRead);
    super.dispose();
  }

  void _autoMarkAllAsRead() {
    final provider = _notificationsProvider;
    if (_autoMarkFailed ||
        _autoMarkScheduled ||
        !provider.hasUnread ||
        provider.isLoading ||
        provider.isMarkingAllRead) {
      return;
    }

    final userId = _resolveUserId();
    if (userId == null) return;

    _newThisVisit.addAll(
      provider.notifications.where((n) => !n.isRead).map((n) => n.id),
    );

    // Deferred: don't start a new notify cycle from inside notifyListeners.
    _autoMarkScheduled = true;
    Future.microtask(() async {
      _autoMarkScheduled = false;
      if (!mounted) return;
      final success = await provider.markAllAsRead(userId);
      if (!success) _autoMarkFailed = true;
    });
  }

  Future<void> _loadNotifications({bool forceRefresh = false}) async {
    final userId = _resolveUserId();
    if (userId == null) return;
    await context
        .read<NotificationsProvider>()
        .fetchNotifications(userId, forceRefresh: forceRefresh);
  }

  /// UserProvider loads asynchronously, so fall back to the id stored at login
  String? _resolveUserId() {
    final userId = context.read<UserProvider>().userId ??
        context.read<LocalStorageService>().getString(StorageKeys.userId);
    return (userId == null || userId.isEmpty) ? null : userId;
  }

  Future<void> _markAllAsRead() async {
    final userId = _resolveUserId();
    if (userId == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final success = await _notificationsProvider.markAllAsRead(userId);
    if (success) _autoMarkFailed = false;
    if (!success && mounted) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not mark notifications as read. Try again.'),
        ),
      );
    }
  }

  /// Marks the tapped notification as read (PUT /api/notifications/{id}/read)
  /// and opens the related job when the notification carries a jobId.
  void _onNotificationTap(NotificationDTO notification) {
    setState(() => _newThisVisit.remove(notification.id));

    if (!notification.isRead) {
      _notificationsProvider.markAsRead(notification.id);
    }

    final jobId = notification.jobId;
    if (jobId != null && jobId.isNotEmpty) {
      context.push('/job-details/$jobId');
    }
  }

  /// Leaves the notifications page, falling back to Home when there is
  /// nothing to pop (the tab is opened via `go` from the bell / nav bar).
  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            tooltip: 'Back',
            onPressed: _goBack,
          ),
          actions: [
            // Mark all as read (disabled when nothing is unread)
            Consumer<NotificationsProvider>(
              builder: (context, provider, _) {
                final canMark =
                    provider.hasUnread && !provider.isMarkingAllRead;
                return TextButton.icon(
                  onPressed: canMark ? _markAllAsRead : null,
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text('Mark all read'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white70,
                  ),
                );
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Consumer<NotificationsProvider>(
          builder: (context, provider, child) {
            return _buildBody(provider);
          },
        ),
      ),
    );
  }

  Widget _buildBody(NotificationsProvider provider) {
    // Loading state
    if (provider.isLoading && provider.notifications.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
        ),
      );
    }

    // Error state
    if (provider.error != null && provider.notifications.isEmpty) {
      return _buildMessage(
        icon: Icons.error_outline,
        iconColor: Colors.red.shade300,
        title: 'Failed to load notifications',
        subtitle: provider.error!,
        action: ElevatedButton.icon(
          onPressed: () => _loadNotifications(forceRefresh: true),
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    // Empty state
    if (provider.notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _loadNotifications(forceRefresh: true),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: _buildMessage(
                icon: Icons.notifications_none,
                iconColor: Colors.grey.shade400,
                title: 'No notifications yet',
                subtitle:
                    'You\'ll see notifications here when you have updates',
              ),
            ),
          ),
        ),
      );
    }

    // Notifications list, split by the API's `read` flag
    final unread = provider.notifications.where(_isUnread).toList();
    final read = provider.notifications.where((n) => !_isUnread(n)).toList();

    return RefreshIndicator(
      onRefresh: () => _loadNotifications(forceRefresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          if (unread.isNotEmpty) ...[
            _buildSectionHeader('Unread', unread.length, highlight: true),
            ..._buildTiles(unread),
          ],
          if (read.isNotEmpty) ...[
            _buildSectionHeader(
              unread.isEmpty ? 'All caught up' : 'Earlier',
              read.length,
            ),
            ..._buildTiles(read),
          ],
        ],
      ),
    );
  }

  /// Unread per the API, or unread when first seen on this visit (kept
  /// highlighted after the automatic read-all on open)
  bool _isUnread(NotificationDTO n) =>
      !n.isRead || _newThisVisit.contains(n.id);

  List<Widget> _buildTiles(List<NotificationDTO> items) {
    return [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0) Divider(height: 1, color: Colors.grey.shade200),
        _buildNotificationTile(items[i]),
      ],
    ];
  }

  Widget _buildSectionHeader(String label, int count,
      {bool highlight = false}) {
    final color = highlight ? AppColors.primaryBlue : Colors.black54;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(NotificationDTO notification) {
    final isUnread = _isUnread(notification);

    return InkWell(
      onTap: () => _onNotificationTap(notification),
      child: Ink(
        color: isUnread
            ? AppColors.primaryBlue.withValues(alpha: 0.06)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isUnread
                  ? AppColors.primaryBlue.withValues(alpha: 0.12)
                  : Colors.grey.shade200,
              child: Icon(
                isUnread
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_none,
                color: isUnread ? AppColors.primaryBlue : Colors.grey.shade500,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                      color: isUnread ? Colors.black87 : Colors.black54,
                    ),
                  ),
                  if (notification.body.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 14,
                        color: isUnread ? Colors.black87 : Colors.black45,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    notification.timeAgo,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            if (isUnread)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 6),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: iconColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action,
            ],
          ],
        ),
      ),
    );
  }
}
