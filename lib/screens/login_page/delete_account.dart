import 'package:flutter/material.dart';
import '../../constants/constant.dart';
import '../../widgets/text_form_widget2.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  String? pass = 'myPassword';
  final GlobalKey<FormState> _deleteAccountKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffD9D9D9),
        automaticallyImplyLeading: true,
        titleSpacing: 16,
        title: const Text.rich(
          TextSpan(
            text: 'Join',
            style: TextStyle(fontSize: 22, color: Colors.black),
            children: [
              TextSpan(
                text: 'Meds',
                style: TextStyle(color: mainBlue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              "We're sad to see you go.",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Deleting your account will permanently erase all your data. Are you sure you want to continue?",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            Form(
              key: _deleteAccountKey,
              child: _buildTextField(
                label: 'Password',
                controller: _passwordController,
                hintText: 'Enter your password',
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
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_deleteAccountKey.currentState!.validate()) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Deleting account...')),
                  );
                  if(_passwordController.text.trim() == pass){
                    Navigator.pushNamed(context, '/landing_page');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Delete Account',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
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
    return Column(
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
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters long';
    return null;
  }
}
