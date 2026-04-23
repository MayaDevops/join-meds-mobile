import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// NavigationHelper - A compatibility layer between old Navigator API and GoRouter
///
/// This class provides static methods that mirror the old Navigator API
/// but internally use GoRouter's declarative navigation.
///
/// Usage: Replace `Navigator.push(...)` with `NavigationHelper.push(...)`
class NavigationHelper {
  /// Push a new screen onto the navigation stack
  ///
  /// Example:
  /// ```dart
  /// NavigationHelper.push(context, MaterialPageRoute(
  ///   builder: (context) => MyScreen(),
  /// ));
  /// ```
  static Future<T?> push<T>(
    BuildContext context,
    Route<T> route,
  ) async {
    // Extract the widget from the MaterialPageRoute
    if (route is MaterialPageRoute<T>) {
      final widget = route.builder(context);
      final path = _getPathForWidget(widget);

      if (path != null) {
        context.push(path);
      } else {
        // Fallback: Use the old Navigator for unknown routes
        return Navigator.of(context).push(route);
      }
    }
    return null;
  }

  /// Replace the current screen with a new one
  ///
  /// Example:
  /// ```dart
  /// NavigationHelper.pushReplacement(context, MaterialPageRoute(
  ///   builder: (context) => MyScreen(),
  /// ));
  /// ```
  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    Route<T> route, {
    TO? result,
  }) async {
    // Extract the widget from the MaterialPageRoute
    if (route is MaterialPageRoute<T>) {
      final widget = route.builder(context);
      final path = _getPathForWidget(widget);

      if (path != null) {
        context.go(path);
      } else {
        // Fallback: Use the old Navigator for unknown routes
        return Navigator.of(context).pushReplacement(route, result: result);
      }
    }
    return null;
  }

  /// Navigate to a named route
  ///
  /// Example:
  /// ```dart
  /// NavigationHelper.pushNamed(context, '/home');
  /// ```
  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    // Convert route name to path (remove leading slash if present)
    final path = routeName.startsWith('/') ? routeName : '/$routeName';

    if (arguments != null) {
      context.push(path, extra: arguments);
    } else {
      context.push(path);
    }

    return Future.value(null);
  }

  /// Replace current route with a named route
  ///
  /// Example:
  /// ```dart
  /// NavigationHelper.pushReplacementNamed(context, '/home');
  /// ```
  static Future<T?> pushReplacementNamed<T, TO>(
    BuildContext context,
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    // Convert route name to path
    final path = routeName.startsWith('/') ? routeName : '/$routeName';

    if (arguments != null) {
      context.go(path); // Note: go doesn't support extra in all cases
    } else {
      context.go(path);
    }

    return Future.value(null);
  }

  /// Pop the current screen from the navigation stack
  ///
  /// Example:
  /// ```dart
  /// NavigationHelper.pop(context);
  /// ```
  static void pop<T>(BuildContext context, [T? result]) {
    if (context.canPop()) {
      context.pop(result);
    }
  }

  /// Push named route and remove all previous routes
  ///
  /// Example:
  /// ```dart
  /// NavigationHelper.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  /// ```
  static Future<T?> pushNamedAndRemoveUntil<T>(
    BuildContext context,
    String routeName,
    bool Function(Route<dynamic>) predicate,
  ) {
    // Convert route name to path
    final path = routeName.startsWith('/') ? routeName : '/$routeName';

    // Use go which replaces the entire stack
    context.go(path);

    return Future.value(null);
  }

  /// Helper method to map widgets to their routes
  /// This is a simple implementation - you may need to expand this
  static String? _getPathForWidget(Widget widget) {
    final widgetType = widget.runtimeType.toString();

    // Map widget types to their routes
    // Add more mappings as needed
    final routeMap = {
      'LandingPage': '/landing_page',
      'HomeScreen': '/home',
      'LoginPage': '/login_page',
      'SignUp': '/sign_up',
      'PersonalData': '/personal_data',
      'ProfilePicture': '/profile_picture',
      'ResumeUpload': '/resume_upload',
      'MyJobsScreen': '/job',
      'ProfileUpdateSuccessPage': '/success',
      'DeleteAccount': '/delete_account',
      'UserPrivacyPolicy': '/user_privacy_policy',
      'UserTermsAndCondition': '/user_terms_and_conditions',
      'UserViewJobDetails': '/user_view_job_details',
      'UserNotification': '/user_notifications',

      // Organisation routes
      'OrganisationLogin': '/organisation_login',
      'OrganisationLandingPage': '/organisation_landing',
      'OrganisationSignUp': '/organisation_sing_up',
      'OrganisationOtpPage': '/organisation_otp',
      'OrgPhoneNumber': '/org_phone_number',
      'AboutOrganisation': '/about_organisation',
      'OrganisationSignUpLoading': '/organisation_signUpLoading',
      'OrganisationHome': '/organisation_home',
      'OrganisationViewJobDetails': '/organisation_view_job_details',
      'OrganisationViewProfile': '/organisation_view_profile',
      'EditJobOrganisation': '/organisation_edit_job',
      'OrganisationProfileEdit': '/organisation_edit_profile',
      'OrganisationProfileSettings': '/organisation_profile_settings',
      'OrganisationDeleteAccount': '/organisation_delete_account',
      'OrganisationTermsAndCondition': '/organisation_terms_and_conditions',
      'OrganisationDeleteOtpPage': '/organisation_delete_otp',
      'OrganisationNotificationPage': '/organisation_notifications',

      // Auth & Loading screens
      'LoginLoading': '/login_page_loading',
      'SignUpLoading': '/sign_up_loading',
      'LogOutLoading': '/logOut_loading',

      // Doctor routes
      'DrAcademicStatus': '/dr_acd_status',
      'DrDegreeOngoing1': '/dr_degree_ongoing_1',
      'SelectingDrSpeciality': '/dr_pg_holder_speciality',
      'WorkExperience': '/work_experience',
      'CertificateOfSpecialisation': '/dr_certification_of_spl',

      // Nurse routes
      'NurseAcademicStatus': '/nurse_academic_status',
      'SelectingNurseSpeciality': '/nurse_pg_holder_speciality',
      'NurseWorkExperience': '/nurse_work_experience',
      'NurseDegreeOngoing': '/nurse_degree_ongoing',
      'GnNurseDiplomaAcademicStatus': '/gn_nurse_academic_status',
      'GeneralNurseInternshipCompleted': '/gn_nurse_internship_completed',
      'GnNurseDiplomaOngoing': '/gn_nurse_diploma_ongoing',
      'AnmNurseDiplomaAcademicStatus': '/anm_nurse_diploma_status',
      'AnmNurseDiplomaOngoing': '/anm_nurse_diploma_ongoing',

      // Pharmacist routes
      'BPharmaAcademicStatus': '/pharmacist_academic_status_page',
      'BPharmDegreeOngoing': '/b-pharm_degree_ongoing',
      'PharmacistWorkExperience': '/pharmacist_work_experience',
      'PharmDAcademicStatus': '/pharm_d_academic_status',
      'PharmDDegreeOngoing': '/pharm_d_degree_ongoing',
      'DPharmDiplomaAcademicStatus': '/d_pharmd_diploma_academic_status',
      'DPharmDiplomaOngoing': '/d_pharm_degree_ongoing',

      // Lab Technician routes
      'BScMLTAcademicStatus': '/bsc_mlt_academic_status',
      'DMLTAcademicStatus': '/dmlt_academic_status',
      'BScMLTDegreeOngoing': '/bsc_mlt_degree_ongoing',
      'DMLTDiplomaOngoing': '/dmlt_diploma_ongoing',

      // Anaesthesia Technician routes
      'BScAnaesthesiaTechAcademicStatus': '/bsc_at_academic_status',
      'DiplomaAnaesthesiaTechAcademicStatus': '/dat_academic_status',
      'BScAnaesthesiaTechDegreeOngoing': '/bsc_at_degree_ongoing',
      'DiplomaAnaesthesiaTechOngoing': '/dat_diploma_ongoing',

      // Dentist routes
      'DentistAcademicStatus': '/dentist_academic_status',
      'DentistDegreeOngoing': '/dentist_degree_ongoing',

      // Physiotherapy routes
      'BScPhysiotherapyAcademicStatus': '/bpt_academic_status',
      'DiplomaPhysiotherapyAcademicStatus': '/dpt_academic_status',
      'BScPhysiotherapyDegreeOngoing': '/bpt_degree_ongoing',
      'DiplomaPhysiotherapyOngoing': '/dpt_diploma_ongoing',

      // Audiologist routes
      'BScAudiologyAcademicStatus': '/bsc_audiology_academic_status',
      'DiplomaAudiologyAcademicStatus': '/diploma_audiology_academic_status',
      'BScAudiologyDegreeOngoing': '/bsc_audiology_degree_ongoing',
      'DiplomaAudiologyOngoing': '/diploma_audiology_diploma_ongoing',

      // Dietitian routes
      'BScDieteticsAcademicStatus': '/bsc_dietetics_academic_status',
      'DiplomaDieteticsAcademicStatus': '/diploma_dietetics_academic_status',
      'BScDieteticsDegreeOngoing': '/bsc_dietetics_degree_ongoing',
      'DiplomaDieteticsTechOngoing': '/diploma_dietetics_diploma_ongoing',

      // Clinical Psychologist routes
      'BScPsychologyStatus': '/bsc_psychology_academic_status',
      'DiplomaPsychologyAcademicStatus': '/diploma_psychology_academic_status',
      'BScPsycologyDegreeOngoing': '/bsc_psychology_degree_ongoing',
      'DiplomaPsychologyOngoing': '/diploma_psychology_diploma_ongoing',

      // Social Worker routes
      'BSWAcademicStatus': '/bsw_academic_status',
      'DiplomaSocialWorkAcademicStatus': '/diploma_social_worker_academic_status',
      'BSWDegreeOngoing': '/bsw_degree_ongoing',
      'DiplomaSocialWorkOngoing': '/diploma_social_worker_diploma_ongoing',

      // Hospital Administrator routes
      'BHAdministratorAcademicStatus': '/bha_academic_status',
      'DiplomaHospitalAdministratorAcademicStatus': '/diploma_hospital_administrator_academic_status',
      'BHAdministratorDegreeOngoing': '/bha_degree_ongoing',
      'DiplomaHospitalAdministratorOngoing': '/diploma_hospital_administrator_diploma_ongoing',

      // Country Preference routes
      'CountryThatYouPreferred': '/County_that_you_preferred_page',
      'AfterCountryPreferredPage': '/after_County_preferred_page',
    };

    return routeMap[widgetType];
  }
}
