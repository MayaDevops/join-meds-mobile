import 'package:flutter/material.dart';
import 'package:untitled/constants/images.dart';
import 'package:untitled/screens/login_page/home_screen.dart';
import 'package:untitled/screens/signupPages/personal_data.dart';

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(appLogo),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Text(
                'Logging',
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
