import 'package:flutter/material.dart';
import 'package:untitled/constants/images.dart';
import 'package:untitled/screens/organisation/organisation_home.dart';
import 'package:untitled/screens/signupPages/personal_data.dart';

class OrganisationSignUpLoading extends StatefulWidget {
  const OrganisationSignUpLoading({super.key});

  @override
  State<OrganisationSignUpLoading> createState() => _OrganisationSignUpLoadingState();
}

class _OrganisationSignUpLoadingState extends State<OrganisationSignUpLoading> {
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
      MaterialPageRoute(builder: (_) => const OrganisationHome()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Image.asset(appLogo),

              const SizedBox(height: 50),

              // Loading indicator
              const CircularProgressIndicator(),

              const SizedBox(height: 20),

              // Label text
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
      ),

      // Bottom logo
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Image.asset(medLandLogo),
      ),
    );
  }
}
