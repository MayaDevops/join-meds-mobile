import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

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
        _error = response.message ?? 'Failed to load job details';
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
