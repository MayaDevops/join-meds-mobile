import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_names.dart';

/// Settings tab screen
class SettingsTabScreen extends StatefulWidget {
  const SettingsTabScreen({super.key});

  @override
  State<SettingsTabScreen> createState() => _SettingsTabScreenState();
}

class _SettingsTabScreenState extends State<SettingsTabScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Menu Items
                _buildMenuItems(context, userProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, UserProvider userProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.description_outlined,
            title: 'My Resume',
            trailing: userProvider.hasResume
                ? const Icon(Icons.check_circle, color: AppColors.success, size: 20)
                : const Icon(Icons.upload_outlined, color: Colors.grey, size: 20),
            onTap: () {
              // TODO: Navigate to resume upload
              context.push('/profile/resume');
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.bookmark_outline,
            title: 'Saved Jobs',
            onTap: () {
              // TODO: Navigate to saved jobs
              // context.push('/saved-jobs');
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.lock_outline,
            title: 'Privacy Policy',
            onTap: () {
              // TODO: Navigate to privacy policy
              // context.push('/privacy-policy');
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            onTap: () {
              // TODO: Navigate to terms
              // context.push('/terms');
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              // TODO: Navigate to help
              // context.push('/help');
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            textColor: AppColors.error,
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.black87),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: textColor ?? Colors.black87,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Perform logout
              final authProvider = context.read<AuthProvider>();
              await authProvider.logout();

              // Navigate to login screen
              if (context.mounted) {
                context.go(RouteNames.loginPage);
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
