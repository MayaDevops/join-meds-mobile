import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../../../shared/models/v2/job/job_details_dto.dart';
import '../../../../shared/models/v2/job/job_applied_dto.dart';
import '../../../../shared/services/v2/repositories/interfaces/i_job_repo.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../domain/repositories/home_repository.dart';
import '../../../../../api/personal_data_service.dart';
import '../../../../shared/services/storage/local_storage_service.dart';

/// Provider for managing home screen state
class HomeProvider extends ChangeNotifier {
  final IHomeRepository _homeRepository;
  final IJobRepo _jobRepo;
  final UserProvider _userProvider;
  final LocalStorageService _storageService;

  HomeProvider(
    this._homeRepository,
    this._jobRepo,
    this._userProvider,
    this._storageService,
  );

  // Recommended jobs
  List<JobDetailsDTO> _recommendedJobs = [];
  bool _isLoadingJobs = false;
  String? _jobsError;

  // Promotional banner
  bool _isLoadingBanner = false;
  String? _bannerError;

  // Search
  String? _searchQuery;

  // Bookmarks
  final Set<String> _bookmarkedJobIds = {};

  // Applied jobs
  final Set<String> _appliedJobIds = {};
  final Map<String, bool> _applyingJobs = {}; // Track loading state per job

  // Cache
  DateTime? _lastJobsFetch;
  DateTime? _lastBannerFetch;

  // Getters
  List<JobDetailsDTO> get recommendedJobs => _recommendedJobs;
  String? get searchQuery => _searchQuery;
  bool get isLoading => _isLoadingJobs || _isLoadingBanner;
  bool get isLoadingJobs => _isLoadingJobs;
  bool get isLoadingBanner => _isLoadingBanner;
  String? get error => _jobsError ?? _bannerError;

  /// Check if a job is bookmarked
  bool isJobBookmarked(String jobId) => _bookmarkedJobIds.contains(jobId);

  /// Check if a job is applied
  bool isJobApplied(String jobId) => _appliedJobIds.contains(jobId);

  /// Check if currently applying to a job
  bool isApplyingToJob(String jobId) => _applyingJobs[jobId] ?? false;

  /// Initialize home data (fetch all)
  Future<void> initialize() async {
    await fetchRecommendedJobs();
  }

  /// Fetch recommended jobs
  Future<void> fetchRecommendedJobs({
    int? limit,
    bool forceRefresh = false,
  }) async {
    // Avoid fetching too frequently (cache for 5 minutes)
    if (!forceRefresh && _lastJobsFetch != null) {
      final difference = DateTime.now().difference(_lastJobsFetch!);
      if (difference.inMinutes < 5) {
        debugPrint('HomeProvider: Using cached recommended jobs');
        return;
      }
    }

    _isLoadingJobs = true;
    _jobsError = null;
    notifyListeners();

    try {
      final response = await _homeRepository.fetchRecommendedJobs(
        limit: limit ?? 20,
      );

      if (response.success && response.data != null) {
        _recommendedJobs = response.data!;
        _lastJobsFetch = DateTime.now();
        _jobsError = null;
      } else {
        _jobsError = response.message;
      }
    } on DioException catch (e) {
      _jobsError = e.message ?? 'Failed to fetch recommended jobs';
      debugPrint('HomeProvider: Error fetching jobs - $e');
    } catch (e) {
      _jobsError = 'An unexpected error occurred';
      debugPrint('HomeProvider: Unexpected error fetching jobs - $e');
    } finally {
      _isLoadingJobs = false;
      notifyListeners();
    }
  }

  /// Bookmark a job
  Future<void> bookmarkJob(String jobId) async {
    // Optimistic update
    _bookmarkedJobIds.add(jobId);
    notifyListeners();

    try {
      final response = await _homeRepository.bookmarkJob(jobId);

      if (!response.success) {
        // Revert on failure
        _bookmarkedJobIds.remove(jobId);
        notifyListeners();
        debugPrint('HomeProvider: Failed to bookmark job - ${response.message}');
      }
    } on DioException catch (e) {
      // Revert on error
      _bookmarkedJobIds.remove(jobId);
      notifyListeners();
      debugPrint('HomeProvider: Error bookmarking job - $e');
    } catch (e) {
      // Revert on error
      _bookmarkedJobIds.remove(jobId);
      notifyListeners();
      debugPrint('HomeProvider: Unexpected error bookmarking job - $e');
    }
  }

  /// Remove bookmark
  Future<void> removeBookmark(String jobId) async {
    // Optimistic update
    _bookmarkedJobIds.remove(jobId);
    notifyListeners();

    try {
      final response = await _homeRepository.removeBookmark(jobId);

      if (!response.success) {
        // Revert on failure
        _bookmarkedJobIds.add(jobId);
        notifyListeners();
        debugPrint('HomeProvider: Failed to remove bookmark - ${response.message}');
      }
    } on DioException catch (e) {
      // Revert on error
      _bookmarkedJobIds.add(jobId);
      notifyListeners();
      debugPrint('HomeProvider: Error removing bookmark - $e');
    } catch (e) {
      // Revert on error
      _bookmarkedJobIds.add(jobId);
      notifyListeners();
      debugPrint('HomeProvider: Unexpected error removing bookmark - $e');
    }
  }

  /// Toggle bookmark state
  Future<void> toggleBookmark(String jobId) async {
    if (isJobBookmarked(jobId)) {
      await removeBookmark(jobId);
    } else {
      await bookmarkJob(jobId);
    }
  }

  /// Apply to a job - Fetches fresh user data from API
  Future<String?> applyToJob(JobDetailsDTO job) async {
    final jobId = job.id;
    if (jobId == null) {
      return 'Invalid job ID';
    }

    // Check if already applied
    if (isJobApplied(jobId)) {
      return 'Already applied to this job';
    }

    // Get userId from storage (using 'userId' key as set during login)
    final userId = _storageService.getString('userId');
    if (userId == null || userId.isEmpty) {
      return 'User ID not found. Please login again';
    }

    // Set loading state
    _applyingJobs[jobId] = true;
    notifyListeners();

    try {
      // Fetch fresh user profile data from API
      final personalData = await PersonalDataService.getPersonalData(userId);

      if (personalData == null) {
        return 'Could not load your profile. Please try again';
      }

      // Validate required fields
      if (personalData.fullname == null || personalData.fullname!.isEmpty) {
        return 'Please complete your profile before applying';
      }

      if (personalData.email == null || personalData.email!.isEmpty) {
        return 'Email is required. Please update your profile';
      }

      if (personalData.resumeId == null || personalData.resumeId!.isEmpty) {
        return 'Please upload your resume before applying';
      }

      // Remove .pdf extension from resumeId if present
      String resumeId = personalData.resumeId!;
      if (resumeId.toLowerCase().endsWith('.pdf')) {
        resumeId = resumeId.substring(0, resumeId.length - 4);
      }

      // Create application DTO with fresh data from API
      final application = JobAppliedDTO(
        userId: userId,
        orgId: job.orgId,
        jobId: jobId,
        fullname: personalData.fullname,
        email: personalData.email,
        emailMobile: personalData.email ?? personalData.emailOrPhone,
        resumeId: resumeId,  // Now using actual resumeId without .pdf extension!
        status: 'pending',
      );

      final response = await _jobRepo.applyToJob(application);

      if (response.success) {
        // Optimistic update - add to applied jobs
        _appliedJobIds.add(jobId);
        debugPrint('HomeProvider: Successfully applied to job $jobId');
        return null; // Success - no error message
      } else {
        debugPrint('HomeProvider: Failed to apply - ${response.message}');
        return response.message ?? 'Failed to apply to job';
      }
    } on DioException catch (e) {
      debugPrint('HomeProvider: Error applying to job - $e');
      return e.message ?? 'Network error occurred';
    } catch (e) {
      debugPrint('HomeProvider: Unexpected error applying to job - $e');
      return 'An unexpected error occurred';
    } finally {
      _applyingJobs[jobId] = false;
      notifyListeners();
    }
  }

  /// Set search query
  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clear search query
  void clearSearch() {
    _searchQuery = null;
    notifyListeners();
  }

  /// Refresh all home data
  Future<void> refreshHome() async {
    await initialize();
  }

  /// Clear all errors
  void clearErrors() {
    _jobsError = null;
    _bannerError = null;
    notifyListeners();
  }

  /// Clear all data
  void clear() {
    _recommendedJobs = [];
    _searchQuery = null;
    _bookmarkedJobIds.clear();
    _appliedJobIds.clear();
    _applyingJobs.clear();
    _lastJobsFetch = null;
    _lastBannerFetch = null;
    clearErrors();
  }

  @override
  void dispose() {
    _recommendedJobs.clear();
    _bookmarkedJobIds.clear();
    _appliedJobIds.clear();
    _applyingJobs.clear();
    super.dispose();
  }
}
