import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// User profile header widget showing profile photo and greeting
class UserProfileHeader extends StatelessWidget {
  final VoidCallback? onTap;

  const UserProfileHeader({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final name = userProvider.fullName ?? 'Guest';
        final profileImageUrl = userProvider.profileImageUrl;

        return GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile photo
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                    ? NetworkImage(profileImageUrl)
                    : null,
                child: profileImageUrl == null || profileImageUrl.isEmpty
                    ? Text(
                        _getInitials(name),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Greeting text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Hello',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    _getFirstName(name),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Get initials from full name
  String _getInitials(String name) {
    if (name.isEmpty) return 'G';

    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
  }

  /// Get first name from full name
  String _getFirstName(String name) {
    if (name.isEmpty) return 'Guest';

    final parts = name.trim().split(' ');
    return parts[0];
  }
}
