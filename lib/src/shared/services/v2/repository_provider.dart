import '../api/api_client.dart';
import 'repositories/interfaces/i_auth_repo.dart';
import 'repositories/interfaces/i_otp_repo.dart';
import 'repositories/interfaces/i_user_repo.dart';
import 'repositories/interfaces/i_organization_repo.dart';
import 'repositories/interfaces/i_job_repo.dart';
import 'repositories/interfaces/i_file_repo.dart';
import 'repositories/implementations/auth_repo.dart';
import 'repositories/implementations/otp_repo.dart';
import 'repositories/implementations/user_repo.dart';
import 'repositories/implementations/organization_repo.dart';
import 'repositories/implementations/job_repo.dart';
import 'repositories/implementations/file_repo.dart';

/// Provides singleton instances of all V2 repositories
///
/// Usage:
/// ```dart
/// final authRepo = RepositoryProvider.instance.authRepo;
/// final response = await authRepo.login(loginRequest);
/// ```
class RepositoryProvider {
  static RepositoryProvider? _instance;

  /// Get singleton instance
  static RepositoryProvider get instance {
    _instance ??= RepositoryProvider._();
    return _instance!;
  }

  late final IAuthRepo _authRepo;
  late final IOtpRepo _otpRepo;
  late final IUserRepo _userRepo;
  late final IOrganizationRepo _organizationRepo;
  late final IJobRepo _jobRepo;
  late final IFileRepo _fileRepo;

  /// Private constructor for singleton pattern
  RepositoryProvider._() {
    final apiClient = ApiClient();

    _authRepo = AuthRepo(apiClient);
    _otpRepo = OtpRepo(apiClient);
    _userRepo = UserRepo(apiClient);
    _organizationRepo = OrganizationRepo(apiClient);
    _jobRepo = JobRepo(apiClient);
    _fileRepo = FileRepo(apiClient);
  }

  /// Constructor with custom ApiClient (for testing)
  RepositoryProvider._withClient(ApiClient apiClient) {
    _authRepo = AuthRepo(apiClient);
    _otpRepo = OtpRepo(apiClient);
    _userRepo = UserRepo(apiClient);
    _organizationRepo = OrganizationRepo(apiClient);
    _jobRepo = JobRepo(apiClient);
    _fileRepo = FileRepo(apiClient);
  }

  // Repository getters

  /// Authentication repository
  IAuthRepo get authRepo => _authRepo;

  /// OTP repository
  IOtpRepo get otpRepo => _otpRepo;

  /// User repository
  IUserRepo get userRepo => _userRepo;

  /// Organization repository
  IOrganizationRepo get organizationRepo => _organizationRepo;

  /// Job repository
  IJobRepo get jobRepo => _jobRepo;

  /// File repository
  IFileRepo get fileRepo => _fileRepo;

  // Testing utilities

  /// Initialize with custom API client (for testing)
  static void initialize(ApiClient apiClient) {
    _instance = RepositoryProvider._withClient(apiClient);
  }

  /// Reset singleton (for testing)
  static void reset() {
    _instance = null;
  }
}
