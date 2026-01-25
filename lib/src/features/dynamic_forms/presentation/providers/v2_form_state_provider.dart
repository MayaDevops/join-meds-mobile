import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/v2_models.dart';
import '../../domain/repositories/v2_form_repository.dart';
import '../../../../shared/services/api/form_api_service.dart';

/// V2 Form State Provider - Graph-based flow navigation
class V2FormStateProvider extends ChangeNotifier {
  final V2FormRepository _repository;
  final FormApiService _apiService;

  // Configuration
  V2FormConfig? _config;
  V2FlowConfig? _currentFlow;
  V2StepConfig? _currentStep;

  // Navigation history for back button
  final List<String> _stepHistory = [];

  // State
  Map<String, dynamic> _formData = {};
  Map<String, String?> _errors = {};
  bool _isLoading = false;
  String? _errorMessage;
  String? _flowContext;

  // Shared data (e.g., universities list)
  Map<String, List<String>> _sharedData = {};

  V2FormStateProvider({
    required V2FormRepository repository,
    required FormApiService apiService,
  }) : _repository = repository,
       _apiService = apiService;

  // Getters
  V2FormConfig? get config => _config;
  V2FlowConfig? get currentFlow => _currentFlow;
  V2StepConfig? get currentStep => _currentStep;
  Map<String, dynamic> get formData => _formData;
  Map<String, String?> get errors => _errors;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalSteps => _currentFlow?.totalSteps ?? 0;
  int get currentStepIndex => _stepHistory.length;
  double get progress =>
      totalSteps > 0 ? (_stepHistory.length + 1) / totalSteps : 0.0;
  bool get canGoBack => _stepHistory.isNotEmpty;
  bool get canSkip => _currentStep?.skippable ?? false;

  /// Initialize form with profession and course type
  Future<void> initialize({
    required String professionId,
    String? courseType,
    String? flowContext,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _flowContext = flowContext;
    _stepHistory.clear();

    try {
      print('🔍 V2: Initializing form for profession: $professionId');
      _config = await _repository.getProfessionConfig(professionId);

      if (_config == null) {
        throw Exception(
          'Configuration not found for profession: $professionId',
        );
      }
      print('✅ V2: Config loaded - ${_config!.profession.displayName}');
      print('✅ V2: Available flows: ${_config!.flows.keys.toList()}');

      // Select flow
      if (courseType != null && courseType != 'default') {
        _currentFlow = _config!.getFlow(courseType);
      }
      _currentFlow ??= _config!.defaultFlow;

      if (_currentFlow == null) {
        throw Exception('No flows configured for profession: $professionId');
      }

      print('✅ V2: Selected flow: ${_currentFlow!.id}');

      // Start at first step
      _currentStep = _currentFlow!.firstStep;
      if (_currentStep == null) {
        throw Exception('No steps configured in flow: ${_currentFlow!.id}');
      }

      print('✅ V2: First step: ${_currentStep!.id} - ${_currentStep!.title}');

      // Load shared data
      await _loadSharedData();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ V2 Error initializing form: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load shared data (universities, etc.)
  Future<void> _loadSharedData() async {
    try {
      // Collect all data source paths from fields
      final sources = <String>{};
      for (final step in _currentFlow?.steps.values ?? <V2StepConfig>[]) {
        for (final field in step.getAllFields()) {
          if (field.source != null) {
            sources.add(field.source!);
          }
        }
      }

      // Load each source
      for (final source in sources) {
        final data = await _repository.getSharedData(source);
        _sharedData[source] = data;
      }
    } catch (e) {
      print('V2 Error loading shared data: $e');
    }
  }

  /// Get shared data by source path
  List<String>? getSharedData(String source) => _sharedData[source];

  /// Update field value
  void updateField(String fieldId, dynamic value) {
    _formData[fieldId] = value;
    _errors.remove(fieldId);
    notifyListeners();
  }

  /// Validate current step
  bool validateCurrentStep() {
    if (_currentStep == null) return false;

    _errors.clear();
    final allFields = _currentStep!.getAllFields();

    for (final field in allFields) {
      if (field.required && !_hasValue(field.id)) {
        _errors[field.id] = '${field.label ?? field.id} is required';
      }
    }

    notifyListeners();
    return _errors.isEmpty;
  }

  bool _hasValue(String fieldId) {
    final value = _formData[fieldId];
    if (value == null) return false;
    if (value is String && value.isEmpty) return false;
    if (value is List && value.isEmpty) return false;
    return true;
  }

  /// Navigate to next step based on edges
  Future<void> navigateNext(BuildContext context) async {
    if (_currentStep == null || _currentFlow == null) return;

    // Validate
    if (!validateCurrentStep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Submit step data
    if (_currentStep!.api != null) {
      final success = await _submitStepData(_currentStep!.api!);
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

    // Find next step using edges
    final nextStepId = _currentStep!.getNextStepId(_formData);

    print('🔍 V2: Next step ID from edges: $nextStepId');

    if (nextStepId == null) {
      // Flow completed
      if (context.mounted) {
        _onFormCompleted(context);
      }
      return;
    }

    // Navigate to next step
    final nextStep = _currentFlow!.getStep(nextStepId);
    if (nextStep != null) {
      _stepHistory.add(_currentStep!.id);
      _currentStep = nextStep;
      print('✅ V2: Navigated to: ${_currentStep!.id} - ${_currentStep!.title}');
      notifyListeners();
    } else {
      print('❌ V2: Step not found: $nextStepId');
      if (context.mounted) {
        _onFormCompleted(context);
      }
    }
  }

  /// Navigate back to previous step
  void navigateBack() {
    if (_stepHistory.isEmpty || _currentFlow == null) return;

    final previousStepId = _stepHistory.removeLast();
    final previousStep = _currentFlow!.getStep(previousStepId);

    if (previousStep != null) {
      _currentStep = previousStep;
      notifyListeners();
    }
  }

  /// Skip current step
  void skipStep(BuildContext context) {
    if (_currentStep?.skippable != true) return;

    // Find next step (use first edge for skip)
    if (_currentStep!.edges.isNotEmpty) {
      final nextStepId = _currentStep!.edges.first.goto;
      if (nextStepId != '_complete') {
        final nextStep = _currentFlow!.getStep(nextStepId);
        if (nextStep != null) {
          _stepHistory.add(_currentStep!.id);
          _currentStep = nextStep;
          notifyListeners();
          return;
        }
      }
    }

    // Complete flow
    _onFormCompleted(context);
  }

  /// Submit step data to API
  Future<bool> _submitStepData(V2ApiConfig api) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final userId = await _getUserId();
      if (userId == null || userId.isEmpty) {
        _errorMessage = 'User ID not found. Please log in again.';
        return false;
      }

      // Build request body using API config mapping
      final requestBody = api.buildRequestBody(_formData, userId);

      print('🔧 V2: API endpoint: ${api.endpoint}');
      print('🔧 V2: Request body: $requestBody');

      final result = await _apiService.submitFormData(
        endpoint: api.endpoint,
        method: api.method,
        data: requestBody,
        pathParams: {'userId': userId},
      );

      if (result['success'] == true) {
        return true;
      } else {
        _errorMessage = result['error']?.toString();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get userId from SharedPreferences
  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  /// Handle form completion
  void _onFormCompleted(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form completed successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    clearFormData();

    final flow = _flowContext ?? 'signup';
    if (flow == 'profile') {
      Navigator.of(context).popUntil((route) {
        final routeName = route.settings.name;
        return routeName == null ||
            (!routeName.contains('dynamic-form') &&
                !routeName.contains('profession-selection'));
      });
    } else {
      context.go('/signup-completion');
    }
  }

  /// Clear all form data
  void clearFormData() {
    _formData.clear();
    _errors.clear();
    _stepHistory.clear();
    notifyListeners();
  }

  /// Reset to first step
  void resetToFirstStep() {
    if (_currentFlow != null) {
      _currentStep = _currentFlow!.firstStep;
      _stepHistory.clear();
      clearFormData();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  dynamic getFieldValue(String fieldId) => _formData[fieldId];

  String? getFieldError(String fieldId) => _errors[fieldId];

  @override
  void dispose() {
    _formData.clear();
    _errors.clear();
    _sharedData.clear();
    _stepHistory.clear();
    super.dispose();
  }
}
