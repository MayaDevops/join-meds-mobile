import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/home/presentation/providers/notifications_provider.dart';
import '../../services/storage/local_storage_service.dart';

/// Shows in-app notification banners while the app is open.
///
/// Polls GET /api/notifications/user/{userId} every [pollInterval] while the
/// app is in the foreground (paused in background, re-checked on resume) and
/// slides a banner in from the top when new unread notifications arrive.
/// Tapping the banner opens the Notifications tab; swiping up dismisses it.
///
/// Wrap the app's root (MaterialApp.router `builder`) with this widget.
class InAppNotificationHost extends StatefulWidget {
  final Widget child;
  final Duration pollInterval;
  final Duration displayDuration;

  const InAppNotificationHost({
    super.key,
    required this.child,
    this.pollInterval = const Duration(seconds: 30),
    this.displayDuration = const Duration(seconds: 5),
  });

  @override
  State<InAppNotificationHost> createState() => _InAppNotificationHostState();
}

class _InAppNotificationHostState extends State<InAppNotificationHost>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final NotificationsProvider _provider;
  late final LocalStorageService _storage;
  late final AnimationController _animation;
  StreamSubscription<List<NotificationDTO>>? _subscription;
  Timer? _pollTimer;
  Timer? _hideTimer;

  List<NotificationDTO>? _banner;

  @override
  void initState() {
    super.initState();
    _provider = context.read<NotificationsProvider>();
    _storage = context.read<LocalStorageService>();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _subscription = _provider.newNotifications.listen(_showBanner);
    WidgetsBinding.instance.addObserver(this);
    _startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    _pollTimer?.cancel();
    _hideTimer?.cancel();
    _animation.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startPolling();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _poll();
    _pollTimer = Timer.periodic(widget.pollInterval, (_) => _poll());
  }

  /// Fetches only for a logged-in candidate; org accounts use a different
  /// notifications endpoint.
  void _poll() {
    final token = _storage.getString(StorageKeys.authToken);
    final userId = _storage.getString(StorageKeys.userId);
    final userType = _storage.getString(StorageKeys.userType);

    final loggedIn = token != null &&
        token.isNotEmpty &&
        userId != null &&
        userId.isNotEmpty &&
        userType != 'organisation';

    if (!loggedIn) {
      if (_provider.notifications.isNotEmpty || _provider.unreadCount > 0) {
        _provider.clearNotifications();
      }
      return;
    }

    _provider.fetchNotifications(userId, forceRefresh: true);
  }

  String get _currentPath {
    try {
      return AppRouter.router.routerDelegate.currentConfiguration.uri.path;
    } catch (_) {
      return '';
    }
  }

  void _showBanner(List<NotificationDTO> fresh) {
    if (!mounted) return;
    // The list on the Notifications tab already updates live.
    if (_currentPath.startsWith(RouteNames.notifications)) return;

    setState(() => _banner = fresh);
    _animation.forward(from: 0);
    _hideTimer?.cancel();
    _hideTimer = Timer(widget.displayDuration, _hideBanner);
  }

  Future<void> _hideBanner() async {
    _hideTimer?.cancel();
    if (!mounted || _banner == null) return;
    await _animation.reverse();
    if (mounted) setState(() => _banner = null);
  }

  /// Single notification: mark just that one read
  /// (PUT /api/notifications/{id}/read) and open its job if it has one.
  /// Otherwise open the Notifications tab (which marks everything read).
  void _onBannerTap(List<NotificationDTO> notifications) {
    _hideBanner();

    if (notifications.length == 1) {
      final notification = notifications.first;
      _provider.markAsRead(notification.id);

      final jobId = notification.jobId;
      if (jobId != null && jobId.isNotEmpty) {
        AppRouter.router.push('/job-details/$jobId');
        return;
      }
    }

    AppRouter.router.go(RouteNames.notifications);
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;

    return Stack(
      children: [
        widget.child,
        if (banner != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1.2),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animation,
                  curve: Curves.easeOutCubic,
                )),
                child: Dismissible(
                  key: ValueKey(banner.first.id),
                  direction: DismissDirection.up,
                  onDismissed: (_) {
                    _hideTimer?.cancel();
                    setState(() => _banner = null);
                  },
                  child: _InAppNotificationBanner(
                    notifications: banner,
                    onTap: () => _onBannerTap(banner),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _InAppNotificationBanner extends StatelessWidget {
  final List<NotificationDTO> notifications;
  final VoidCallback onTap;

  const _InAppNotificationBanner({
    required this.notifications,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final single = notifications.length == 1;
    final first = notifications.first;
    final title =
        single ? first.title : 'You have ${notifications.length} new notifications';
    final body = single ? first.body : first.title;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Material(
        color: Colors.white,
        elevation: 6,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.primaryBlue, width: 4),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      AppColors.primaryBlue.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.notifications_active_outlined,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (body.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
