class RouteNames {
  // Splash & Onboarding
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String landing = '/landing';

  // Auth - User
  static const String login = '/login_page';
  static const String signup = '/signup';
  static const String otpVerification = '/otp-verification';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Auth - Organisation
  static const String orgLogin = '/org/login';
  static const String orgSignup = '/org/signup';

  // Main App - User
  static const String home = '/home';
  static const String jobDetails = '/job/:jobId';
  static const String myJobs = '/my-jobs';
  static const String savedJobs = '/saved-jobs';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String personalDataEdit = '/personal_data';
  static const String profileResume = '/profile/resume';
  static const String settings = '/settings';

  // Main App - Organisation
  static const String orgHome = '/org/home';
  static const String orgJobDetails = '/org/job/:jobId';
  static const String orgCreateJob = '/org/job/create';
  static const String orgEditJob = '/org/job/:jobId/edit';
  static const String orgProfile = '/org/profile';
  static const String orgSettings = '/org/settings';

  // Profile Setup Flow
  static const String selectProfession = '/setup/profession';
  static const String personalData = '/setup/personal-data';
  static const String academicStatus = '/setup/academic-status';
  static const String workExperience = '/setup/work-experience';
  static const String countryPreference = '/setup/country-preference';

  // Dynamic Forms
  static const String professionSelection = '/profession-selection';
  static const String dynamicForm = '/dynamic-form/:professionId';

  // Signup Flow
  static const String signupCompletion = '/signup-completion';

  // Utility Pages
  static const String privacyPolicy = '/privacy-policy';
  static const String termsAndConditions = '/terms-and-conditions';
  static const String userPrivacyPolicy = '/user_privacy_policy';
  static const String userTermsAndConditions = '/user_terms_and_conditions';
  static const String helpSupport = '/help-support';
  static const String aboutUs = '/about-us';

  // Helper methods for parameterized routes
  static String jobDetailsPath(String jobId) => '/job/$jobId';
  static String orgJobDetailsPath(String jobId) => '/org/job/$jobId';
  static String orgEditJobPath(String jobId) => '/org/job/$jobId/edit';
  static String dynamicFormPath(String professionId, {String? courseType}) {
    final path = '/dynamic-form/$professionId';
    return courseType != null ? '$path?courseType=$courseType' : path;
  }



  ///old path : /login_page
  static const String loginPage = '/login_page';

}
