import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../api/personal_data_service.dart';
import '../../../../../models/personal_data_model.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/hero_logo.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndRedirect();
  }

  Future<void> _checkAuthAndRedirect() async {
    // Wait for the frame to build before navigating
    await Future.delayed(Duration.zero);

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    // Check if userId exists in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null && userId.isNotEmpty) {
      // User has previously logged in, check profile completion
      await authProvider.setOnboardingComplete();

      if (mounted) {
        await _checkProfileCompletionAndNavigate(userId);
      }
    } else if (authProvider.isAuthenticated) {
      // Authenticated but no userId (edge case)
      await authProvider.setOnboardingComplete();

      if (mounted) {
        context.go(RouteNames.home);
      }
    }
    // If no userId and not authenticated, stay on onboarding screen
  }

  Future<void> _handleNext() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.setOnboardingComplete();

    if (mounted) {
      // User is not authenticated, go to login
      context.go(RouteNames.loginPage);
    }
  }

  Future<void> _checkProfileCompletionAndNavigate(String userId) async {
    try {
      // Fetch user details from API
      final userDetails = await PersonalDataService.getPersonalData(userId);

      if (!mounted) return;

      if (userDetails == null) {
        // API call failed or user not found
        // Navigate to personal data to set up profile
        debugPrint('⚠️ User details not found. Redirecting to profile setup.');
        context.go('/personal_data');
        return;
      }

      // Check if basic profile details are present
      bool isProfileComplete = _hasBasicProfileDetails(userDetails);

      if (isProfileComplete) {
        debugPrint('✅ Profile complete. Navigating to home.');
        context.go(RouteNames.home);
      } else {
        debugPrint('⚠️ Profile incomplete. Redirecting to profile setup.');
        context.go('/personal_data');
      }
    } catch (e) {
      debugPrint('❌ Error checking profile: $e');
      // On error, redirect to personal_data for safety
      if (!mounted) return;
      context.go('/personal_data');
    }
  }

  bool _hasBasicProfileDetails(PersonalDataModel userDetails) {
    // Check if user has basic profile information
    bool hasUsername = userDetails.fullname != null &&
                       userDetails.fullname!.isNotEmpty;

    bool hasEmail = userDetails.email != null &&
                    userDetails.email!.isNotEmpty;

    bool hasDob = userDetails.dob != null &&
                  userDetails.dob!.isNotEmpty;

    bool hasProfession = userDetails.profession != null &&
                         userDetails.profession!.isNotEmpty;

    // Profile is complete if user has:
    // 1. Username (fullname)
    // 2. Email
    // 3. Date of birth
    // 4. Profession selected
    return hasUsername && hasEmail && hasDob && hasProfession;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAuthenticated = authProvider.isAuthenticated;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top Background Pattern
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Image.asset(
              AppAssets.splashPattern1,
              fit: BoxFit.cover,
            ).animate().fadeIn(duration: 800.ms),
          ),

          // Bottom Background Pattern
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Image.asset(
              AppAssets.splashPattern2,
              fit: BoxFit.cover,
            ).animate().fadeIn(duration: 800.ms),
          ),

          Positioned(
            top: 120,
            right: 70,
            child: const HeroLogo(height: 40),
          ),

          Positioned(
            top: 50,
            left: 0,
            child: Image.asset(
              width: 180,
              AppAssets.splashImage1,
              fit: BoxFit.contain,
              alignment: Alignment.centerRight,
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3, end: 0, delay: 200.ms),
          ),

          Positioned(
            top: 200,
            right: 0,
            child: Image.asset(
              width: 180,
              AppAssets.splashImage2,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
            ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.3, end: 0, delay: 300.ms),
          ),

          Positioned(
            bottom: 80,
            left: 20,
            child: Text(
              '''Find Your
Dream Job
Easily''',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
          ),

          Positioned(
            bottom: 40,
            left: 20,
            child: Text(
              'Find. Connect. Success',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondaryLight,
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
          ),

          // Floating Action Button (Arrow) - Hidden if authenticated
          if (!isAuthenticated)
            Positioned(
              bottom: 80,
              right: 20,
              child: FloatingActionButton.large(
                onPressed: _handleNext,
                backgroundColor: AppColors.primaryBlue,
                elevation: 4,
                shape: const CircleBorder(),
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              )
                  .animate()
                  .scale(delay: 800.ms, curve: Curves.elasticOut)
                  .then()
                  .shimmer(delay: 2000.ms, duration: 1500.ms)
                  .animate(onComplete: (controller) => controller.repeat())
                  .shimmer(duration: 1500.ms),
            ),
        ],
      ),
    );
  }
}
