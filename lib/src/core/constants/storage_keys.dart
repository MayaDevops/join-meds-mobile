class StorageKeys {
  // Auth
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userType = 'user_type'; // 'user' or 'organisation'

  // User
  static const String userId = 'user_id';
  static const String userData = 'user_data';
  static const String userProfile = 'user_profile';
  static const String userEmail = 'user_email';
  static const String userPhone = 'user_phone';

  // Organisation
  static const String orgId = 'org_id';
  static const String orgData = 'org_data';

  // App Settings
  static const String themeMode = 'app_theme_mode';
  static const String isFirstLaunch = 'is_first_launch';
  static const String onboardingComplete = 'onboarding_complete';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String languageCode = 'language_code';

  // Profile Completion
  static const String personalDataComplete = 'personal_data_complete';
  static const String academicStatusComplete = 'academic_status_complete';
  static const String workExperienceComplete = 'work_experience_complete';
  static const String professionSelected = 'profession_selected';
}
