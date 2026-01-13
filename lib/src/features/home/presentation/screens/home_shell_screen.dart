import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/notifications_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_names.dart';

/// Shell screen with custom designed persistent bottom navigation
class HomeShellScreen extends StatelessWidget {
  final Widget child;

  const HomeShellScreen({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      // extendBody ensures the content flows behind the rounded corners of the nav bar
      extendBody: true,
      body: Padding(
        padding: EdgeInsets.only(bottom:50 ),
          child: child),
      bottomNavigationBar: _buildCustomBottomNavBar(context, currentIndex),
    );
  }

  Widget _buildCustomBottomNavBar(BuildContext context, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, -2), // Shadow upwards
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70, // Fixed height to match design
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: 'assets/v2/images/icons/home.png',
                context,
                index: 0,
                currentIndex: currentIndex,
                label: 'Home',
                activeIcon: Icons.home_rounded,
                inactiveIcon: Icons.home_outlined,
              ),
              _buildNavItem(
                icon: 'assets/v2/images/icons/jobs.png',
                context,
                index: 1,
                currentIndex: currentIndex,
                label: 'Jobs',
                // Using shopping_bag to match the "bag" look in the image,
                // or use work_outline if preferred.
                activeIcon: Icons.shopping_bag_rounded,
                inactiveIcon: Icons.shopping_bag_outlined,
              ),
              _buildNavItem(
                icon: 'assets/v2/images/icons/notification.png',
                context,
                index: 2,
                currentIndex: currentIndex,
                label: 'Notifications',
                activeIcon: Icons.notifications_rounded,
                inactiveIcon: Icons.notifications_outlined,
                hasBadge: true,
              ),
              _buildNavItem(
                icon: 'assets/v2/images/icons/profile.png',
                context,
                index: 3,
                currentIndex: currentIndex,
                label: 'Profile',
                activeIcon: Icons.person_rounded,
                inactiveIcon: Icons.person_outline_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required int index,
        required String icon,
        required int currentIndex,
        required String label,
        required IconData activeIcon,
        required IconData inactiveIcon,
        bool hasBadge = false,
      }) {
    final bool isSelected = index == currentIndex;
    final Color color = isSelected ? AppColors.primaryBlue : Colors.grey.shade600;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(context, index),
        customBorder: const CircleBorder(), // Ripple effect shape
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Wrapper with optional Badge
            SizedBox(
              height: 28,
              width: 28,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Image.asset(
                      icon,
                      // isSelected ? activeIcon : inactiveIcon,
                      color: color,
                      width: 26,
                      height: 26,
                    ),
                  ),
                  if (hasBadge)
                    Consumer<NotificationsProvider>(
                      builder: (context, provider, child) {
                        if (!provider.hasUnread) return const SizedBox();
                        return Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Label
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),

            const SizedBox(height: 4),

            // Active Indicator Line
            // This is the blue underline shown in the design
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isSelected ? 20 : 0, // Expands when selected
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(RouteNames.home)) return 0;
    if (location.startsWith(RouteNames.myJobs)) return 1;
    if (location.startsWith(RouteNames.notifications)) return 2;
    if (location.startsWith(RouteNames.profile)) return 3;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.home);
        break;
      case 1:
        context.go(RouteNames.myJobs);
        break;
      case 2:
        context.go(RouteNames.notifications);
        // Optional: Fetch on tap
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.read<NotificationsProvider>().fetchNotifications();
          }
        });
        break;
      case 3:
        context.go(RouteNames.profile);
        break;
    }
  }
}