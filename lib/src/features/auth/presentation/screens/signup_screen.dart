import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../api/user_api_service.dart';
import '../../../../../models/signup_request.dart';
import '../widgets/email_phone_text_field.dart';
import '../widgets/password_text_field.dart';
import '../widgets/hero_logo.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../core/router/route_names.dart';

const String sharedPrefUserIdKey = 'userId'; // Constant for SharedPreferences key

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isPhoneNumber = false;
  bool _isTermsAccepted = false;

  @override
  void dispose() {
    _emailPhoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onEmailPhoneChanged(String value) {
    final trimmed = value.trim();

    bool shouldBePhone = false;

    // Detect email: contains @ or domain extensions
    if (trimmed.contains('@') || trimmed.contains('.')) {
      shouldBePhone = false;
    }
    // Detect phone: only digits (and not empty)
    else if (trimmed.isNotEmpty && RegExp(r'^[0-9]+$').hasMatch(trimmed)) {
      shouldBePhone = true;
    }

    // Update state if changed
    if (_isPhoneNumber != shouldBePhone) {
      setState(() {
        _isPhoneNumber = shouldBePhone;
      });
    }
  }

  String? _validateEmailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email/Phone is required';
    }

    final trimmed = value.trim();

    // Email validation
    if (trimmed.contains('@')) {
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
      );
      if (!emailRegex.hasMatch(trimmed)) {
        return 'Enter a valid email address';
      }
      return null;
    }

    // Phone validation
    if (RegExp(r'^[0-9]+$').hasMatch(trimmed)) {
      if (trimmed.length != 10) {
        return 'Phone number must be exactly 10 digits';
      }
      return null;
    }

    // Invalid format
    return 'Enter a valid email or phone number';
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _onSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must accept the Terms & Privacy Policy.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final request = SignupRequest(
      orgName: "",
      officialEmail: "",
      officialPhone: "",
      incorporationNo: "",
      emailMobile: _emailPhoneController.text.trim(),
      password: _passwordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
      createdAt: "",
      userType: "CITIZEN",
    );

    try {
      final response = await UserApiService().signup(request);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Handle both 'userId' and 'id' fields from API
        final userId = responseData['userId'] ?? responseData['id'];

        if (userId != null) {
          final prefs = await SharedPreferences.getInstance();

          // Save userId
          await prefs.setString(sharedPrefUserIdKey, userId.toString());

          // Initialize onboarding flags
          await prefs.setBool('onboarding_complete', false);
          await prefs.setBool('personal_data_complete', false);
          await prefs.setBool('profession_selected', false);

          debugPrint("✅ Saved userId to prefs: $userId");
        }

        if (!mounted) return;

        // Navigate to personal data screen (V2 flow)
        context.go('/personal_data');
      } else {
        if (!mounted) return;
        // Parse error message from API response
        String errorMessage = "Something went wrong. Please try again later.";
        try {
          // Try to parse as JSON first
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ??
                         errorData['error'] ??
                         errorMessage;
        } catch (e) {
          // If not JSON, use response body as plain text if it's not empty
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
          debugPrint("Using plain text error response: ${response.body}");
        }
        _showErrorDialog("Signup Failed", errorMessage);
        debugPrint("❌ Signup API Error: ${response.body}");
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog("Error", "Unable to connect. Check your internet.");
      debugPrint("❌ Exception during signup: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              Color(0xFF00A4E1), // Primary blue
              Color(0xFF0090C7), // Darker blue
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: screenHeight - MediaQuery.of(context).padding.top,
              child: Column(
                children: [
                  // Top Section with Logo and Text
                  Padding(
                    padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top, bottom: 0),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // Background star pattern
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Image.asset(
                            'assets/v2/Star.png',
                          ),
                        ),
                        // Content (logo and text)
                        Column(
                          children: [
                            // Logo
                            const HeroLogo(height: 50),
                            const SizedBox(height: 8),
                            // Title
                            Text(
                              'Create your\nAccount',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 400.ms),
                            const SizedBox(height: 8),
                            // Subtitle
                            Text(
                              'Sign up to get started',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w400,
                              ),
                            ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 400.ms),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // White Card Section
                  Expanded(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 100.0),
                          child: SizedBox.expand(child: ColoredBox(color: Colors.white)),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.5),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 25.2),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 25.2),
                                    // Form Fields
                                    Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          // Email/Phone Field
                                          EmailPhoneTextField(
                                            controller: _emailPhoneController,
                                            isPhoneNumber: _isPhoneNumber,
                                            onChanged: _onEmailPhoneChanged,
                                            validator: _validateEmailOrPhone,
                                          ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.3, end: 0, duration: 400.ms, delay: 300.ms),
                                          const SizedBox(height: 8),

                                          // Password Field
                                          PasswordTextField(
                                            controller: _passwordController,
                                            hintText: 'Enter Password',
                                            validator: _validatePassword,
                                          ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.3, end: 0, duration: 400.ms, delay: 400.ms),
                                          const SizedBox(height: 8),

                                          // Confirm Password Field
                                          PasswordTextField(
                                            controller: _confirmPasswordController,
                                            hintText: 'Confirm Password',
                                            validator: _validateConfirmPassword,
                                          ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 0.3, end: 0, duration: 400.ms, delay: 500.ms),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // Terms & Conditions Checkbox
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Checkbox(
                                          value: _isTermsAccepted,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              _isTermsAccepted = value ?? false;
                                            });
                                          },
                                          activeColor: const Color(0xFF00A4E1),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Wrap(
                                              children: [
                                                Text(
                                                  'I agree to ',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 12,
                                                    color: const Color(0xFF666666),
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    context.push('/user_terms_and_conditions');
                                                  },
                                                  child: Text(
                                                    'Terms and Conditions',
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 12,
                                                      color: const Color(0xFF00A4E1),
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  ' and ',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 12,
                                                    color: const Color(0xFF666666),
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    context.push('/user_privacy_policy');
                                                  },
                                                  child: Text(
                                                    'Privacy Policy',
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 12,
                                                      color: const Color(0xFF00A4E1),
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ).animate().fadeIn(duration: 400.ms, delay: 600.ms).slideY(begin: 0.3, end: 0, duration: 400.ms, delay: 600.ms),

                                    const SizedBox(height: 8),

                                    // Sign Up Button
                                    PrimaryButton(
                                      text: 'Sign Up',
                                      onPressed: _onSignUp,
                                      isLoading: _isLoading,
                                      elevation: 0,
                                      animationType: 'scale',
                                      textStyle: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),


                                    // Login Link
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 24,top: 12),
                                      child: GestureDetector(
                                        onTap: () {
                                          context.pop();
                                        },
                                        child: RichText(
                                          text: TextSpan(
                                            text: "Already have an account? ",
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFF666666),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'Login',
                                                style: GoogleFonts.outfit(
                                                  color: const Color(0xFF00A4E1),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ).animate().fadeIn(delay: 900.ms, duration: 400.ms),
                                  ],
                                ),
                              ),
                            ).animate().slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 200.ms, curve: Curves.easeOutCubic).fadeIn(duration: 400.ms, delay: 200.ms),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
