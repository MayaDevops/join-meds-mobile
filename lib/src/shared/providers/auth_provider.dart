import 'package:flutter/foundation.dart';
import '../services/storage/local_storage_service.dart';
import '../services/api/api_client.dart';
import '../../core/constants/storage_keys.dart';
import '../services/v2/repository_provider.dart';
import '../models/v2/auth/login_request.dart';
import '../models/v2/auth/signup_request.dart';
import '../services/api/api_exceptions.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

enum UserType {
  user,
  organisation,
}

class AuthProvider extends ChangeNotifier {
  final LocalStorageService _storageService;
  final ApiClient _apiClient;

  AuthStatus _status = AuthStatus.initial;
  UserType? _userType;
  String? _error;
  String? _token;
  String? _userId;

  AuthProvider(this._storageService, this._apiClient) {
    _checkAuthStatus();
  }

  // Getters
  AuthStatus get status => _status;
  UserType? get userType => _userType;
  String? get error => _error;
  String? get token => _token;
  String? get userId => _userId;

  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isInitial => _status == AuthStatus.initial;
  bool get hasError => _status == AuthStatus.error;
  bool get isUser => _userType == UserType.user;
  bool get isOrganisation => _userType == UserType.organisation;

  // Check auth status on app start
  Future<void> _checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      _token = _storageService.getString(StorageKeys.authToken);
      _userId = _storageService.getString(StorageKeys.userId);

      final userTypeStr = _storageService.getString(StorageKeys.userType);
      if (userTypeStr != null) {
        _userType = userTypeStr == 'organisation' ? UserType.organisation : UserType.user;
      }

      if (_token != null && _token!.isNotEmpty) {
        _apiClient.setAuthToken(_token!);
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = e.toString();
    }

    notifyListeners();
  }

  // Login
  Future<bool> login({
    required String emailOrPhone,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      // Create login request
      final loginRequest = LoginRequest(
        username: emailOrPhone,
        password: password,
      );

      // Call API through repository
      debugPrint('Attempting login with username: $emailOrPhone');
      final response = await RepositoryProvider.instance.authRepo.login(loginRequest);
      debugPrint('Login response: success=${response.success}, hasData=${response.data != null}, message=${response.message}');

      // Check if response is successful
      if (response.success && response.data != null) {
        final authData = response.data!;

        // Extract auth data
        _token = authData.token;
        _userId = authData.userId?.toString();

        // Determine user type
        if (authData.organizationName != null && authData.organizationName!.isNotEmpty) {
          _userType = UserType.organisation;
        } else {
          _userType = UserType.user;
        }

        // Save auth data to local storage
        await _saveAuthData();

        // Save user profile data for UserProvider
        final userProfile = {
          'fullName': authData.username ?? authData.email?.split('@')[0] ?? 'User',
          'email': authData.email,
          'phone': authData.phone,
          'profession': null,
          'profileImageUrl': null,
          'resumeUrl': null,
        };
        await _storageService.setObject(StorageKeys.userProfile, userProfile);
        debugPrint('AuthProvider: Saved user profile to storage during login: $userProfile');

        // Set token in API client
        if (_token != null) {
          _apiClient.setAuthToken(_token!);
        }

        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else if (response.success && response.data == null) {
        _status = AuthStatus.error;
        _error = 'Invalid response from server. Please try again.';
        debugPrint('Login error: Response data is null despite success=true');
        notifyListeners();
        return false;
      } else {
        _status = AuthStatus.error;
        _error = response.message.isNotEmpty ? response.message : 'Login failed. Please try again.';
        debugPrint('Login failed: ${response.message}');
        notifyListeners();
        return false;
      }
    } on BadRequestException {
      _status = AuthStatus.error;
      _error = 'Invalid email or password';
      notifyListeners();
      return false;
    } on UnauthorizedException {
      _status = AuthStatus.error;
      _error = 'Invalid credentials';
      notifyListeners();
      return false;
    } on ServerException {
      _status = AuthStatus.error;
      _error = 'Server error. Please try again later.';
      notifyListeners();
      return false;
    } on NetworkException {
      _status = AuthStatus.error;
      _error = 'Network error. Please check your connection.';
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      _status = AuthStatus.error;
      _error = 'An unexpected error occurred';
      debugPrint('Login error: $e');
      debugPrint('Stack trace: $stackTrace');
      notifyListeners();
      return false;
    }
  }

  // Organisation Login
  Future<bool> loginOrganisation({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      _userType = UserType.organisation;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Signup
  Future<bool> signup({
    required String emailOrPhone,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      // Detect if input is email or phone
      String username = emailOrPhone.trim();
      String? email;
      String? phone;

      // Check if it's an email (contains @)
      if (username.contains('@')) {
        email = username;
      } else {
        // It's a phone number - prepend +91 if not already present
        if (!username.startsWith('+')) {
          username = '+91$username';
        }
        phone = username;
      }

      // Create signup request
      final signupRequest = SignupRequest(
        username: username,
        password: password,
        email: email,
        phone: phone,
      );

      // Call API through repository
      debugPrint('Attempting signup with username: $username');
      final response = await RepositoryProvider.instance.authRepo.signup(signupRequest);
      debugPrint('Signup response: success=${response.success}, hasData=${response.data != null}, message=${response.message}');

      // Check if response is successful
      if (response.success && response.data != null) {
        final authData = response.data!;

        // Extract auth data
        _token = authData.token;
        _userId = authData.userId?.toString();

        // Determine user type
        if (authData.organizationName != null && authData.organizationName!.isNotEmpty) {
          _userType = UserType.organisation;
        } else {
          _userType = UserType.user;
        }

        // Save auth data to local storage
        await _saveAuthData();

        // Save user profile data for UserProvider
        final userProfile = {
          'fullName': authData.username ?? authData.email?.split('@')[0] ?? 'User',
          'email': authData.email,
          'phone': authData.phone,
          'profession': null,
          'profileImageUrl': null,
          'resumeUrl': null,
        };
        await _storageService.setObject(StorageKeys.userProfile, userProfile);
        debugPrint('AuthProvider: Saved user profile to storage during signup: $userProfile');

        // Set token in API client
        if (_token != null) {
          _apiClient.setAuthToken(_token!);
        }

        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else if (response.success && response.data == null) {
        _status = AuthStatus.error;
        _error = 'Invalid response from server. Please try again.';
        debugPrint('Signup error: Response data is null despite success=true');
        notifyListeners();
        return false;
      } else {
        _status = AuthStatus.error;
        _error = response.message.isNotEmpty ? response.message : 'Signup failed. Please try again.';
        debugPrint('Signup failed: ${response.message}');
        notifyListeners();
        return false;
      }
    } on BadRequestException {
      _status = AuthStatus.error;
      _error = 'Invalid signup data. Please check your inputs.';
      notifyListeners();
      return false;
    } on UnauthorizedException {
      _status = AuthStatus.error;
      _error = 'This account already exists.';
      notifyListeners();
      return false;
    } on ServerException {
      _status = AuthStatus.error;
      _error = 'Server error. Please try again later.';
      notifyListeners();
      return false;
    } on NetworkException {
      _status = AuthStatus.error;
      _error = 'Network error. Please check your connection.';
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      _status = AuthStatus.error;
      _error = 'An unexpected error occurred';
      debugPrint('Signup error: $e');
      debugPrint('Stack trace: $stackTrace');
      notifyListeners();
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOtp({
    required String otp,
    required String phone,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Resend OTP
  Future<bool> resendOtp({required String phone}) async {
    try {
      // TODO: Implement actual API call
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    await _storageService.remove(StorageKeys.authToken);
    await _storageService.remove(StorageKeys.refreshToken);
    await _storageService.remove(StorageKeys.userId);
    await _storageService.remove(StorageKeys.userData);
    await _storageService.remove(StorageKeys.userType);

    _apiClient.clearAuthToken();

    _token = null;
    _userId = null;
    _userType = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // Save auth data to storage
  Future<void> _saveAuthData() async {
    if (_token != null) {
      await _storageService.setString(StorageKeys.authToken, _token!);
    }
    if (_userId != null) {
      await _storageService.setString(StorageKeys.userId, _userId!);
    }
    if (_userType != null) {
      await _storageService.setString(
        StorageKeys.userType,
        _userType == UserType.organisation ? 'organisation' : 'user',
      );
    }
  }

  // Update token (e.g., after refresh)
  Future<void> updateToken(String newToken) async {
    _token = newToken;
    await _storageService.setString(StorageKeys.authToken, newToken);
    _apiClient.setAuthToken(newToken);
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // Check if onboarding is complete
  bool get isOnboardingComplete {
    return _storageService.getBoolOrDefault(StorageKeys.onboardingComplete);
  }

  // Set onboarding complete
  Future<void> setOnboardingComplete() async {
    await _storageService.setBool(StorageKeys.onboardingComplete, true);
  }

  // Check if first launch
  bool get isFirstLaunch {
    return !_storageService.containsKey(StorageKeys.isFirstLaunch);
  }

  // Set first launch complete
  Future<void> setFirstLaunchComplete() async {
    await _storageService.setBool(StorageKeys.isFirstLaunch, false);
  }
}
