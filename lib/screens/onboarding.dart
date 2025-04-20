import 'package:flutter/material.dart';
import 'package:untitled/constants/images.dart';
import 'package:untitled/screens/landing_page.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      redirectToNextPage();
    });
  }

  void redirectToNextPage() async {
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LandingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Image.asset(appLogo),
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Image.asset(medLandLogo),
            ),
          ],
        ),
      ),
    );
  }
}
