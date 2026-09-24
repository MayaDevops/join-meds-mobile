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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
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
                subtitle: 'You\'ll see notifications here when you have updates',
              ),
            ),
          ),
        ),
      );
    }

    // Notifications list
    return RefreshIndicator(
      onRefresh: () => _loadNotifications(forceRefresh: true),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: provider.notifications.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, index) =>
            _buildNotificationTile(provider.notifications[index]),
      ),
    );
  }

  Widget _buildNotificationTile(NotificationDTO notification) {
    final isUnread = !notification.isRead;

    return Container(
      color: isUnread
          ? AppColors.primaryBlue.withValues(alpha: 0.06)
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
            child: Icon(
              Icons.notifications_outlined,
              color: AppColors.primaryBlue,
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
                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (notification.body.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
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
