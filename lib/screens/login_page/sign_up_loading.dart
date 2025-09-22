import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:untitled/constants/images.dart';
import 'package:untitled/screens/login_page/login_page.dart';

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
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          decoration: const BoxDecoration(

          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo
                  Image.asset(
                    appLogo,
                    height: 100,
                  ),
                  const SizedBox(height: 40),

                  // Lottie animation
                  Lottie.asset(
                    loadingAnimation3, // Make sure this file exists
                    height: 200,
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'You have signed in successfully. Redirecting to the login page...',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Image.asset(
          medLandLogo,
          height: 150,
        ),
      ),
    );
  }
}
