import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../shared/services/v2/repositories/interfaces/i_job_repo.dart';
import '../../../../shared/models/v2/job/job_applied_dto.dart';
import '../../../../shared/models/v2/job/job_search_params.dart';

/// Provider for managing jobs tab state (applied jobs)
class JobsTabProvider extends ChangeNotifier {
  final IJobRepo _jobRepo;

  JobsTabProvider(this._jobRepo);

  List<JobAppliedDTO> _appliedJobs = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;

  /// All applied jobs
  List<JobAppliedDTO> get appliedJobs => _appliedJobs;

  /// Loading state
  bool get isLoading => _isLoading;

  /// Error message
  String? get error => _error;

  /// Total applications count
  int get totalCount => _appliedJobs.length;

  /// Fetch applied jobs for the user
  Future<void> fetchAppliedJobs(
    String userId, {
    bool forceRefresh = false,
  }) async {
    // Avoid fetching too frequently (cache for 2 minutes)
    if (!forceRefresh && _lastFetchTime != null) {
      final difference = DateTime.now().difference(_lastFetchTime!);
      if (difference.inMinutes < 2) {
        debugPrint('JobsTabProvider: Using cached applied jobs');
        return;
      }
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _jobRepo.fetchUserApplications(userId);

      if (response.success && response.data != null) {
        _appliedJobs = response.data!;
        _lastFetchTime = DateTime.now();
        _error = null;
      } else {
        _error = response.message;
        _appliedJobs = [];
      }
    } on DioException catch (e) {
      _error = e.message ?? 'Network error occurred';
      debugPrint('JobsTabProvider: Error fetching applied jobs - $e');
    } catch (e) {
      _error = 'An unexpected error occurred';
      debugPrint('JobsTabProvider: Unexpected error - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search applications with custom params
  Future<void> searchApplications(JobSearchParams params) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _jobRepo.searchApplications(params);

      if (response.success && response.data != null) {
        _appliedJobs = response.data!;
        _error = null;
      } else {
        _error = response.message;
        _appliedJobs = [];
      }
    } on DioException catch (e) {
      _error = e.message ?? 'Network error occurred';
      debugPrint('JobsTabProvider: Error searching applications - $e');
    } catch (e) {
      _error = 'An unexpected error occurred';
      debugPrint('JobsTabProvider: Unexpected error - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh jobs (force fetch)
  Future<void> refresh(String userId) async {
    await fetchAppliedJobs(userId, forceRefresh: true);
  }

  /// Add a newly applied job to the local list
  void addAppliedJob(JobAppliedDTO application) {
    _appliedJobs.insert(0, application); // Add at beginning
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear all data
  void clear() {
    _appliedJobs = [];
    _lastFetchTime = null;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _appliedJobs.clear();
    super.dispose();
  }
}
