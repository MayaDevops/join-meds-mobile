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
  List<JobAppliedDTO> _filteredJobs = [];
  bool _isLoading = false;
  String? _error;
  String? _filterStatus; // 'all', 'pending', 'reviewed', 'accepted', 'rejected'
  DateTime? _lastFetchTime;

  /// All applied jobs
  List<JobAppliedDTO> get appliedJobs => _filteredJobs;

  /// Loading state
  bool get isLoading => _isLoading;

  /// Error message
  String? get error => _error;

  /// Current filter status
  String? get filterStatus => _filterStatus ?? 'all';

  /// Total applications count
  int get totalCount => _appliedJobs.length;

  /// Pending applications count
  int get pendingCount =>
      _appliedJobs.where((j) => j.status == 'pending').length;

  /// Accepted applications count
  int get acceptedCount =>
      _appliedJobs.where((j) => j.status == 'accepted').length;

  /// Rejected applications count
  int get rejectedCount =>
      _appliedJobs.where((j) => j.status == 'rejected').length;

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
        _applyFilter(); // Apply current filter
        _lastFetchTime = DateTime.now();
        _error = null;
      } else {
        _error = response.message;
        _appliedJobs = [];
        _filteredJobs = [];
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

  /// Filter jobs by status
  void filterByStatus(String? status) {
    _filterStatus = status;
    _applyFilter();
  }

  /// Apply the current filter
  void _applyFilter() {
    if (_filterStatus == null || _filterStatus == 'all') {
      _filteredJobs = List.from(_appliedJobs);
    } else {
      _filteredJobs = _appliedJobs
          .where((job) => job.status?.toLowerCase() == _filterStatus?.toLowerCase())
          .toList();
    }
    notifyListeners();
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
        _applyFilter(); // Apply current filter
        _error = null;
      } else {
        _error = response.message;
        _appliedJobs = [];
        _filteredJobs = [];
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
    _applyFilter();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear all data
  void clear() {
    _appliedJobs = [];
    _filteredJobs = [];
    _filterStatus = null;
    _lastFetchTime = null;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _appliedJobs.clear();
    _filteredJobs.clear();
    super.dispose();
  }
}
