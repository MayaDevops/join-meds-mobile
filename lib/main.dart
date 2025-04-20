import 'package:flutter/material.dart';
import 'package:untitled/screens/Doctor/dr_academic_status.dart';
import 'package:untitled/screens/landing_page.dart';
import 'package:untitled/screens/login_page/login_page.dart';
import 'package:untitled/screens/onboarding.dart';
import 'package:untitled/screens/organisation/about_organisation.dart';
import 'package:untitled/screens/organisation/org_phone_number.dart';
import 'package:untitled/screens/organisation/organisation_landing.dart';
import 'package:untitled/screens/organisation/organisation_otp_page.dart';
import 'package:untitled/screens/signupPages/profile_picture.dart';
import 'package:untitled/screens/signupPages/resume_upload.dart';
import 'package:untitled/screens/signupPages/sign_up.dart';
import 'screens/signupPages/personal_data.dart';
import 'screens/signupPages/sing_up_loading.dart';

void main() {
  runApp(MaterialApp(

    debugShowCheckedModeBanner: false,
    routes: {
      '/': (context)=> const Onboarding(),
      '/landing_page': (context)=> const LandingPage(),
      '/organisation_home': (context)=> const OrganisationLanding(),
      '/organisation_otp': (context)=> const OrganisationOtpPage(),
      '/org_phone_number': (context)=> const OrgPhoneNumber(),
      '/about_organisation': (context)=> const AboutOrganisation(),
      '/login_page': (context)=> const LoginPage(),
      '/sign_up': (context)=> const SignUp(),
      '/sign_up_loading': (context)=> const SignUpLoading(),
      '/personal_data': (context)=> const PersonalData(),
      '/profile_picture': (context)=> const ProfilePicture(),
      '/resume_upload': (context)=> const ResumeUpload(),
      '/dr_acd_status': (context)=> const DrAcademicStatus(),


    },
    initialRoute: '/',
  ),
  );
}




