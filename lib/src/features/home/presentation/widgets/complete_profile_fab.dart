import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../../core/router/route_names.dart';

/// Floating action button for completing user profile
class CompleteProfileFAB extends StatelessWidget {
  final VoidCallback? onPressed;

  const CompleteProfileFAB({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // TODO: Add profileCompletion percentage to UserProvider
        // For now, show if profile is incomplete (no name or no resume)
        final shouldShow = !userProvider.isProfileComplete;

        if (!shouldShow) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton.extended(
          onPressed: onPressed ??
              () {
                // Navigate to profile setup/edit
                // TODO: Add specific profile setup flow route
                context.push('/profile/edit');
              },
          backgroundColor: Colors.orange,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          icon: const Icon(
            Icons.person_add,
            color: Colors.white,
            size: 20,
          ),
          label: const Text(
            'Complete Your Profile',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

/// Compact version of the FAB (just icon)
class CompleteProfileFABCompact extends StatelessWidget {
  final VoidCallback? onPressed;

  const CompleteProfileFABCompact({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final shouldShow = !userProvider.isProfileComplete;

        if (!shouldShow) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton(
          onPressed: onPressed ??
              () {
                context.push('/profile/edit');
              },
          backgroundColor: Colors.orange,
          elevation: 4,
          child: const Icon(
            Icons.person_add,
            color: Colors.white,
          ),
        );
      },
    );
  }
}
