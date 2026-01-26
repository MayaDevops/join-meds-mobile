import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/models/v2/job/job_details_dto.dart';
import '../../domain/repository/jon_details_repository.dart';

/// Provider for managing job details screen state
class JobDetailsProvider extends ChangeNotifier {
  final IJobDetailsRepository _jobDetailsRepository;

  JobDetailsProvider(this._jobDetailsRepository);


  // Job details
  JobDetailsDTO? _jobDetails;
  bool _isLoading = false;
  String? _error;

  // Cache
  String? _lastJobId;
  DateTime? _lastFetchTime;

  // Getters
  JobDetailsDTO? get jobDetails => _jobDetails;
  bool get isLoading => _isLoading;
  String? get error => _error;
  // Apply job state
  bool _isApplying = false;
  String? _applyError;

  bool get isApplying => _isApplying;
  String? get applyError => _applyError;

  /// Fetch job details by job ID
  Future<void> fetchJobDetails(
      String jobId, {
        bool forceRefresh = false,
      }) async {
    // Avoid refetching same job within 2 minutes
    if (!forceRefresh &&
        _lastJobId == jobId &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inMinutes < 2) {
      debugPrint('JobDetailsProvider: Using cached job details');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _jobDetailsRepository.fetchJobDetails(jobId);

      if (response.success && response.data != null) {
        _jobDetails = response.data;
        _lastJobId = jobId;
        _lastFetchTime = DateTime.now();
        _error = null;
      } else {
        _error = response.message ;
      }
    } on DioException catch (e) {
      _error = e.message ?? 'Network error occurred';
      debugPrint('JobDetailsProvider: Dio error - $e');
    } catch (e) {
      _error = 'An unexpected error occurred';
      debugPrint('JobDetailsProvider: Unexpected error - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyForJob({CancelToken? cancelToken}) async {
    if (_jobDetails == null) {
      _applyError = 'Job details not loaded';
      notifyListeners();
      return false;
    }
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getString('user_id');
    final resumeId = prefs.getString('resume_id');
    final applicantName = prefs.getString('user_name');
    final orgId = _jobDetails!.orgId; // usually from job details

    if (userId == null || resumeId == null || applicantName == null) {
      _applyError = 'Required user data missing';
      notifyListeners();
      return false;
    }

    _isApplying = true;
    _applyError = null;
    notifyListeners();

    try {
      final response = await _jobDetailsRepository.applyForJob(
        _jobDetails!.id!,
        userId: userId,
        orgId: orgId!,
        applicantName: applicantName,
        resumeId: resumeId,
        cancelToken: cancelToken,
      );

      if (response.success) {
        return true;
      } else {
        _applyError = response.message ;
        return false;
      }
    } catch (e) {
      _applyError = 'An unexpected error occurred';
      return false;
    } finally {
      _isApplying = false;
      notifyListeners();
    }
  }


  /// Clear job details state
  void clear() {
    _jobDetails = null;
    _error = null;
    _lastJobId = null;
    _lastFetchTime = null;
    notifyListeners();
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }
}
