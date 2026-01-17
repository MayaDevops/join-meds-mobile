import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage/local_storage_service.dart';
import '../services/api/api_client.dart';
import '../services/api/form_api_service.dart';
import '../../core/theme/theme_provider.dart';
import 'auth_provider.dart';
import 'user_provider.dart';
import 'locale_provider.dart';
import 'otp_provider.dart';
import '../../features/dynamic_forms/domain/repositories/form_repository.dart';
import '../../features/dynamic_forms/data/repositories/form_repository_impl.dart';
import '../../features/dynamic_forms/data/datasources/firebase_form_datasource.dart';
import '../../features/dynamic_forms/data/datasources/local_form_datasource.dart';
import '../../features/dynamic_forms/presentation/providers/form_state_provider.dart';
import '../../features/dynamic_forms/domain/repositories/v2_form_repository.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/presentation/providers/home_provider.dart';
import '../../features/home/presentation/providers/navigation_provider.dart';
import '../../features/home/presentation/providers/jobs_tab_provider.dart';
import '../../features/home/presentation/providers/notifications_provider.dart';
import '../services/v2/repositories/interfaces/i_job_repo.dart';
import '../services/v2/repositories/implementations/job_repo.dart';

class AppProvider {
  static late LocalStorageService _storageService;
  static late ApiClient _apiClient;
  static late FormApiService _formApiService;
  static late FormRepository _formRepository;
  static late V2FormRepository _v2FormRepository;
  static late IHomeRepository _homeRepository;
  static late IJobRepo _jobRepo;
  static late SharedPreferences _prefs;

  // Expose services for direct access if needed
  static LocalStorageService get storageService => _storageService;
  static ApiClient get apiClient => _apiClient;
  static FormApiService get formApiService => _formApiService;
  static FormRepository get formRepository => _formRepository;
  static V2FormRepository get v2FormRepository => _v2FormRepository;
  static IHomeRepository get homeRepository => _homeRepository;
  static IJobRepo get jobRepo => _jobRepo;

  /// Initialize all services before app starts
  /// Call this in main() before runApp()
  static Future<void> initializeServices() async {
    // Initialize storage service
    _storageService = LocalStorageService();
    await _storageService.init();

    // Initialize SharedPreferences
    _prefs = await SharedPreferences.getInstance();

    // Initialize API client
    _apiClient = ApiClient();

    // Initialize Form API Service
    _formApiService = FormApiService();

    // Initialize Form Repository
    final firebaseDatasource = FirebaseFormDatasource();
    final localDatasource = LocalFormDatasource(_prefs);
    _formRepository = FormRepositoryImpl(
      firebaseDatasource: firebaseDatasource,
      localDatasource: localDatasource,
    );

    // Initialize V2 Form Repository
    _v2FormRepository = V2FormRepository();

    // Initialize Home Repository
    _homeRepository = HomeRepositoryImpl(_apiClient);

    // Initialize Job Repository
    _jobRepo = JobRepo(_apiClient);
  }

  /// All providers for MultiProvider
  /// Wrap your app with MultiProvider using these providers
  static List<SingleChildWidget> get providers => [
        // Services as Providers (for dependency injection)
        Provider<LocalStorageService>.value(value: _storageService),
        Provider<ApiClient>.value(value: _apiClient),
        Provider<FormApiService>.value(value: _formApiService),
        Provider<FormRepository>.value(value: _formRepository),
        Provider<V2FormRepository>.value(value: _v2FormRepository),
        Provider<IHomeRepository>.value(value: _homeRepository),
        Provider<IJobRepo>.value(value: _jobRepo),

        // Theme Provider
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(_storageService),
        ),

        // Locale Provider
        ChangeNotifierProvider<LocaleProvider>(
          create: (_) => LocaleProvider(_storageService),
        ),

        // Auth Provider
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(_storageService, _apiClient),
        ),

        // OTP Provider
        ChangeNotifierProvider<OtpProvider>(
          create: (_) => OtpProvider(),
        ),

        // User Provider (depends on Auth)
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (_) => UserProvider(_storageService, _apiClient),
          update: (_, authProvider, userProvider) {
            userProvider?.updateAuth(authProvider);
            return userProvider ?? UserProvider(_storageService, _apiClient);
          },
        ),

        // Dynamic Forms Provider
        ChangeNotifierProvider<FormStateProvider>(
          create: (_) => FormStateProvider(
            repository: _formRepository,
            apiService: _formApiService,
          ),
        ),

        // Navigation Provider (for bottom nav state)
        ChangeNotifierProvider<NavigationProvider>(
          create: (_) => NavigationProvider(),
        ),

        // Home Provider
        ChangeNotifierProxyProvider<UserProvider, HomeProvider>(
          create: (_) => HomeProvider(_homeRepository, _jobRepo,
              UserProvider(_storageService, _apiClient), _storageService),
          update: (_, userProvider, homeProvider) =>
              homeProvider ??
              HomeProvider(
                  _homeRepository, _jobRepo, userProvider, _storageService),
        ),

        // Jobs Tab Provider
        ChangeNotifierProvider<JobsTabProvider>(
          create: (_) => JobsTabProvider(_jobRepo),
        ),

        // Notifications Provider
        ChangeNotifierProvider<NotificationsProvider>(
          create: (_) => NotificationsProvider(),
        ),
      ];

  /// Dispose services (if needed)
  static void dispose() {
    // Add cleanup logic if needed
  }
}
