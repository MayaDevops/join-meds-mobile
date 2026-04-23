import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';

/// Signup completion screen shown after user completes dynamic forms
/// Matches the design from "siginUp last.png"
class SignupCompletionScreen extends StatefulWidget {
  const SignupCompletionScreen({super.key});

  @override
  State<SignupCompletionScreen> createState() => _SignupCompletionScreenState();
}

class _SignupCompletionScreenState extends State<SignupCompletionScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _markOnboardingComplete();
  }

  /// Mark onboarding as complete in SharedPreferences
  Future<void> _markOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);
      debugPrint('✅ Onboarding marked as complete');
    } catch (e) {
      debugPrint('❌ Error marking onboarding complete: $e');
    }
  }

  /// Navigate to home screen
  Future<void> _goToProfile() async {
    if (_isNavigating) return;

    setState(() => _isNavigating = true);

    // Use go() to replace navigation stack
    context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Prevent back button navigation
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),

               Image.asset('assets/v2/profileCompletedImage.png',width: 180,height: 180,),
                const SizedBox(height: 40),

                // Title
                Text(
                  'Your basic profile is now active',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 16),

                // Subtitle
                Text(
                  'To unlock the best job opportunities, please complete all remaining fields. A 100% complete profile helps our system match you with excellent roles tailored to your experience.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: const Color(0xFF666666),
                    height: 1.5,
                  ),
                ),

                const Spacer(flex: 2),

                // JoinMeds Logo
               Image.asset('assets/v2/appLogo.png',height: 50,),

                const SizedBox(height: 32),

                // Go to Profile Button
                _buildActionButton(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }



  /// Primary action button
  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isNavigating ? null : _goToProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          disabledBackgroundColor: AppColors.primaryBlue.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isNavigating
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                'Go to Profile',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
