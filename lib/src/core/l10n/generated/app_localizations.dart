import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('hi')
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'JoinMeds'**
  String get appName;

  /// App tagline shown on splash screen
  ///
  /// In en, this message translates to:
  /// **'Your Healthcare Career Partner'**
  String get appTagline;

  /// Greeting on login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// Subtitle on login screen
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your journey'**
  String get signInToContinue;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Email field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Confirm password field hint
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get reenterYourPassword;

  /// Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign up button/link text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Create account button text
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Divider text between login options
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// Text before sign up link
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Text before sign in link
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Organisation login button text
  ///
  /// In en, this message translates to:
  /// **'Login as Organisation'**
  String get loginAsOrganisation;

  /// Sign up page title
  ///
  /// In en, this message translates to:
  /// **'Join JoinMeds'**
  String get joinJoinMeds;

  /// Sign up page subtitle
  ///
  /// In en, this message translates to:
  /// **'Create an account to start your healthcare career journey'**
  String get createAccountSubtitle;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Full name field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterYourFullName;

  /// Phone number field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Phone number field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhoneNumber;

  /// Terms agreement prefix
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get agreeToTerms;

  /// Terms and conditions link text
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// Conjunction between terms and privacy
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// Privacy policy link text
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Greeting with user name
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}!'**
  String hello(String name);

  /// Home page subtitle
  ///
  /// In en, this message translates to:
  /// **'Find your dream healthcare job'**
  String get findYourDreamJob;

  /// Search field placeholder
  ///
  /// In en, this message translates to:
  /// **'Search for jobs...'**
  String get searchForJobs;

  /// Categories section title
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// Recent jobs section title
  ///
  /// In en, this message translates to:
  /// **'Recent Jobs'**
  String get recentJobs;

  /// View all link text
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Doctor profession
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor;

  /// Nurse profession
  ///
  /// In en, this message translates to:
  /// **'Nurse'**
  String get nurse;

  /// Pharmacist profession
  ///
  /// In en, this message translates to:
  /// **'Pharmacist'**
  String get pharmacist;

  /// Therapist profession
  ///
  /// In en, this message translates to:
  /// **'Therapist'**
  String get therapist;

  /// Lab Technician profession
  ///
  /// In en, this message translates to:
  /// **'Lab Tech'**
  String get labTech;

  /// First onboarding page title
  ///
  /// In en, this message translates to:
  /// **'Find Your Dream Job'**
  String get onboardingTitle1;

  /// First onboarding page description
  ///
  /// In en, this message translates to:
  /// **'Discover thousands of healthcare job opportunities tailored to your profession and preferences.'**
  String get onboardingDesc1;

  /// Second onboarding page title
  ///
  /// In en, this message translates to:
  /// **'Connect with Employers'**
  String get onboardingTitle2;

  /// Second onboarding page description
  ///
  /// In en, this message translates to:
  /// **'Get noticed by top hospitals, clinics, and healthcare organizations looking for talented professionals like you.'**
  String get onboardingDesc2;

  /// Third onboarding page title
  ///
  /// In en, this message translates to:
  /// **'Launch Your Career'**
  String get onboardingTitle3;

  /// Third onboarding page description
  ///
  /// In en, this message translates to:
  /// **'Take the next step in your healthcare career with JoinMeds. Your journey to success starts here.'**
  String get onboardingDesc3;

  /// Skip button text
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Get started button text
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Job details page title
  ///
  /// In en, this message translates to:
  /// **'Job Details'**
  String get jobDetails;

  /// Home navigation label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Jobs navigation label
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get jobs;

  /// Profile navigation label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Notifications page title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get errorOccurred;

  /// Go home button text
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// Email validation error - empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// Email validation error - invalid format
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// Password validation error - empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// Password validation error - too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// Confirm password validation error - empty
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// Confirm password validation error - mismatch
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Name validation error - empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// Name validation error - too short
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameMinLength;

  /// Phone validation error - empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhoneNumber;

  /// Phone validation error - invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get pleaseEnterValidPhoneNumber;

  /// Terms agreement validation error
  ///
  /// In en, this message translates to:
  /// **'Please agree to the Terms and Conditions'**
  String get pleaseAgreeToTerms;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get noInternetConnection;

  /// Timeout error message
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Please try again.'**
  String get connectionTimedOut;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Dark mode toggle label
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Light mode toggle label
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Hindi language name
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// Arabic language name
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
