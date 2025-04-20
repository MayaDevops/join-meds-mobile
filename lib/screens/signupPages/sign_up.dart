import 'package:flutter/material.dart';
import 'package:untitled/widgets/text_form_widget2.dart';
import '../../constants/constant.dart';
import '../../constants/images.dart';
import '../../widgets/main_button.dart';
import '../../api/user_api_service.dart';
import '../../models/signup_request.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _showPassword = true;
  bool _showConfirmPassword = true;

  final _signInKey = GlobalKey<FormState>();
  final _emailPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailPhoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required Email/Phone Number';
    final regex = RegExp(
        r"(^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$)|(^\+?\d{10,15}$)");
    return regex.hasMatch(value.trim()) ? null : 'Enter valid Email/Phone Number';
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters long';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirm Password is required';
    if (value != _passwordController.text) return 'Passwords do not match';
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
          Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
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

  Future<void> _submitSignup() async {
    if (_signInKey.currentState!.validate()) {
      final request = SignupRequest(
        username: _emailPhoneController.text, // Modify this as needed
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        emailMobile: _emailPhoneController.text,
      );

      final response = await UserApiService().signup(request);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pushNamed(context, '/sign_up_loading');
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Signup Failed"),
            content: Text("Error: ${response.body}"),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
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
            child: RawScrollbar(
              thumbColor: Colors.black38,
              thumbVisibility: true,
              thickness: 8,
              radius: const Radius.circular(10),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(signUpBanner, fit: BoxFit.cover),
                    Form(
                      key: _signInKey,
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
                                _showPassword ? Icons.visibility_off : Icons.visibility,
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
                          _buildTextField(
                            label: 'Confirm Password',
                            controller: _confirmPasswordController,
                            hintText: 'Confirm Password',
                            obscureText: _showConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                color: mainBlue,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showConfirmPassword = !_showConfirmPassword;
                                });
                              },
                            ),
                            validator: _validateConfirmPassword,
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MainButton(
                text: 'Sign In',
                onPressed: _submitSignup,
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('If you have an account ', style: TextStyle(fontSize: 16)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/login_page'),
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 16, color: mainBlue, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
