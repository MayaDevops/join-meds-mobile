import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    // Determine where to navigate
    if (authProvider.isFirstLaunch) {
      // First time user - show onboarding
      if (mounted) context.go(RouteNames.onboarding);
    } else if (authProvider.isAuthenticated) {
      // Already logged in - go to home
      if (authProvider.isOrganisation) {
        if (mounted) context.go(RouteNames.orgHome);
      } else {
        if (mounted) context.go(RouteNames.home);
      }
    } else {
      // Not logged in - go to login
      if (mounted) context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          AppAssets.splashLogo,
          width: 150,
          height: 150,
        ).animate().fadeIn(duration: 600.ms).scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }
}
