import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:untitled/constants/images.dart';
import 'package:untitled/screens/login_page/home_screen.dart';

class LoginLoading extends StatefulWidget {
  const LoginLoading({super.key});

  @override
  State<LoginLoading> createState() => _LoginLoadingState();
}

class _LoginLoadingState extends State<LoginLoading> {
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
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: const BoxDecoration(

          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo
                Image.asset(
                  appLogo,
                  height: 150,
                ),
                const SizedBox(height: 40),

                // Lottie animation
                Lottie.asset(
                  loadingAnimation3, // Make sure this file exists
                  height: 200,
                ),

                const SizedBox(height: 10),

                const Text(
                  'Logging you in...',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 20),


              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Image.asset(
          medLandLogo,
          height: 130,
        ),
      ),
    );
  }
}
