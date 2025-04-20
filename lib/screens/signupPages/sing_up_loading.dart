import 'package:flutter/material.dart';
import 'package:untitled/constants/images.dart';
import 'package:untitled/screens/signupPages/personal_data.dart';

class SignUpLoading extends StatefulWidget {
  const SignUpLoading({super.key});

  @override
  State<SignUpLoading> createState() => _SignUpLoadingState();
}

class _SignUpLoadingState extends State<SignUpLoading> {
  @override
  void initState() {
    super.initState();
    _redirectToNextPage();
  }

  Future<void> _redirectToNextPage() async {
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PersonalData()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Image.asset(appLogo),),
            const SizedBox(height: 50),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Text(
                'Signing In',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Image.asset(medLandLogo),
      ),
    );
  }
}
