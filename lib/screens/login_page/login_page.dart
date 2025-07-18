import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/widgets/text_form_widget2.dart';
import '../../constants/constant.dart';
import '../../constants/images.dart';
import '../../widgets/main_button.dart';
import 'package:untitled/models/login_request.dart';
import 'package:untitled/api/api_service.dart';
import 'package:dio/dio.dart'; // Required for catching DioError

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showPassword = true;
  final _loginKey = GlobalKey<FormState>();
  final _emailPhoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required Email/Phone Number';
    }
    final regex = RegExp(
      r"(^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$)|(^\+?\d{10,15}$)",
    );
    return regex.hasMatch(value.trim())
        ? null
        : 'Enter valid Email/Phone Number';
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters long';
    return null;
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          TextFormWidget2(
            controller: controller,
            validator: validator,
            hintText: hintText,
            keyboardType: keyboardType,
            obscureText: obscureText,
            suffixIcon: suffixIcon,
            readOnly: false,
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_loginKey.currentState!.validate()) {
      final loginRequest = LoginRequest(
        username: _emailPhoneController.text.trim(),
        password: _passwordController.text.trim(),
      );

      try {
        final response = await ApiService().login(loginRequest);

        if (response.statusCode == 200) {
          // ✅ Use response.data directly, no jsonDecode
          final responseBody = response.data;
          final userId = responseBody['id']; // Adjust this key as needed

          if (userId != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('userId', userId.toString());
            debugPrint('✅ userId stored: $userId');
          }

          Navigator.pushReplacementNamed(context, '/login_page_loading');
        } else {
          print('❌ Login failed: ${response.statusCode} - ${response.data}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${response.statusMessage}')),
          );
        }
      } on DioException catch (dioError) {
        String message = 'Unknown error';
        if (dioError.response != null) {
          message =
          'Server Error ${dioError.response?.statusCode}: ${dioError.response?.data}';
        } else {
          message = 'Network error: ${dioError.message}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e, stack) {
        print('❗ Unexpected error: $e');
        print('StackTrace: $stack');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: ${e.toString()}')),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(loginBanner,
                      fit: BoxFit.cover, width: double.infinity),
                  Form(
                    key: _loginKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        _buildTextField(
                          label: 'Email / Phone Number',
                          controller: _emailPhoneController,
                          hintText: 'Enter Email/Phone Number',
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmailOrPhone,
                        ),
                        _buildTextField(
                          label: 'Password',
                          controller: _passwordController,
                          hintText: 'Enter Password',
                          obscureText: _showPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: mainBlue,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                          validator: _validatePassword,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MainButton(
              text: 'Login',
              onPressed: _handleLogin,
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('If you don’t have an account ',
                    style: TextStyle(fontSize: 16)),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/sign_up'),
                  child: Text(
                    ' Sign Up',
                    style: TextStyle(
                        fontSize: 16,
                        color: mainBlue,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}