import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../api/api_service.dart';
import '../../../../../models/login_request.dart';
import '../widgets/email_phone_text_field.dart';
import '../widgets/password_text_field.dart';
import '../widgets/hero_logo.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

// SharedPreferences keys
const String keyUserId = 'userId';
const String keyUsername = 'username';
const String keyEmailMobile = 'emailMobile';
const String keyUserType = 'userType';
const String keyOrgName = 'orgName';
const String keyIncorporationNo = 'incorporationNo';
const String keyOfficialEmail = 'officialEmail';
const String keyOfficePhone = 'officePhone';
const String keyCreatedAt = 'createdAt';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPhoneNumber = false;

  @override
  void dispose() {
    _emailPhoneController.dispose();
    _passwordController.dispose();
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

  Future<void> _saveUserDataToPrefs(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    final dataMap = {
      keyUserId: userData['id'],
      keyUsername: userData['username'],
      keyEmailMobile: userData['emailMobile'],
      keyUserType: userData['userType'],
      keyOrgName: userData['orgName'],
      keyIncorporationNo: userData['incorporationNo'],
      keyOfficialEmail: userData['officialEmail'],
      keyOfficePhone: userData['officePhone'],
      keyCreatedAt: userData['createdAt'],
    };

    for (var entry in dataMap.entries) {
      if (entry.value != null) {
        await prefs.setString(entry.key, entry.value.toString());
      }
    }

    debugPrint('✅ User data saved to SharedPreferences');
    debugPrint('   - userId: ${userData['id']}');
    debugPrint('   - username: ${userData['username']}');
    debugPrint('   - userType: ${userData['userType']}');
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Prepend +91 if it's a phone number
    String username = _emailPhoneController.text.trim();
    if (_isPhoneNumber && !username.startsWith('+')) {
      username = username;
    }

    final loginRequest = LoginRequest(
      username: username,
      password: _passwordController.text.trim(),
    );

    try {
      final response = await ApiService().login(loginRequest);

      if (response.statusCode == 200 && response.data != null) {
        final responseBody = response.data;
        await _saveUserDataToPrefs(responseBody);

        if (!mounted) return;
        context.go('/home');
      } else {
        _showSnackBar('Login failed. Please check your credentials.');
      }
    } on DioException catch (dioError) {
      final statusCode = dioError.response?.statusCode ?? 0;

      if (statusCode == 401 || statusCode == 400) {
        _showSnackBar("Invalid email or password. Please try again.");
      } else if (statusCode >= 500) {
        _showSnackBar("Server is unavailable. Please try later.");
      } else if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout) {
        _showSnackBar("Connection timeout. Please try again.");
      } else {
        _showSnackBar("Network error. Please check your connection.");
      }

      debugPrint("❌ Dio error [$statusCode]: ${dioError.response?.data}");
    } catch (e, stack) {
      debugPrint('❗ Unexpected error: $e');
      debugPrint('StackTrace: $stack');
      _showSnackBar("Unexpected error. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
                    padding:  EdgeInsets.only(top: MediaQuery.paddingOf(context).top, bottom: 0),
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
                            const SizedBox(height: 16),
                            // Title
                            Text(
                              'Sign in to your\nAccount',
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
                              'Enter your email and password to log in',
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
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),

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
                                    const SizedBox(height: 40),
                                    // Email/Phone and Password Inputs
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
                                          const SizedBox(height: 16),
                                          // Password Field
                                          PasswordTextField(
                                            controller: _passwordController,
                                            hintText: 'Enter Password',
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Password is required';
                                              }
                                              if (value.length < 8) {
                                                return 'Password must be at least 8 characters';
                                              }
                                              return null;
                                            },
                                          ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.3, end: 0, duration: 400.ms, delay: 400.ms),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Login Button
                                    PrimaryButton(
                                      text: 'Login',
                                      onPressed: _onLogin,
                                      isLoading: _isLoading,
                                      elevation: 0,
                                      animationType: 'scale',
                                      textStyle: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),

                                    const SizedBox(height: 24),


                                    // Register Link
                                    Padding(
                                      padding: const EdgeInsets.only(bottom : 32),
                                      child: GestureDetector(
                                        onTap: () {
                                          context.push('/forgot_password');
                                        },
                                        child: RichText(
                                          text: TextSpan(
                                            text: "Having trouble signing in?",
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFF666666),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'Forgot Password',
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
                                    ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom : 32),
                                      child: GestureDetector(
                                        onTap: () {
                                          context.push('/sign_up');
                                        },
                                        child: RichText(
                                          text: TextSpan(
                                            text: "Don't have an account? ",
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFF666666),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'Register now',
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
                                    ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
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
