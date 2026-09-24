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
  //
  // GET /api/org-job/list has no page/size support (it ignores them and always
  // returns every job), so the full list is fetched once into [_allJobs] and
  // revealed [jobsPageSize] at a time as the user scrolls. When the backend
  // adds paging, only [loadMoreJobs] needs to change -- the UI contract
  // (recommendedJobs / hasMoreJobs / loadMoreJobs) stays the same.
  static const int jobsPageSize = 10;
  List<JobDetailsDTO> _allJobs = [];
  List<JobDetailsDTO> _recommendedJobs = [];
  int _visibleJobCount = 0;
  bool _isLoadingMoreJobs = false;
  bool _isLoadingJobs = false;
  bool _isLoadingSearchedJobs = false;
  String? _jobsError;
  String? _searchedJobsError;

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

  // Getters
  List<JobDetailsDTO> get recommendedJobs => _recommendedJobs;
  bool get hasMoreJobs => _visibleJobCount < _allJobs.length;
  bool get isLoadingMoreJobs => _isLoadingMoreJobs;
  int get totalJobCount => _allJobs.length;
  String? get searchQuery => _searchQuery;
  bool get isSearching => _isLoadingSearchedJobs;
  String? get searchError => _searchedJobsError;
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
      // No default limit: the previous `limit ?? 20` silently dropped every
      // job past the 20th, so newly posted jobs never appeared.
      final response = await _homeRepository.fetchRecommendedJobs(
        limit: limit,
      );

      if (response.success && response.data != null) {
        _allJobs = response.data!;
        _visibleJobCount = jobsPageSize.clamp(0, _allJobs.length);
        _syncVisibleJobs();
        _lastJobsFetch = DateTime.now();
        _jobsError = null;
        debugPrint(
          'HomeProvider: Fetched ${_allJobs.length} jobs, '
          'showing $_visibleJobCount',
        );
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
        debugPrint(
            'HomeProvider: Failed to bookmark job - ${response.message}');
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
        debugPrint(
            'HomeProvider: Failed to remove bookmark - ${response.message}');
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
        resumeId: resumeId, // Now using actual resumeId without .pdf extension!
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
        return response.message;
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
  /// Reveals the next page of jobs. Safe to call repeatedly from a scroll
  /// listener: it is a no-op while a load is running or when nothing is left.
  Future<void> loadMoreJobs() async {
    if (_isLoadingMoreJobs || _isLoadingJobs || !hasMoreJobs) return;

    _isLoadingMoreJobs = true;
    notifyListeners();

    try {
      _visibleJobCount =
          (_visibleJobCount + jobsPageSize).clamp(0, _allJobs.length);
      _syncVisibleJobs();
      debugPrint(
        'HomeProvider: Loaded more jobs, showing '
        '$_visibleJobCount of ${_allJobs.length}',
      );
    } finally {
      _isLoadingMoreJobs = false;
      notifyListeners();
    }
  }

  void _syncVisibleJobs() {
    _recommendedJobs = _allJobs.sublist(0, _visibleJobCount);
  }

  /// Pull-to-refresh. Forces a network fetch -- going through [initialize]
  /// hit the 5-minute cache, so newly posted jobs did not appear on refresh.
  Future<void> refreshHome() async {
    await fetchRecommendedJobs(forceRefresh: true);
  }

  /// Clear all errors
  void clearErrors() {
    _jobsError = null;
    _bannerError = null;
    notifyListeners();
  }

  /// Clear all data
  void clear() {
    _allJobs = [];
    _visibleJobCount = 0;
    _recommendedJobs = [];
    _searchQuery = null;
    _bookmarkedJobIds.clear();
    _appliedJobIds.clear();
    _applyingJobs.clear();
    _lastJobsFetch = null;
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

  List<JobDetailsDTO> searchedJobs = [];

  Future<void> searchJobs({String? searchKey}) async {
    final query = searchKey?.trim() ?? '';

    // Avoid unnecessary calls
    if (query.isEmpty) {
      searchedJobs = [];
      _searchedJobsError = null;
      notifyListeners();
      return;
    }

    if (_isLoadingSearchedJobs) return;

    _isLoadingSearchedJobs = true;
    _searchedJobsError = null;
    notifyListeners();

    try {
      final response = await _homeRepository.fetchJobsByKeyword(query);

      if (response.success && response.data != null) {
        searchedJobs = response.data!;
        _searchedJobsError = null;
      } else {
        searchedJobs = [];
        _searchedJobsError = response.message;
      }
    } on DioException catch (e) {
      searchedJobs = [];
      _searchedJobsError = e.message ?? 'Search failed';
      debugPrint('HomeProvider: Search error - $e');
    } catch (e) {
      searchedJobs = [];
      _searchedJobsError = 'Unexpected error occurred';
      debugPrint('HomeProvider: Unexpected search error - $e');
    } finally {
      _isLoadingSearchedJobs = false;
      notifyListeners();
    }
  }
}
