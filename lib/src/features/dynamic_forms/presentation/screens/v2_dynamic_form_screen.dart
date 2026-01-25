import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/repositories/v2_form_repository.dart';
import '../../domain/models/v2_models.dart';
import '../../../../shared/widgets/headers/headers.dart';
import '../../../../shared/services/api/form_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

// V1 color constants
const Color mainBlue = Color(0xff00A4E1);
const Color inputBorderClr = Color(0xff6B7280);

/// V2 Dynamic Form Screen - V1 Style UI
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
  V2FormRepository get _formRepository =>
      context.read<V2FormRepository>();
  V2FormConfig? _config;
  V2FlowConfig? _currentFlow;
  V2StepConfig? _currentStep;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  final Map<String, List<V2FieldOption>> _fieldOptions = {};

  // Navigation history for back button
  final List<String> _stepHistory = [];

  // Form data
  final Map<String, dynamic> _formData = {};
  final Map<String, String?> _errors = {};

  // List entries for list-type steps
  List<Map<String, dynamic>> _listEntries = [];

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
      _initializeListEntries();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _initializeListEntries() {
    if (_currentStep?.type == 'list') {
      _listEntries = [{}];
    }
  }

  void _updateField(String fieldId, dynamic value) {
    setState(() {
      _formData[fieldId] = value;
      _errors.remove(fieldId);
    });
  }

  bool _isFieldVisible(V2FieldConfig field) {
    final condition = field.visibleWhen;
    if (condition == null || condition.isEmpty) return true;

    for (final entry in condition.entries) {
      final dependentFieldId = entry.key;
      final expectedValue = entry.value;
      final actualValue = _formData[dependentFieldId];

      if (actualValue != expectedValue) {
        return false;
      }
    }
    return true;
  }

  void _updateListEntry(int index, String fieldId, dynamic value) {
    setState(() {
      _listEntries[index][fieldId] = value;
    });
  }

  void _addListEntry() {
    setState(() {
      _listEntries.add({});
    });
  }

  void _removeListEntry(int index) {
    if (_listEntries.length > 1) {
      setState(() {
        _listEntries.removeAt(index);
      });
    }
  }

  bool _validateCurrentStep() {
    _errors.clear();

    if (_currentStep?.type == 'list') {
      // List validation - at least one entry or skippable
      if (_listEntries.isEmpty && !(_currentStep?.skippable ?? false)) {
        return false;
      }
      return true;
    }

    final allFields = _currentStep?.getAllFields() ?? [];
    for (final field in allFields) {
      if (!_isFieldVisible(field)) continue;

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
        if (_currentStep!.type == 'list') {
          // Submit each list entry in a loop
          await _submitListData(_currentStep!.api!);
        } else {
          await _submitStepData(_currentStep!.api!);
        }
      }

      // Find next step using edges
      final nextStepId = _currentStep!.getNextStepId(_formData);

      if (nextStepId == null) {
        _onFormCompleted();
        return;
      }

      // Navigate to next step
      final nextStep = _currentFlow!.getStep(nextStepId);
      if (nextStep != null) {
        setState(() {
          _stepHistory.add(_currentStep!.id);
          _currentStep = nextStep;
          _initializeListEntries();
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
    String endpoint = api.endpoint;
    if (endpoint == '/api/user-details/update') {
      endpoint = '/api/user-details/update/$userId?userId=$userId';
    }
    final result = await apiService.submitFormData(
      endpoint: endpoint,
      method: api.method,
      data: requestBody,
      pathParams: {'userId': userId},
    );

    if (result['success'] != true) {
      throw Exception(result['error'] ?? 'Failed to save');
    }
  }

  Future<void> _submitListData(V2ApiConfig api) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) throw Exception('User ID not found');

    final apiService = context.read<FormApiService>();

    // Submit each entry in a loop
    for (final entry in _listEntries) {
      if (entry.isEmpty) continue;

      final requestBody = <String, dynamic>{'userId': userId};

      // Build request body from entry using API mapping
      api.mapping.forEach((formField, apiField) {
        if (entry.containsKey(formField)) {
          requestBody[apiField] = entry[formField];
        }
      });

      final result = await apiService.submitFormData(
        endpoint: api.endpoint,
        method: api.method,
        data: requestBody,
        pathParams: {'userId': userId},
      );

      if (result['success'] != true) {
        throw Exception(result['error'] ?? 'Failed to save entry');
      }
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
      setState(() {
        _currentStep = previousStep;
        _initializeListEntries();
      });
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
                !routeName.contains('flow-selection'));
      });
    } else {
      context.go('/signup-completion');
    }
  }

  Future<void> _pickDate(int entryIndex, String fieldId) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1965),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final formatted = DateFormat('dd-MM-yyyy').format(picked);
      _updateListEntry(entryIndex, fieldId, formatted);
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
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: mainBlue,
        ),
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
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _currentStep?.title ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: mainBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _navigateBack,
        ),
      ),
      body: Column(
        children: [
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Subtitle
                  if (_currentStep?.subtitle != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      _currentStep!.subtitle!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: inputBorderClr,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                  _buildStepContent(),
                ],
              ),
            ),
          ),

          // Save Button
          SafeArea(
            top: false,
            minimum: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _navigateNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
                        'Save',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
        return _buildRadioSelection();
      case 'grid':
        return _buildGridSelection();
      case 'list':
        return _buildListEntry();
      default:
        return Text('Unknown step type: $stepType');
    }
  }

  /// V1 Style: Side-by-side card selection
  Widget _buildCardSelection() {
    final field = _currentStep!.field;
    if (field == null) return const SizedBox();

    final options = field.options ?? [];
    final selectedValue = _formData[field.id];
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: options.map((option) {
        final isSelected = selectedValue == option.value;
        return InkWell(
          onTap: () => _updateField(field.id, option.value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: screenWidth * 0.42,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? mainBlue.withOpacity(0.1)
                  : const Color(0xffD9D9D9),
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: mainBlue, width: 2) : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(2, 4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getIconData(option.icon ?? 'help'),
                  size: screenWidth * 0.12,
                  color: mainBlue,
                ),
                const SizedBox(height: 12),
                Text(
                  option.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: mainBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// V1 Style: Radio selection (for modal type)
  Widget _buildRadioSelection() {
    final field = _currentStep!.field;
    if (field == null) return const SizedBox();

    final options = field.options ?? [];
    final selectedValue = _formData[field.id];

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: options.map((option) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [

              Radio<String>(
                value: option.value,
                groupValue: selectedValue,
                activeColor: mainBlue,
                onChanged: (value) => _updateField(field.id, value),
              ),
              Expanded(
                child: Text(
                  option.label,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: inputBorderClr,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFormFields() {
    final fields = _currentStep!.fields ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields
          .where(_isFieldVisible)
          .map((field) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildField(field),
      ))
          .toList(),
    );
  }

  Future<void> _loadFieldOptions(V2FieldConfig field) async {
    if (field.source == null) return;

    // Prevent duplicate calls AND mark as loading
    if (_fieldOptions.containsKey(field.id)) return;

    // Mark loading state
    _fieldOptions[field.id] = [];

    final options = await _formRepository.getSharedOptions(field.source!);

    if (!mounted) return;

    setState(() {
      _fieldOptions[field.id] = options;
    });
  }



  Widget _buildField(V2FieldConfig field) {
    if (field.source != null) {
      _loadFieldOptions(field);
    }


    final options = field.options ?? _fieldOptions[field.id] ?? [];
    switch (field.type) {
      case 'text':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (field.label != null) ...[
              Text(
                field.label!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: inputBorderClr,
                ),
              ),
              const SizedBox(height: 8),
            ],
            TextFormField(
              initialValue: _formData[field.id]?.toString(),
              onChanged: (value) => _updateField(field.id, value),
              decoration: InputDecoration(
                hintText: field.hint ?? 'Enter ${field.label ?? field.id}',
                errorText: _errors[field.id],
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: inputBorderClr),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: mainBlue, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        );
      case 'radio':
        return _buildRadioField(field);
      case 'dropdown':
        return _buildDropdownField(field,options);
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
        if (field.label != null) ...[
          Text(
            field.label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: inputBorderClr,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: options.map((option) {
            return Row(
              children: [
                Text(
                  option.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: inputBorderClr,
                  ),
                ),
                Radio<String>(
                  value: option.value,
                  groupValue: selectedValue,
                  activeColor: mainBlue,
                  onChanged: (value) => _updateField(field.id, value),
                ),
              ],
            );
          }).toList(),
        ),
        if (_errors[field.id] != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _errors[field.id]!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdownField(
      V2FieldConfig field,
      List<V2FieldOption> options,
      ) {

    if (options.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (field.label != null)
            Text(
              field.label!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: inputBorderClr,
              ),
            ),
          const SizedBox(height: 8),
          const Text('No Data found'),
        ],
      );
    }

    return DropdownButtonFormField<String>(
      value: _formData[field.id],
      isExpanded: true,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.hint,
      ),
      items: options.map((opt) {
        return DropdownMenuItem<String>(
          value: opt.value,
          child: Text(
            opt.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        _updateField(field.id, value);
      },
    );
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
                color: isSelected ? mainBlue : const Color(0xffD9D9D9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                option.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// V1 Style: Multi-entry list with Add button
  Widget _buildListEntry() {
    final template = _currentStep!.template ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // List of entries
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _listEntries.length,
          itemBuilder: (context, index) {
            return _buildListEntryCard(index, template);
          },
        ),

        // Add button
        const SizedBox(height: 16),
        InkWell(
          onTap: _addListEntry,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Add',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: mainBlue,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.add, color: mainBlue),
            ],
          ),
        ),

        // Skip button if skippable
        if (_currentStep!.skippable) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: _navigateNext,
            child: const Text('Skip this step'),
          ),
        ],
      ],
    );
  }

  Widget _buildListEntryCard(int index, List<V2FieldConfig> template) {
    final entry = _listEntries[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Entry header with delete button
          if (_listEntries.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Experience ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: mainBlue,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _removeListEntry(index),
                ),
              ],
            ),

          // Template fields
          ...template.map((field) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildListField(index, field, entry),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildListField(
      int entryIndex, V2FieldConfig field, Map<String, dynamic> entry) {
    switch (field.type) {
      case 'radio':
        final options = field.options ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (field.label != null)
              Text(
                field.label!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: inputBorderClr,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: options.map((option) {
                return Row(
                  children: [
                    Text(option.label,
                        style: const TextStyle(color: inputBorderClr)),
                    Radio<String>(
                      value: option.value,
                      groupValue: entry[field.id],
                      activeColor: mainBlue,
                      onChanged: (value) =>
                          _updateListEntry(entryIndex, field.id, value),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        );

      case 'text':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (field.label != null)
              Text(
                field.label!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: inputBorderClr,
                ),
              ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: entry[field.id]?.toString(),
              onChanged: (value) =>
                  _updateListEntry(entryIndex, field.id, value),
              decoration: InputDecoration(
                hintText: field.hint ?? 'Enter ${field.label ?? field.id}',
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: inputBorderClr),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: mainBlue, width: 2),
                ),
              ),
            ),
          ],
        );

      case 'date':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (field.label != null)
              Text(
                field.label!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: inputBorderClr,
                ),
              ),
            const SizedBox(height: 8),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                  text: entry[field.id]?.toString() ?? ''),
              decoration: InputDecoration(
                hintText: 'Select Date',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month,
                      color: mainBlue, size: 28),
                  onPressed: () => _pickDate(entryIndex, field.id),
                ),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: inputBorderClr),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: mainBlue, width: 2),
                ),
              ),
              onTap: () => _pickDate(entryIndex, field.id),
            ),
          ],
        );

      default:
        return Text('Unknown field type: ${field.type}');
    }
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
