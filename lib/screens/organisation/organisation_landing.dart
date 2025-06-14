import 'package:flutter/material.dart';
import 'package:untitled/constants/constant.dart';
import 'package:untitled/constants/images.dart';
import '../../widgets/main_button.dart';

class OrganisationLandingPage extends StatefulWidget {
  const OrganisationLandingPage({super.key});

  @override
  State<OrganisationLandingPage> createState() => _OrganisationLandingPageState();
}

class _OrganisationLandingPageState extends State<OrganisationLandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(orgLandingPageBanner1, fit: BoxFit.cover),
          SizedBox(
            height: 60,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MainButton(
                  text: 'Login',
                  onPressed: () => Navigator.pushNamed(context, '/organisation_login'),
                ),
                const SizedBox(height: 15),
                OutlinedButton(
                  style: _outlinedButtonStyle(),
                  onPressed: () => Navigator.pushNamed(context, '/organisation_sing_up'),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 20.0, color: mainBlue),
                  ),
                ),

              ],
            ),
          ),

        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Not an organisation ',
              style: TextStyle(fontSize: 18),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/landing_page'),
              child: const Text(
                ' click here',
                style: TextStyle(fontSize: 18, color: mainBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _outlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      side: const BorderSide(width: 3, color: mainBlue),
      padding: const EdgeInsets.all(15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
