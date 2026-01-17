import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/v2_form_repository.dart';
import '../../domain/models/v2_models.dart';
import '../../../../shared/widgets/headers/headers.dart';
import '../../../../shared/services/api/form_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

/// V2 Dynamic Form Screen - Renders forms using graph-based V2 config
class V2DynamicFormScreen extends StatefulWidget {
  final String professionId;
  final String? courseType;
  final String? flowContext;

  const V2DynamicFormScreen({
    super.key,
    required this.professionId,
    this.courseType,
    this.flowContext,
  });

  @override
  State<V2DynamicFormScreen> createState() => _V2DynamicFormScreenState();
}

class _V2DynamicFormScreenState extends State<V2DynamicFormScreen> {
  V2FormConfig? _config;
  V2FlowConfig? _currentFlow;
  V2StepConfig? _currentStep;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Navigation history for back button
  final List<String> _stepHistory = [];

  // Form data
  final Map<String, dynamic> _formData = {};
  final Map<String, String?> _errors = {};

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = context.read<V2FormRepository>();
      _config = await repository.getProfessionConfig(widget.professionId);

      if (_config == null) {
        throw Exception('Config not found for ${widget.professionId}');
      }

      // Select flow
      if (widget.courseType != null && widget.courseType != 'default') {
        _currentFlow = _config!.getFlow(widget.courseType!);
      }
      _currentFlow ??= _config!.defaultFlow;

      if (_currentFlow == null) {
        throw Exception('No flows configured');
      }

      // Start at first step
      _currentStep = _currentFlow!.firstStep;

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _updateField(String fieldId, dynamic value) {
    setState(() {
      _formData[fieldId] = value;
      _errors.remove(fieldId);
    });
  }

  bool _validateCurrentStep() {
    _errors.clear();

    final allFields = _currentStep?.getAllFields() ?? [];
    for (final field in allFields) {
      if (field.required && !_hasValue(field.id)) {
        _errors[field.id] = '${field.label ?? field.id} is required';
      }
    }

    setState(() {});
    return _errors.isEmpty;
  }

  bool _hasValue(String fieldId) {
    final value = _formData[fieldId];
    if (value == null) return false;
    if (value is String && value.isEmpty) return false;
    if (value is List && value.isEmpty) return false;
    return true;
  }

  Future<void> _navigateNext() async {
    if (_currentStep == null || _currentFlow == null) return;

    // Validate
    if (!_validateCurrentStep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Submit step data if API config exists
      if (_currentStep!.api != null) {
        await _submitStepData(_currentStep!.api!);
      }

      // Find next step using edges
      final nextStepId = _currentStep!.getNextStepId(_formData);

      if (nextStepId == null) {
        // Flow completed
        _onFormCompleted();
        return;
      }

      // Navigate to next step
      final nextStep = _currentFlow!.getStep(nextStepId);
      if (nextStep != null) {
        setState(() {
          _stepHistory.add(_currentStep!.id);
          _currentStep = nextStep;
        });
      } else {
        _onFormCompleted();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitStepData(V2ApiConfig api) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) throw Exception('User ID not found');

    final requestBody = api.buildRequestBody(_formData, userId);

    final apiService = context.read<FormApiService>();
    final result = await apiService.submitFormData(
      endpoint: api.endpoint,
      method: api.method,
      data: requestBody,
      pathParams: {'userId': userId},
    );

    if (result['success'] != true) {
      throw Exception(result['error'] ?? 'Failed to save');
    }
  }

  void _navigateBack() {
    if (_stepHistory.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final previousStepId = _stepHistory.removeLast();
    final previousStep = _currentFlow!.getStep(previousStepId);

    if (previousStep != null) {
      setState(() => _currentStep = previousStep);
    }
  }

  void _onFormCompleted() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form completed successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    final flow = widget.flowContext ?? 'signup';
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadConfig,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          CustomHeaderContainer(
            title: _currentStep?.title ?? '',
            subtitle: _currentStep?.subtitle ?? '',
            backgroundImage: 'assets/v2/Star.png',
            showBackButton: true,
            onBackPressed: _navigateBack,
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(),
            ),
          ),

          // Navigation
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_stepHistory.isNotEmpty) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _navigateBack,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    flex: _stepHistory.isEmpty ? 1 : 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _navigateNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff00A4E1),
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    if (_currentStep == null) return const SizedBox();

    final stepType = _currentStep!.type;

    switch (stepType) {
      case 'cardSelection':
        return _buildCardSelection();
      case 'form':
        return _buildFormFields();
      case 'modal':
        return _buildModalOptions();
      case 'grid':
        return _buildGridSelection();
      case 'list':
        return _buildListEntry();
      default:
        return Text('Unknown step type: $stepType');
    }
  }

  Widget _buildCardSelection() {
    final field = _currentStep!.field;
    if (field == null) return const SizedBox();

    final options = field.options ?? [];
    final selectedValue = _formData[field.id];

    return Column(
      children: options.map((option) {
        final isSelected = selectedValue == option.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _updateField(field.id, option.value),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xff00A4E1).withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xff00A4E1)
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    if (option.icon != null) ...[
                      Icon(
                        _getIconData(option.icon!),
                        color:
                            isSelected ? const Color(0xff00A4E1) : Colors.grey,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: Text(
                        option.label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xff00A4E1)
                              : Colors.black87,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: Color(0xff00A4E1)),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFormFields() {
    final fields = _currentStep!.fields ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields.map((field) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildField(field),
        );
      }).toList(),
    );
  }

  Widget _buildField(V2FieldConfig field) {
    switch (field.type) {
      case 'text':
        return TextField(
          onChanged: (value) => _updateField(field.id, value),
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.hint,
            errorText: _errors[field.id],
            border: const OutlineInputBorder(),
          ),
        );
      case 'radio':
        return _buildRadioField(field);
      case 'dropdown':
        return _buildDropdownField(field);
      default:
        return Text('Unknown field type: ${field.type}');
    }
  }

  Widget _buildRadioField(V2FieldConfig field) {
    final options = field.options ?? [];
    final selectedValue = _formData[field.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (field.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              field.label!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ...options.map((option) {
          return RadioListTile<String>(
            title: Text(option.label),
            value: option.value,
            groupValue: selectedValue,
            onChanged: (value) => _updateField(field.id, value),
            contentPadding: EdgeInsets.zero,
          );
        }),
        if (_errors[field.id] != null)
          Text(
            _errors[field.id]!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
      ],
    );
  }

  Widget _buildDropdownField(V2FieldConfig field) {
    final options = field.options ?? [];
    final selectedValue = _formData[field.id];

    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: field.label,
        errorText: _errors[field.id],
        border: const OutlineInputBorder(),
      ),
      items: options.map((option) {
        return DropdownMenuItem(
          value: option.value,
          child: Text(option.label),
        );
      }).toList(),
      onChanged: (value) => _updateField(field.id, value),
    );
  }

  Widget _buildModalOptions() {
    return _buildCardSelection(); // Same as card selection for now
  }

  Widget _buildGridSelection() {
    final field = _currentStep!.field;
    if (field == null) return const SizedBox();

    final options = field.options ?? [];
    final selectedValue = _formData[field.id];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = selectedValue == option.value;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _updateField(field.id, option.value),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xff00A4E1) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xff00A4E1)
                      : Colors.grey.shade300,
                ),
              ),
              child: Text(
                option.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListEntry() {
    // Simplified list entry - shows template fields
    final template = _currentStep!.template ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add your details:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        ...template.map((field) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildField(field),
          );
        }),
        if (_currentStep!.skippable)
          TextButton(
            onPressed: _navigateNext,
            child: const Text('Skip this step'),
          ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'menu_book':
        return Icons.menu_book;
      case 'school':
        return Icons.school;
      case 'medication':
        return Icons.medication;
      case 'work':
        return Icons.work;
      default:
        return Icons.help;
    }
  }
}
