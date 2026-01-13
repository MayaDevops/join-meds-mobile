import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/services/storage/local_storage_service.dart';
import '../../constants/storage_keys.dart';
import '../route_names.dart';

class AuthGuard {
  final LocalStorageService storageService;

  AuthGuard(this.storageService);

  /// Routes that don't require authentication
  static const List<String> _publicRoutes = [
    RouteNames.splash,
    RouteNames.onboarding,
    RouteNames.landing,
    RouteNames.login,
    RouteNames.signup,
    RouteNames.otpVerification,
    RouteNames.forgotPassword,
    RouteNames.resetPassword,
    RouteNames.orgLogin,
    RouteNames.orgSignup,
    RouteNames.privacyPolicy,
    RouteNames.termsAndConditions,
  ];

  /// Routes only accessible to users (not organisations)
  static const List<String> _userOnlyRoutes = [
    RouteNames.home,
    RouteNames.myJobs,
    RouteNames.savedJobs,
    RouteNames.profile,
    RouteNames.editProfile,
    RouteNames.selectProfession,
    RouteNames.personalData,
    RouteNames.academicStatus,
    RouteNames.workExperience,
    RouteNames.countryPreference,
  ];

  /// Routes only accessible to organisations
  static const List<String> _orgOnlyRoutes = [
    RouteNames.orgHome,
    RouteNames.orgCreateJob,
    RouteNames.orgProfile,
    RouteNames.orgSettings,
  ];

  /// Main redirect function for GoRouter
  Future<String?> redirect(BuildContext context, GoRouterState state) async {
    final location = state.matchedLocation;
    final isAuthenticated = await _isAuthenticated();
    final isPublicRoute = _isPublicRoute(location);

    // Check if first launch - redirect to onboarding
    if (_isFirstLaunch() && location == RouteNames.splash) {
      return null; // Let splash handle the logic
    }

    // Not authenticated and trying to access protected route
    if (!isAuthenticated && !isPublicRoute) {
      return RouteNames.login;
    }

    // Authenticated and trying to access auth routes (login/signup)
    if (isAuthenticated && _isAuthRoute(location)) {
      final userType = _getUserType();
      return userType == 'organisation' ? RouteNames.orgHome : RouteNames.home;
    }

    // Check user type restrictions
    if (isAuthenticated) {
      final userType = _getUserType();

      // User trying to access org routes
      if (userType == 'user' && _isOrgOnlyRoute(location)) {
        return RouteNames.home;
      }

      // Organisation trying to access user routes
      if (userType == 'organisation' && _isUserOnlyRoute(location)) {
        return RouteNames.orgHome;
      }
    }

    return null; // No redirect needed
  }

  Future<bool> _isAuthenticated() async {
    final token = storageService.getString(StorageKeys.authToken);
    return token != null && token.isNotEmpty;
  }

  bool _isFirstLaunch() {
    return !storageService.containsKey(StorageKeys.isFirstLaunch);
  }

  bool _isOnboardingComplete() {
    return storageService.getBoolOrDefault(StorageKeys.onboardingComplete);
  }

  String? _getUserType() {
    return storageService.getString(StorageKeys.userType);
  }

  bool _isPublicRoute(String location) {
    return _publicRoutes.any((route) => location == route || location.startsWith(route));
  }

  bool _isAuthRoute(String location) {
    const authRoutes = [
      RouteNames.login,
      RouteNames.signup,
      RouteNames.orgLogin,
      RouteNames.orgSignup,
      RouteNames.landing,
    ];
    return authRoutes.contains(location);
  }

  bool _isUserOnlyRoute(String location) {
    return _userOnlyRoutes.any((route) => location == route || location.startsWith(route));
  }

  bool _isOrgOnlyRoute(String location) {
    return _orgOnlyRoutes.any((route) => location == route || location.startsWith(route));
  }
}
