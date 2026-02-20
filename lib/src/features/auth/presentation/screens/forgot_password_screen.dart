import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../api/user_api_service.dart';
import '../widgets/email_phone_text_field.dart';
import '../widgets/password_text_field.dart';
import '../widgets/hero_logo.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _isPhoneNumber = false;
  bool _isOtpStage = false;
  bool _isLoading = false;
  bool _isOtpLoading = false;

  @override
  void dispose() {
    _emailPhoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onEmailPhoneChanged(String value) {
    final trimmed = value.trim();
    setState(() {
      _isPhoneNumber =
          trimmed.isNotEmpty && RegExp(r'^[0-9]+$').hasMatch(trimmed);
    });
  }

  String? _validateEmailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email/Phone is required';
    }

    final trimmed = value.trim();

    if (trimmed.contains('@')) {
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );
      if (!emailRegex.hasMatch(trimmed)) {
        return 'Enter a valid email address';
      }
      return null;
    }

    if (RegExp(r'^[0-9]+$').hasMatch(trimmed)) {
      if (trimmed.length != 10) {
        return 'Phone number must be exactly 10 digits';
      }
      return null;
    }

    return 'Enter a valid email or phone number';
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
            onPressed: () {
              Navigator.of(context).pop(); // close dialog first

              // if (message.toLowerCase().contains('user already exists')) {
              //   context.go(RouteNames.login); // or context.pop() if login is previous
              // }
            }
            ,
          ),
        ],
      ),
    );
  }


  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await UserApiService().sendOtp(
        mobile: _emailPhoneController.text.trim(),
      );

      if (response.statusCode != 200) {
        throw Exception();
      }

      if (!mounted) return;
      setState(() => _isOtpStage = true);
    } catch (_) {
      _showError("Failed to send OTP");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().length != 6) {
      _showErrorDialog("Invalid OTP", "Enter 6 digit OTP");
      return;
    }

    setState(() => _isOtpLoading = true);

    try {
      final response = await UserApiService().verifyOtp(
        mobile: _emailPhoneController.text.trim(),
        otp: _otpController.text.trim(),
      );

      if (response.statusCode != 200) {
        throw Exception("OTP verification failed");
      }

      final data = jsonDecode(response.body);

      final bool success = data['success'] == true;
      final String message =
          data['message'] ?? 'OTP verification failed';

      if (!success) {
        // ❌ OTP invalid → STOP here
        _showErrorDialog("OTP Failed", message);
        return;
      }

      // ✅ OTP VERIFIED → NOW reset password
      await _resetPassword();

    } catch (e) {
      _showErrorDialog(
        "Error",
        "Unable to verify OTP. Please try again.",
      );
    } finally {
      if (mounted) setState(() => _isOtpLoading = false);
    }
  }



  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await UserApiService().resetPassword(
        mobile: _emailPhoneController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception();
      }

      if (!mounted) return;
      context.pop(); // Back to Login
    } catch (_) {
      _showError("Password reset failed");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
              Color(0xFF00A4E1),
              Color(0xFF0090C7),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: screenHeight,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.paddingOf(context).top,
                    ),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Image.asset('assets/v2/Star.png'),
                        ),
                        Column(
                          children: [
                            const HeroLogo(height: 50),
                            const SizedBox(height: 8),
                            Text(
                              'Forgot your\nPassword?',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 400.ms)
                                .slideY(begin: 0.2),
                            const SizedBox(height: 8),
                            Text(
                              'Reset it securely using OTP',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ).animate().fadeIn(delay: 200.ms),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child:
                          SizedBox.expand(child: ColoredBox(color: Colors.white)),
                        ),
                        Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 24),
                                EmailPhoneTextField(
                                  controller: _emailPhoneController,
                                  isPhoneNumber: _isPhoneNumber,
                                  onChanged: _onEmailPhoneChanged,
                                  validator: _validateEmailOrPhone,
                                ),
                                if (_isOtpStage) ...[
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _otpController,
                                    maxLength: 6,
                                    keyboardType: TextInputType.number,
                                    decoration:
                                    const InputDecoration(hintText: 'Enter OTP'),
                                  ),
                                  const SizedBox(height: 8),
                                  PasswordTextField(
                                    controller: _newPasswordController,
                                    hintText: 'New Password',
                                  ),
                                  const SizedBox(height: 8),
                                  PasswordTextField(
                                    controller: _confirmPasswordController,
                                    hintText: 'Confirm Password',
                                  ),
                                ],
                                const SizedBox(height: 16),
                                PrimaryButton(
                                  text: _isOtpStage
                                      ? 'Reset Password'
                                      : 'Send OTP',
                                  onPressed:
                                  _isOtpStage ? _verifyOtp : _sendOtp,
                                  isLoading: _isLoading,
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .slideY(begin: 0.3, end: 0)
                            .fadeIn(),
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
