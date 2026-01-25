import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/job_details/presentation/screens/job_details_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/signup_completion_screen.dart';
import '../../features/profile/presentation/screens/personal_data_screen.dart';
import '../../features/profile/presentation/screens/resume_upload_screen.dart';
import 'route_names.dart';
import 'route_transitions.dart';
// import 'guards/auth_guard.dart';
import '../../shared/services/storage/local_storage_service.dart';

// Import old screens - Splash & Onboarding
import '../../../screens/onboarding.dart';

// Import old screens - User Pages
import '../../../screens/landing_page.dart';
import '../../../screens/login_page/home_screen.dart';
import '../../../screens/login_page/my_jobs_screen.dart';
import '../../../screens/signupPages/profile_update_success_page.dart';
import '../../../screens/login_page/delete_account.dart';
import '../../../screens/login_page/user_privacy_policy.dart';
import '../../../screens/login_page/user_terms_and_condition.dart';
import '../../../screens/login_page/user_view_job_details.dart';
import '../../../screens/login_page/user_notification.dart';

// Import old screens - Organisation Pages
import '../../../screens/organisation/organisation_login.dart';
import '../../../screens/organisation/organisation_landing.dart';
import '../../../screens/organisation/organisation_sign_up.dart';
import '../../../screens/organisation/organisation_otp_page.dart';
import '../../../screens/organisation/org_phone_number.dart';
import '../../../screens/organisation/about_organisation.dart';
import '../../../screens/organisation/organisation_sign_up_loading.dart';
import '../../../screens/organisation/organisation_home.dart';
import '../../../screens/organisation/organisation_view_job_details.dart';
import '../../../screens/organisation/organisation_view_profile.dart';
import '../../../screens/organisation/edit_job_organisation.dart';
import '../../../screens/organisation/organisation_profile_edit.dart';
import '../../../screens/organisation/organisation_profile_settings.dart';
import '../../../screens/organisation/organisation_delete_account.dart';
import '../../../screens/organisation/organisation_terms_and_conditions.dart';
import '../../../screens/organisation/organisation_delete_otp_page.dart';
import '../../../screens/organisation/organisation_notifications.dart';

// Import old screens - Auth & Signup Pages
import '../../../screens/login_page/login_page.dart';
import '../../../screens/login_page/login_page_loading.dart';
import '../../../screens/signupPages/sign_up.dart';
import '../../../screens/login_page/sign_up_loading.dart';
import '../../../screens/login_page/log_out_loading.dart';
// import '../../../screens/signupPages/personal_data.dart'; // Migrated to V2
import '../../../screens/signupPages/profile_picture.dart';
// import '../../../screens/signupPages/resume_upload.dart'; // Migrated to V2

// Import old screens - Doctor Pages
import '../../../screens/Doctor/dr_academic_status.dart';
import '../../../screens/Doctor/doctor_degree_ongoing/dr_degree_ongoing_1.dart';
import '../../../screens/Doctor/doctor_degree_completed/doctor_pg-holder/dr_pg_holder_speciality.dart';
import '../../../screens/Doctor/doctor_work_experience/work_experience.dart';
import '../../../screens/Doctor/doctor_work_experience/certificate_specialisation.dart';

// Import old screens - Nurse Pages
import '../../../screens/Nurse/nurse_academic_status.dart';
import '../../../screens/Nurse/nurse_degree_completed/nurse_pg_holder_speciality.dart';
import '../../../screens/Nurse/nurse_work_experience/nurse_work_experience.dart';
import '../../../screens/Nurse/nurse_degree_ongoing/nurse_degree_ongoing.dart';
import '../../../screens/Nurse/gnm_nurse_diploma_acc_status.dart';
import '../../../screens/Nurse/nurse_diploma_completed/general_nurse_internship_completed.dart';
import '../../../screens/Nurse/nurse_diploma_ongoing/gn_nurse_diploma_ongoing.dart';
import '../../../screens/Nurse/anm_nurse_diploma_status.dart';
import '../../../screens/Nurse/nurse_diploma_ongoing/anm_nurse_diploma_ongoing.dart';

// Import old screens - Pharmacist Pages
import '../../../screens/Pharmacist/b_pharm_academic_status.dart';
import '../../../screens/Pharmacist/b_pharm_degree_ongoing.dart';
import '../../../screens/Pharmacist/pharmacist_work_experience.dart';
import '../../../screens/Pharmacist/pharm_d_academic_status.dart';
import '../../../screens/Pharmacist/pharm_d_degree_ongoing.dart';
import '../../../screens/Pharmacist/d_pharm_academic_status.dart';
import '../../../screens/Pharmacist/d_pharm_diploma_ongoing.dart';

// Import old screens - Lab Technician Pages
import '../../../screens/Lab Techinician/bsc_mlt_academic_status.dart';
import '../../../screens/Lab Techinician/dmlt_academic_status.dart';
import '../../../screens/Lab Techinician/bsc_mlt_degree_ongoing.dart';
import '../../../screens/Lab Techinician/dmlt_diploma_ongoing.dart';

// Import old screens - Anaesthesia Technician Pages
import '../../../screens/Anaesthesia technician/bsc_anaesthesia_tech_academic_status.dart';
import '../../../screens/Anaesthesia technician/diploma_anaesthesia_academic_status.dart';
import '../../../screens/Anaesthesia technician/bsc_anaesthesia_tech_degree_ongoing.dart';
import '../../../screens/Anaesthesia technician/diploma_anaesthesia_ongoing.dart';

// Import old screens - Dentist Pages
import '../../../screens/Dentist/dentist_academic_status.dart';
import '../../../screens/Dentist/dentist_degree_ongoing.dart';

// Import old screens - Physiotherapy Pages
import '../../../screens/Physiotherapy/bsc_physiotherapy_academic_status.dart';
import '../../../screens/Physiotherapy/diploma_physiotherapy_academic_status.dart';
import '../../../screens/Physiotherapy/bsc_physiotherapy_degree_ongoing.dart';
import '../../../screens/Physiotherapy/diploma_physiotherapy_ongoing.dart';

// Import old screens - Audiologist Pages
import '../../../screens/Audiologist/bsc_audiology_academic_status.dart';
import '../../../screens/Audiologist/diploma_audiology_academic_status.dart';
import '../../../screens/Audiologist/bsc_audiology_degree_ongoing.dart';
import '../../../screens/Audiologist/diploma_audiology_ongoing.dart';

// Import old screens - Dietitian Pages
import '../../../screens/Dietitian/bsc_dietetics_academic_status.dart';
import '../../../screens/Dietitian/diploma_dietetics_academic_status.dart';
import '../../../screens/Dietitian/bsc_dietetics_degree_ongoing.dart';
import '../../../screens/Dietitian/diploma_dietetics_ongoing.dart';

// Import old screens - Clinical Psychologist Pages
import '../../../screens/Clinical Psychologist/bsc_clinical_psychologist_academic_status.dart';
import '../../../screens/Clinical Psychologist/diploma_clinical_psychologist_academic_status.dart';
import '../../../screens/Clinical Psychologist/bsc_clinical_psychologist_degree_ongoing.dart';
import '../../../screens/Clinical Psychologist/diploma_clinical_psychologist_ongoing.dart';

// Import old screens - Social Worker Pages
import '../../../screens/Social Worker/bsw_academic_status.dart';
import '../../../screens/Social Worker/diploma_social_work_academic_status.dart';
import '../../../screens/Social Worker/bsw_degree_ongoing.dart';
import '../../../screens/Social Worker/diploma_social_work_ongoing.dart';

// Import old screens - Hospital Administrator Pages
import '../../../screens/Hospital Administrator/b_hospital_administrator_academic_status.dart';
import '../../../screens/Hospital Administrator/diploma_hospital_administrator_academic_status.dart';
import '../../../screens/Hospital Administrator/b_hospital_administrator_degree_ongoing.dart';
import '../../../screens/Hospital Administrator/diploma_hospital_administrator_ongoing.dart';

// Import old screens - Country Preference Pages
import '../../../screens/country_preferred_pages/country_that_you_preferred.dart';
import '../../../screens/country_preferred_pages/after_country_preferred_page.dart';

// OLD - DEPRECATED: Commented out old profession selection import
// Use the new profession selection screen from dynamic forms instead
// import '../../../widgets/selection_of_professions.dart';

// Import Dynamic Forms
import '../../features/dynamic_forms/presentation/screens/profession_selection_screen.dart';
import '../../features/dynamic_forms/presentation/screens/dynamic_form_screen.dart';
import '../../features/dynamic_forms/presentation/screens/v2_dynamic_form_screen.dart';
import '../../features/dynamic_forms/presentation/screens/v2_flow_selection_screen.dart';

// Import V2 Home Feature
import '../../features/home/presentation/screens/home_shell_screen.dart';
import '../../features/home/presentation/screens/home_tab_screen.dart';
import '../../features/home/presentation/screens/jobs_tab_screen.dart';
import '../../features/home/presentation/screens/notifications_tab_screen.dart';
import '../../features/home/presentation/screens/profile_details_tab_screen.dart';
import '../../features/home/presentation/screens/settings_tab_screen.dart';
import '../../features/home/presentation/screens/job_search_screen.dart';
import '../../features/home/presentation/screens/job_filters_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  // static late AuthGuard _authGuard;
  static late GoRouter _router;

  /// Initialize the router with dependencies
  static void initialize(LocalStorageService storageService) {
    // _authGuard = AuthGuard(storageService);
    _router = _createRouter();
  }

  /// Get the router instance
  static GoRouter get router => _router;

  static GoRouter _createRouter() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: true,

      // Global redirect for authentication (disabled for old flow)
      // redirect: _authGuard.redirect,

      routes: [
        // ============ Splash & Onboarding (Old Flow) ============
        GoRoute(
          path: '/',
          name: 'splash',
          pageBuilder: (context, state) => RouteTransitions.fadeTransition(
            state: state,
            child: const OnboardingScreen(),
          ),
        ),

        // ============ Old User Pages ============
        GoRoute(
          path: '/landing_page',
          name: 'landing_page',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const LandingPage(),
          ),
        ),

        // ============ V2 Home with Bottom Navigation ============
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return HomeShellScreen(child: child);
          },
          routes: [
            GoRoute(
              path: RouteNames.home,
              name: 'home',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomeTabScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'search',
                  name: 'job_search',
                  pageBuilder: (context, state) =>
                      RouteTransitions.slideFromRight(
                    state: state,
                    child: const JobSearchScreen(),
                  ),
                ),
                GoRoute(
                  path: 'filters',
                  name: 'job_filters',
                  pageBuilder: (context, state) =>
                      RouteTransitions.slideFromBottom(
                    state: state,
                    child: const JobFiltersScreen(),
                  ),
                ),
              ],
            ),
            GoRoute(
              path: RouteNames.myJobs,
              name: 'my_jobs',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: JobsTabScreen(),
              ),
            ),
            GoRoute(
              path: RouteNames.notifications,
              name: 'notifications',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: NotificationsTabScreen(),
              ),
            ),
            GoRoute(
              path: RouteNames.profile,
              name: 'profile',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfileDetailsTabScreen(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/job-details/:jobId',
          name: 'job_details',
          pageBuilder: (context, state) {
            final jobId = state.pathParameters['jobId']!;
            return RouteTransitions.slideFromRight(
              state: state,
              child: JobDetailsScreen(jobId: jobId),
            );
          },
        ),

        // Settings Screen (accessible from profile)
        GoRoute(
          path: RouteNames.settings,
          name: 'settings',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const SettingsTabScreen(),
          ),
        ),

        // Resume Upload Screen (accessible from profile)
        GoRoute(
          path: RouteNames.profileResume,
          name: 'profileResume',
          pageBuilder: (context, state) {
            final flow = state.uri.queryParameters['flow'];
            return RouteTransitions.slideFromRight(
              state: state,
              child: ResumeUploadScreen(flowContext: flow),
            );
          },
        ),

        // ============ Old Home Screen (Deprecated) ============
        GoRoute(
          path: '/home-old',
          name: 'home_old',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/job',
          name: 'job',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const MyJobsScreen(),
          ),
        ),
        GoRoute(
          path: '/success',
          name: 'success',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const ProfileUpdateSuccessPage(),
          ),
        ),
        GoRoute(
          path: '/delete_account',
          name: 'delete_account',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DeleteAccount(),
          ),
        ),
        GoRoute(
          path: '/user_privacy_policy',
          name: 'user_privacy_policy',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const UserPrivacyPolicy(),
          ),
        ),
        GoRoute(
          path: '/user_terms_and_conditions',
          name: 'user_terms_and_conditions',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const UserTermsAndCondition(),
          ),
        ),
        GoRoute(
          path: '/user_view_job_details',
          name: 'user_view_job_details',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: UserViewJobDetails(jobId: 'dummy-job-id'),
          ),
        ),
        GoRoute(
          path: '/user_notifications',
          name: 'user_notifications',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const UserNotification(),
          ),
        ),

        // ============ Old Organisation Pages ============
        GoRoute(
          path: '/organisation_login',
          name: 'organisation_login',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const OrganisationLogin(),
          ),
        ),
        GoRoute(
          path: '/organisation_landing',
          name: 'organisation_landing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const OrganisationLandingPage(),
          ),
        ),
        GoRoute(
          path: '/organisation_sing_up',
          name: 'organisation_sing_up',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const OrganisationSignUp(),
          ),
        ),
        GoRoute(
          path: '/organisation_otp',
          name: 'organisation_otp',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const OrganisationOtpPage(),
          ),
        ),
        GoRoute(
          path: '/org_phone_number',
          name: 'org_phone_number',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const OrgPhoneNumber(),
          ),
        ),
        GoRoute(
          path: '/about_organisation',
          name: 'about_organisation',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const AboutOrganisation(),
          ),
        ),
        GoRoute(
          path: '/organisation_signUpLoading',
          name: 'organisation_signUpLoading',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const OrganisationSignUpLoading(),
          ),
        ),
        GoRoute(
          path: '/organisation_home',
          name: 'organisation_home',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const OrganisationHome(),
          ),
        ),
        GoRoute(
          path: '/organisation_view_job_details',
          name: 'organisation_view_job_details',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const OrganisationViewJobDetails(),
          ),
        ),
        GoRoute(
          path: '/organisation_view_profile',
          name: 'organisation_view_profile',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const OrganisationViewProfile(),
          ),
        ),
        GoRoute(
          path: '/organisation_edit_job',
          name: 'organisation_edit_job',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const EditJobOrganisation(),
          ),
        ),
        GoRoute(
          path: '/organisation_edit_profile',
          name: 'organisation_edit_profile',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const OrganisationProfileEdit(),
          ),
        ),
        GoRoute(
          path: '/organisation_profile_settings',
          name: 'organisation_profile_settings',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const OrganisationProfileSettings(),
          ),
        ),
        GoRoute(
          path: '/organisation_delete_account',
          name: 'organisation_delete_account',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const OrganisationDeleteAccount(),
          ),
        ),
        GoRoute(
          path: '/organisation_terms_and_conditions',
          name: 'organisation_terms_and_conditions',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const OrganisationTermsAndCondition(),
          ),
        ),
        GoRoute(
          path: '/organisation_privacy_policy',
          name: 'organisation_privacy_policy',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const OrganisationTermsAndCondition(),
          ),
        ),
        GoRoute(
          path: '/organisation_delete_otp',
          name: 'organisation_delete_otp',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const OrganisationDeleteOtpPage(),
          ),
        ),
        GoRoute(
          path: '/organisation_notifications',
          name: 'organisation_notifications',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const OrganisationNotificationPage(),
          ),
        ),

        // ============ Old Auth & Signup Pages ============
        GoRoute(
          path: '/login_page',
          name: 'login_page',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: '/login_page_loading',
          name: 'login_page_loading',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const LoginLoading(),
          ),
        ),
        GoRoute(
          path: '/sign_up',
          name: 'sign_up',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const SignupScreen(),
          ),
        ),
        GoRoute(
          path: '/sign_up_loading',
          name: 'sign_up_loading',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const SignUpLoading(),
          ),
        ),
        GoRoute(
          path: '/logOut_loading',
          name: 'logOut_loading',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const LogOutLoading(),
          ),
        ),
        GoRoute(
          path: '/personal_data',
          name: 'personal_data',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const PersonalDataScreen(),
          ),
        ),
        GoRoute(
          path: '/profile_picture',
          name: 'profile_picture',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const ProfilePicture(),
          ),
        ),
        GoRoute(
          path: '/resume_upload',
          name: 'resume_upload',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const ResumeUploadScreen(),
          ),
        ),
        // OLD - DEPRECATED: Old profession selection route (removed)
        // Use '/profession-selection' instead
        /*
        GoRoute(
          path: '/selection_profession',
          name: 'selection_profession',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const SelectionProfession(),
          ),
        ),
        */

        // ============ Dynamic Forms ============
        GoRoute(
          path: '/profession-selection',
          name: 'profession_selection',
          pageBuilder: (context, state) {
            final flow = state.uri.queryParameters['flow'];
            return RouteTransitions.slideFromRight(
              state: state,
              child: ProfessionSelectionScreen(flowContext: flow),
            );
          },
        ),
        GoRoute(
          path: '/dynamic-form/:professionId',
          name: 'dynamic_form',
          pageBuilder: (context, state) {
            final professionId = state.pathParameters['professionId']!;
            final courseType = state.uri.queryParameters['courseType'];
            final flow = state.uri.queryParameters['flow'];

            return RouteTransitions.slideFromRight(
              state: state,
              child: DynamicFormScreen(
                professionId: professionId,
                courseType: courseType,
                flowContext: flow,
              ),
            );
          },
        ),
        // V2 Flow Selection (B.Pharm, M.Pharm, etc.)
        GoRoute(
          path: '/v2-flow-selection/:professionId',
          name: 'v2_flow_selection',
          pageBuilder: (context, state) {
            final professionId = state.pathParameters['professionId']!;
            final flow = state.uri.queryParameters['flow'];

            return RouteTransitions.slideFromRight(
              state: state,
              child: V2FlowSelectionScreen(
                professionId: professionId,
                flowContext: flow,
              ),
            );
          },
        ),
        // V2 Dynamic Form (graph-based navigation)
        GoRoute(
          path: '/v2-dynamic-form/:professionId',
          name: 'v2_dynamic_form',
          pageBuilder: (context, state) {
            final professionId = state.pathParameters['professionId']!;
            final courseType = state.uri.queryParameters['courseType'];
            final flow = state.uri.queryParameters['flow'];

            return RouteTransitions.slideFromRight(
              state: state,
              child: V2DynamicFormScreen(
                professionId: professionId,
                courseType: courseType,
                flowContext: flow,
              ),
            );
          },
        ),

        // ============ Signup Completion ============
        GoRoute(
          path: '/signup-completion',
          name: 'signup_completion',
          pageBuilder: (context, state) => RouteTransitions.fadeTransition(
            state: state,
            child: const SignupCompletionScreen(),
          ),
        ),

        // ============ Doctor Pages ============
        GoRoute(
          path: '/dr_acd_status',
          name: 'dr_acd_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DrAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/dr_degree_ongoing_1',
          name: 'dr_degree_ongoing_1',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DrDegreeOngoing1(),
          ),
        ),
        GoRoute(
          path: '/dr_pg_holder_speciality',
          name: 'dr_pg_holder_speciality',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const SelectingDrSpeciality(),
          ),
        ),
        GoRoute(
          path: '/work_experience',
          name: 'work_experience',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const WorkExperience(),
          ),
        ),
        GoRoute(
          path: '/dr_certification_of_spl',
          name: 'dr_certification_of_spl',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const CertificateOfSpecialisation(),
          ),
        ),

        // ============ Nurse Pages ============
        GoRoute(
          path: '/nurse_academic_status',
          name: 'nurse_academic_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const NurseAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/nurse_pg_holder_speciality',
          name: 'nurse_pg_holder_speciality',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const SelectingNurseSpeciality(),
          ),
        ),
        GoRoute(
          path: '/nurse_work_experience',
          name: 'nurse_work_experience',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const NurseWorkExperience(),
          ),
        ),
        GoRoute(
          path: '/nurse_degree_ongoing',
          name: 'nurse_degree_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const NurseDegreeOngoing(),
          ),
        ),
        GoRoute(
          path: '/gn_nurse_academic_status',
          name: 'gn_nurse_academic_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const GnNurseDiplomaAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/gn_nurse_internship_completed',
          name: 'gn_nurse_internship_completed',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const GeneralNurseInternshipCompleted(),
          ),
        ),
        GoRoute(
          path: '/gn_nurse_diploma_ongoing',
          name: 'gn_nurse_diploma_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const GnNurseDiplomaOngoing(),
          ),
        ),
        GoRoute(
          path: '/anm_nurse_diploma_status',
          name: 'anm_nurse_diploma_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const AnmNurseDiplomaAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/anm_nurse_diploma_ongoing',
          name: 'anm_nurse_diploma_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const AnmNurseDiplomaOngoing(),
          ),
        ),

        // ============ Pharmacist Pages ============
        GoRoute(
          path: '/pharmacist_academic_status_page',
          name: 'pharmacist_academic_status_page',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const BPharmaAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/b-pharm_degree_ongoing',
          name: 'b-pharm_degree_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const BPharmDegreeOngoing(),
          ),
        ),
        GoRoute(
          path: '/pharmacist_work_experience',
          name: 'pharmacist_work_experience',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const PharmacistWorkExperience(),
          ),
        ),
        GoRoute(
          path: '/pharm_d_academic_status',
          name: 'pharm_d_academic_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const PharmDAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/pharm_d_degree_ongoing',
          name: 'pharm_d_degree_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const PharmDDegreeOngoing(),
          ),
        ),
        GoRoute(
          path: '/d_pharmd_diploma_academic_status',
          name: 'd_pharmd_diploma_academic_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DPharmDiplomaAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/d_pharm_degree_ongoing',
          name: 'd_pharm_degree_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DPharmDiplomaOngoing(),
          ),
        ),

        // ============ Lab Technician Pages ============
        GoRoute(
          path: '/bsc_mlt_academic_status',
          name: 'bsc_mlt_academic_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const BScMLTAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/dmlt_academic_status',
          name: 'dmlt_academic_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DMLTAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/bsc_mlt_degree_ongoing',
          name: 'bsc_mlt_degree_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const BScMLTDegreeOngoing(),
          ),
        ),
        GoRoute(
          path: '/dmlt_diploma_ongoing',
          name: 'dmlt_diploma_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DMLTDiplomaOngoing(),
          ),
        ),

        // ============ Anaesthesia Technician Pages ============
        GoRoute(
          path: '/bsc_at_academic_status',
          name: 'bsc_at_academic_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const BScAnaesthesiaTechAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/dat_academic_status',
          name: 'dat_academic_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DiplomaAnaesthesiaTechAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/bsc_at_degree_ongoing',
          name: 'bsc_at_degree_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const BScAnaesthesiaTechDegreeOngoing(),
          ),
        ),
        GoRoute(
          path: '/dat_diploma_ongoing',
          name: 'dat_diploma_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DiplomaAnaesthesiaTechOngoing(),
          ),
        ),

        // ============ Dentist Pages ============
        GoRoute(
          path: '/dentist_academic_status',
          name: 'dentist_academic_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DentistAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/dentist_degree_ongoing',
          name: 'dentist_degree_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DentistDegreeOngoing(),
          ),
        ),

        // ============ Physiotherapy Pages ============
        GoRoute(
          path: '/bpt_academic_status',
          name: 'bpt_academic_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const BScPhysiotherapyAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/dpt_academic_status',
          name: 'dpt_academic_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DiplomaPhysiotherapyAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/bpt_degree_ongoing',
          name: 'bpt_degree_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const BScPhysiotherapyDegreeOngoing(),
          ),
        ),
        GoRoute(
          path: '/dpt_diploma_ongoing',
          name: 'dpt_diploma_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DiplomaPhysiotherapyOngoing(),
          ),
        ),

        // ============ Audiologist Pages ============
        GoRoute(
          path: '/bsc_audiology_academic_status',
          name: 'bsc_audiology_academic_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const BScAudiologyAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/diploma_audiology_academic_status',
          name: 'diploma_audiology_academic_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DiplomaAudiologyAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/bsc_audiology_degree_ongoing',
          name: 'bsc_audiology_degree_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const BScAudiologyDegreeOngoing(),
          ),
        ),
        GoRoute(
          path: '/diploma_audiology_diploma_ongoing',
          name: 'diploma_audiology_diploma_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DiplomaAudiologyOngoing(),
          ),
        ),

        // ============ Dietitian Pages ============
        GoRoute(
          path: '/bsc_dietetics_academic_status',
          name: 'bsc_dietetics_academic_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const BScDieteticsAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/diploma_dietetics_academic_status',
          name: 'diploma_dietetics_academic_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DiplomaDieteticsAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/bsc_dietetics_degree_ongoing',
          name: 'bsc_dietetics_degree_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const BScDieteticsDegreeOngoing(),
          ),
        ),
        GoRoute(
          path: '/diploma_dietetics_diploma_ongoing',
          name: 'diploma_dietetics_diploma_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DiplomaDieteticsTechOngoing(),
          ),
        ),

        // ============ Clinical Psychologist Pages ============
        GoRoute(
          path: '/bsc_psychology_academic_status',
          name: 'bsc_psychology_academic_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const BScPsychologyStatus(),
          ),
        ),
        GoRoute(
          path: '/diploma_psychology_academic_status',
          name: 'diploma_psychology_academic_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DiplomaPsychologyAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/bsc_psychology_degree_ongoing',
          name: 'bsc_psychology_degree_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const BScPsycologyDegreeOngoing(),
          ),
        ),
        GoRoute(
          path: '/diploma_psychology_diploma_ongoing',
          name: 'diploma_psychology_diploma_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DiplomaPsychologyOngoing(),
          ),
        ),

        // ============ Social Worker Pages ============
        GoRoute(
          path: '/bsw_academic_status',
          name: 'bsw_academic_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const BSWAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/diploma_social_worker_academic_status',
          name: 'diploma_social_worker_academic_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DiplomaSocialWorkAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/bsw_degree_ongoing',
          name: 'bsw_degree_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const BSWDegreeOngoing(),
          ),
        ),
        GoRoute(
          path: '/diploma_social_worker_diploma_ongoing',
          name: 'diploma_social_worker_diploma_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DiplomaSocialWorkOngoing(),
          ),
        ),

        // ============ Hospital Administrator Pages ============
        GoRoute(
          path: '/bha_academic_status',
          name: 'bha_academic_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const BHAdministratorAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/diploma_hospital_administrator_academic_status',
          name: 'diploma_hospital_administrator_academic_status',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DiplomaHospitalAdministratorAcademicStatus(),
          ),
        ),
        GoRoute(
          path: '/bha_degree_ongoing',
          name: 'bha_degree_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const BHAdministratorDegreeOngoing(),
          ),
        ),
        GoRoute(
          path: '/diploma_hospital_administrator_diploma_ongoing',
          name: 'diploma_hospital_administrator_diploma_ongoing',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const DiplomaHospitalAdministratorOngoing(),
          ),
        ),

        // ============ Country Preference Pages ============
        GoRoute(
          path: '/County_that_you_preferred_page',
          name: 'County_that_you_preferred_page',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const CountryThatYouPreferred(),
          ),
        ),
        GoRoute(
          path: '/after_County_preferred_page',
          name: 'after_County_preferred_page',
          pageBuilder: (context, state) => RouteTransitions.slideFromRight(
            state: state,
            child: const AfterCountryPreferredPage(),
          ),
        ),
      ],

      // Error page
      errorPageBuilder: (context, state) => MaterialPage(
        child: ErrorPage(error: state.error?.toString() ?? 'Page not found'),
      ),
    );
  }
}

// ============ Error Page ============
class ErrorPage extends StatelessWidget {
  final String error;

  const ErrorPage({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
