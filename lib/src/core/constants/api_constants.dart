class ApiConstants {
  static const String baseUrl = 'https://api.joinmeds.in/api';

  // Auth endpoints
  static const String login = '/user/login';
  static const String signup = '/user/signup';
  static const String verifyOtp = '/user/verify-otp';
  static const String resendOtp = '/user/resend-otp';
  static const String logout = '/user/logout';
  static const String forgotPassword = '/user/forgot-password';
  static const String resetPassword = '/user/reset-password';

  // User endpoints
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile/update';
  static const String uploadProfilePicture = '/user/profile/picture';
  static const String uploadResume = '/user/profile/resume';
  static const String personalData = '/user/personal-data';

  // Job endpoints
  static const String jobs = '/jobs';
  static const String searchJobs = '/jobs/search';
  static const String applyJob = '/jobs/apply';
  static const String myApplications = '/user/applications';
  static const String savedJobs = '/user/saved-jobs';

  // Organisation endpoints
  static const String orgLogin = '/organisation/login';
  static const String orgSignup = '/organisation/signup';
  static const String orgProfile = '/organisation/profile';
  static const String orgJobs = '/organisation/jobs';
  static const String orgCreateJob = '/organisation/jobs/create';
  static const String orgUpdateJob = '/organisation/jobs/update';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
