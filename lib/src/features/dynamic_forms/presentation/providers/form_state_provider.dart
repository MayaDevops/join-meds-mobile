import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/src/core/utils/api_date_formatter.dart';
import '../../domain/models/form_config.dart';
import '../../domain/models/step_config.dart';
import '../../domain/repositories/form_repository.dart';
import '../../../../shared/services/api/form_api_service.dart';
import '../utils/validation_engine.dart';
import '../utils/navigation_handler.dart';

/// Central state management for dynamic forms
class FormStateProvider extends ChangeNotifier {
  final FormRepository _repository;
  final FormApiService _apiService;

  // Configuration
  FormConfig? _config;
  FlowConfig? _currentFlow;
  StepConfig? _currentStep;

  // State
  int _currentStepIndex = 0;
  Map<String, dynamic> _formData = {};
  Map<String, String?> _errors = {};
  bool _isLoading = false;
  String? _errorMessage;
  String? _flowContext;

  // Shared data (e.g., universities list)
  Map<String, List<String>> _sharedData = {};

  FormStateProvider({
    required FormRepository repository,
    required FormApiService apiService,
  })  : _repository = repository,
        _apiService = apiService;

  // Getters
  FormConfig? get config => _config;
  FlowConfig? get currentFlow => _currentFlow;
  StepConfig? get currentStep => _currentStep;
  int get currentStepIndex => _currentStepIndex;
  Map<String, dynamic> get formData => _formData;
  Map<String, String?> get errors => _errors;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalSteps => _currentFlow?.steps.length ?? 0;
  double get progress =>
      totalSteps > 0 ? (_currentStepIndex + 1) / totalSteps : 0.0;

  /// Initialize form with profession and optional course type
  Future<void> initialize({
    required String professionId,
    String? courseType,
    String? flowContext,
    bool forceRefresh = false,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _flowContext = flowContext;

    try {
      // Debug: Log initialization parameters
      print('🔍 DEBUG: Initializing form for profession: $professionId');
      print('🔍 DEBUG: Course type: $courseType');
      print('🔍 DEBUG: Flow context: $flowContext');
      print('🔍 DEBUG: Force refresh: $forceRefresh');

      // TEMPORARY: Force refresh to clear old cache
      print('🔧 DEBUG: Forcing config refresh for $professionId');
      _config = await _repository.getProfessionConfigWithCache(
        professionId,
        forceRefresh: true, // Always force refresh for now
      );

      if (_config == null) {
        print('❌ DEBUG: Config is NULL for $professionId');
        throw Exception(
            'Configuration not found for profession: $professionId');
      }

      // Debug: Log loaded config
      print(
          '✅ DEBUG: Config loaded - profession displayName: ${_config!.profession.displayName}');
      print('✅ DEBUG: Available flows: ${_config!.flows.keys.toList()}');

      // Select flow (course type)
      if (courseType != null && courseType != 'default') {
        // Try to find specific course type
        _currentFlow = _config!.getFlowById(courseType);
      }

      // If no flow selected yet, use default flow
      if (_currentFlow == null) {
        _currentFlow = _config!.getDefaultFlow();
      }

      if (_currentFlow == null) {
        print('❌ DEBUG: No flows configured for profession: $professionId');
        throw Exception('No flows configured for profession: $professionId');
      }

      // Debug: Log selected flow
      print('✅ DEBUG: Selected flow: ${_currentFlow!.flowId}');
      print('✅ DEBUG: Flow displayName: ${_currentFlow!.displayName}');
      print('✅ DEBUG: Flow has ${_currentFlow!.steps.length} steps');

      // Initialize with first step
      _currentStepIndex = 0;
      _currentStep = _currentFlow!.steps.first;

      // Debug: Log first step
      print('✅ DEBUG: First step loaded: ${_currentStep!.stepId}');
      print('✅ DEBUG: Step title: "${_currentStep!.title}"');
      print('✅ DEBUG: Step subtitle: "${_currentStep?.subtitle}"');

      // Load shared data if needed
      await _loadSharedData();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      print('Error initializing form: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load shared data (e.g., universities)
  Future<void> _loadSharedData() async {
    if (_config?.sharedDataPaths == null) return;

    try {
      for (final entry in _config!.sharedDataPaths!.entries) {
        final data = await _repository.getSharedDataWithCache(entry.value);
        _sharedData[entry.key] = data;
      }
    } catch (e) {
      print('Error loading shared data: $e');
    }
  }

  /// Get shared data by key or path
  /// Tries direct lookup first, then resolves path to key if needed
  List<String>? getSharedData(String keyOrPath) {
    // Try direct lookup first (for backward compatibility)
    if (_sharedData.containsKey(keyOrPath)) {
      return _sharedData[keyOrPath];
    }

    // If not found, try to find key by matching path
    if (_config?.sharedDataPaths != null) {
      for (final entry in _config!.sharedDataPaths!.entries) {
        if (entry.value == keyOrPath) {
          return _sharedData[entry.key];
        }
      }
    }

    return null;
  }

  /// Update field value
  void updateField(String fieldId, dynamic value) {
    _formData[fieldId] = value;

    // Clear error for this field
    if (_errors.containsKey(fieldId)) {
      _errors.remove(fieldId);
    }

    notifyListeners();
  }

  /// Validate current step
  bool validateCurrentStep() {
    if (_currentStep == null) return false;

    _errors = ValidationEngine.validateStep(
      _currentStep!.fields,
      _formData,
    );

    notifyListeners();
    return _errors.values.every((error) => error == null);
  }

  /// Navigate to next step
  Future<void> navigateNext(BuildContext context) async {
    if (_currentStep == null || _currentFlow == null) return;

    // Debug: Log navigation attempt
    print('🔍 DEBUG: Navigate next from step: ${_currentStep!.stepId}');
    print('🔍 DEBUG: Current step title: "${_currentStep!.title}"');

    // Validate if required
    if (_currentStep!.validateBeforeNavigate) {
      if (!validateCurrentStep()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fix the errors before continuing'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Submit step data if API config exists
    if (_currentStep!.apiConfig != null) {
      final success = await _submitStepData(_currentStep!.apiConfig!);
      if (!success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage ?? 'Failed to save data'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    // Evaluate navigation
    final nextStepId = await NavigationHandler.evaluateNavigation(
      navigation: _currentStep!.navigation,
      formData: _formData,
      context: context,
      onShowModal: (modalConfig) async {
        final result = await NavigationHandler.showModal(
          context,
          modalConfig,
        );
        if (result != null) {
          updateField(modalConfig.fieldId, result);
        }
      },
    );

    // Debug: Log navigation result
    print('🔍 DEBUG: Next step ID determined: $nextStepId');

    if (nextStepId != null) {
      final found = await navigateToStep(nextStepId);

      // If step not found and we're at the last step, complete the form
      if (!found && _currentStepIndex >= totalSteps - 1) {
        if (context.mounted) {
          _onFormCompleted(context);
        }
      }
    } else if (_currentStepIndex < totalSteps - 1) {
      // Move to next step in sequence
      _currentStepIndex++;
      _currentStep = _currentFlow!.steps[_currentStepIndex];
      notifyListeners();
    } else {
      // Last step completed
      if (context.mounted) {
        _onFormCompleted(context);
      }
    }
  }

  /// Navigate to specific step by ID
  /// Returns true if step was found, false otherwise
  Future<bool> navigateToStep(String stepId) async {
    if (_currentFlow == null) return false;

    // Debug: Log navigation attempt
    print('🔍 DEBUG: Navigating to step: $stepId');

    final stepIndex = _currentFlow!.getStepIndex(stepId);
    if (stepIndex >= 0) {
      _currentStepIndex = stepIndex;
      _currentStep = _currentFlow!.steps[stepIndex];

      // Debug: Log successful navigation
      print('✅ DEBUG: Step found at index $stepIndex');
      print('✅ DEBUG: New step title: "${_currentStep!.title}"');
      print('✅ DEBUG: New step subtitle: "${_currentStep?.subtitle}"');

      notifyListeners();
      return true;
    } else {
      print('❌ DEBUG: Step not found: $stepId');
      return false;
    }
  }

  /// Navigate to previous step
  void navigateBack() {
    if (_currentStepIndex > 0) {
      _currentStepIndex--;
      _currentStep = _currentFlow!.steps[_currentStepIndex];
      notifyListeners();
    }
  }

  /// Skip current step (if allowed)
  void skipStep(BuildContext context) {
    if (_currentStep?.skippable == true) {
      if (_currentStep!.skipMessage != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_currentStep!.skipMessage!)),
        );
      }

      if (_currentStepIndex < totalSteps - 1) {
        _currentStepIndex++;
        _currentStep = _currentFlow!.steps[_currentStepIndex];
        notifyListeners();
      }
    }
  }

  /// Get userId from SharedPreferences
  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  /// Get field IDs for the current step
  List<String> _getCurrentStepFieldIds() {
    if (_currentStep?.fields == null) return [];
    return _currentStep!.fields.map((field) => field.fieldId).toList();
  }

  /// Submit step data to API
  Future<bool> _submitStepData(apiConfig) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Get userId from SharedPreferences
      final userId = await _getUserId();

      if (userId == null || userId.isEmpty) {
        _errorMessage = 'User ID not found. Please log in again.';
        return false;
      }

      // Build complete field mapping from both step-level and field-level sources
      final completeFieldMapping = <String, String>{};

      // 1. Start with step-level fieldMapping from apiConfig (if exists)
      if (apiConfig.fieldMapping != null) {
        completeFieldMapping.addAll(apiConfig.fieldMapping!);
      }

      // 2. Add field-level apiMapping from each field (if not already mapped)
      if (_currentStep?.fields != null) {
        for (final field in _currentStep!.fields) {
          if (field.apiMapping != null &&
              !completeFieldMapping.containsKey(field.fieldId)) {
            completeFieldMapping[field.fieldId] = field.apiMapping!;
          }
        }
      }

      // 3. Filter form data to only include current step's fields
      final currentStepFieldIds = _getCurrentStepFieldIds();
      final filteredFormData = <String, dynamic>{};
      for (final fieldId in currentStepFieldIds) {
        if (_formData.containsKey(fieldId)) {
          filteredFormData[fieldId] = _formData[fieldId];
        }
      }

      print('🔧 DEBUG: Current step fields: $currentStepFieldIds');
      print('🔧 DEBUG: All form data: $_formData');
      print('🔧 DEBUG: Filtered data for this step: $filteredFormData');
      print('🔧 DEBUG: Field mapping: $completeFieldMapping');

      // Map form data to API fields using complete mapping
      final mappedData = _apiService.mapFormDataToApi(
        formData: filteredFormData, // ✅ Use filtered data
        fieldMapping: completeFieldMapping,
      );

      print('🔧 DEBUG: Final mapped data for API: $mappedData');

      if (mappedData.containsKey('experiences') &&
          mappedData['experiences'] is List) {
        final List experiences = mappedData['experiences'];

        for (final exp in experiences) {
          final singleExperiencePayload = {
            'userId': userId.toString(),
            'clinicalNonclinical': exp['experienceType'].toString(),
            'workedHospName': exp['organisation'].toString(),
            'workSpecialisation': 'General',
            'fromDate': ApiDateFormatter.toApiDateString(exp['fromDate']),
            'toDate': ApiDateFormatter.toApiDateString(exp['toDate']),
          };

          final result = await _apiService.submitFormData(
            endpoint: apiConfig.endpoint, // /api/work-experience/save
            method: apiConfig.method, // POST
            data: singleExperiencePayload,
            headers: apiConfig.headers,
            pathParams: {'userId': userId},
          );
          if (result['success'] != true) {
            _errorMessage =
                apiConfig.errorMessage ?? result['error']?.toString();
            return false;
          }
        }

        return true;
      }

      // Add static params
      if (apiConfig.staticParams != null) {
        mappedData.addAll(apiConfig.staticParams!);
      }

      // Construct pathParams for placeholder replacement
      final pathParams = {'userId': userId};

      // Submit to API with pathParams
      final result = await _apiService.submitFormData(
        endpoint: apiConfig.endpoint,
        method: apiConfig.method,
        data: mappedData,
        headers: apiConfig.headers,
        pathParams: pathParams,
      );

      if (result['success'] == true) {
        if (apiConfig.successMessage != null) {
          // Success message will be shown by caller
        }
        return true;
      } else {
        _errorMessage = apiConfig.errorMessage ?? result['error']?.toString();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Handle form completion
  void _onFormCompleted(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form completed successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Clear form data
    clearFormData();

    // Navigate based on flow context
    final flow = _flowContext ?? 'signup';

    if (flow == 'profile') {
      // Profile flow: pop back to profile screen
      if (context.mounted) {
        // Pop back to profile (pop dynamic forms and profession selection screens)
        Navigator.of(context).popUntil((route) {
          // Keep popping until we reach a route that's not dynamic-form or profession-selection
          final routeName = route.settings.name;
          return routeName == null ||
              (!routeName.contains('dynamic-form') &&
                  !routeName.contains('profession-selection'));
        });
      }
    } else {
      // Signup flow: go to completion screen
      context.go('/signup-completion');
    }
  }

  /// Clear all form data
  void clearFormData() {
    _formData.clear();
    _errors.clear();
    notifyListeners();
  }

  /// Reset to first step
  void resetToFirstStep() {
    if (_currentFlow != null && _currentFlow!.steps.isNotEmpty) {
      _currentStepIndex = 0;
      _currentStep = _currentFlow!.steps.first;
      clearFormData();
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Get field value
  dynamic getFieldValue(String fieldId) {
    return _formData[fieldId];
  }

  /// Get field error
  String? getFieldError(String fieldId) {
    return _errors[fieldId];
  }

  /// Check if step can go back
  bool get canGoBack => _currentStepIndex > 0;

  /// Check if step can skip
  bool get canSkip => _currentStep?.skippable ?? false;

  @override
  void dispose() {
    _formData.clear();
    _errors.clear();
    _sharedData.clear();
    super.dispose();
  }
}
