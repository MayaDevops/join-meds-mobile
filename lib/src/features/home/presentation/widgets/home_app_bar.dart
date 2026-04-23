import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/notifications_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_names.dart';
import 'user_profile_header.dart';

/// Home screen app bar with profile header and notification icon
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showNotificationBell;

  const HomeAppBar({
    super.key,
    this.showNotificationBell = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xffD9D9D9),
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: UserProfileHeader(
        onTap: () {
          // Navigate to profile tab
          context.go(RouteNames.profile);
        },
      ),
      actions: [
        if (showNotificationBell) _buildNotificationButton(context),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Consumer<NotificationsProvider>(
      builder: (context, notificationsProvider, child) {
        final unreadCount = notificationsProvider.unreadCount;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.black87,
                size: 28,
              ),
              onPressed: () {
                // Navigate to notifications tab
                context.go(RouteNames.notifications);
              },
            ),
            // Unread badge
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
