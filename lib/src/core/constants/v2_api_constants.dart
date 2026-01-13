/// V2 API Constants for JoinMeds API
/// Based on Swagger documentation: https://api.joinmeds.in/swagger-ui/index.html
class V2ApiConstants {
  // Authentication & User endpoints
  static const String signup = '/user/signup';
  static const String login = '/user/login';
  static const String resetPassword = '/user/reset-password';
  static String signupUpdate(int id) => '/user/signup-update/$id';
  static String userFetch(int id) => '/user/user-fetch/$id';

  // OTP Services endpoints
  static const String sendOtp = '/sms/send';
  static const String verifyOtp = '/sms/verify';

  // User Details & Profile endpoints
  static const String saveUserDetails = '/user-details/save';
  static String updateUserDetails(int userId) => '/user-details/update/$userId';
  static String fetchUserDetails(int userId) => '/user-details/$userId';
  static String fetchCitizenProfile(int userId) => '/user-profile/citizen/details/$userId';

  // Work Experience endpoints
  static const String saveWorkExperience = '/work-experience/save';
  static String updateWorkExperience(int id) => '/work-experience/update/$id';
  static String fetchWorkExperience(int userId) => '/work-experience/fetch/$userId';

  // Organization endpoints
  static const String saveOrg = '/org/save';
  static String updateOrg(int id) => '/org/update/$id';
  static String fetchOrg(int id) => '/org/fetch/$id';
  static const String fetchAllOrgs = '/org/all';

  // Job endpoints
  static String saveJob(int userId) => '/org-job/save/$userId';
  static String updateJob(String jobId) => '/org-job/update/$jobId';
  static const String fetchAllJobs = '/org-job/list';
  static String deleteJob(String jobId) => '/org-job/delete/$jobId';
  static const String fetchRecommendedJobs = '/org-job/recommended';
  static String searchJobsByHiringFor(String keyword) => '/org-job/list/hiring-for/$keyword';

  // Job Application endpoints
  static const String applyToJob = '/job-applied/save';
  static String fetchUserApplications(String userId) => '/job-applied/user/$userId';
  static const String searchApplications = '/job-applied/search';

  // Job Bookmarks endpoints
  static String bookmarkJob(String jobId) => '/job-bookmarks/save/$jobId';
  static String removeBookmark(String jobId) => '/job-bookmarks/remove/$jobId';
  static const String fetchBookmarkedJobs = '/job-bookmarks/list';

  // Home Screen endpoints
  static const String fetchActiveBanner = '/home/banner/active';

  // File Management endpoints
  static String uploadResume(int userId) => '/resume/upload/$userId';
  static String uploadImage(int userId) => '/images/upload/$userId';
  static String downloadResume(String filename) => '/resume/$filename';
  static String downloadImage(String filename) => '/images/$filename';
}
