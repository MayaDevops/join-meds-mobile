import 'package:flutter/material.dart';
import '../models/step_config.dart';
import '../models/field_config.dart';
import 'field_builder_screen.dart';

class StepEditorScreen extends StatefulWidget {
  final String professionId;
  final String flowId;
  final String stepId;
  final StepConfig initialStep;
  final Function(StepConfig) onStepUpdated;

  const StepEditorScreen({
    super.key,
    required this.professionId,
    required this.flowId,
    required this.stepId,
    required this.initialStep,
    required this.onStepUpdated,
  });

  @override
  State<StepEditorScreen> createState() => _StepEditorScreenState();
}

class _StepEditorScreenState extends State<StepEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  late StepConfig _currentStep;
  bool _hasChanges = false;
  String _selectedStepType = 'form';
  bool _showProgress = true;
  bool _validateBeforeNavigate = true;
  bool _skippable = false;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    _titleController.text = _currentStep.title;
    _subtitleController.text = _currentStep.subtitle ?? '';
    _selectedStepType = _currentStep.stepType;
    _showProgress = _currentStep.showProgress ?? true;
    _validateBeforeNavigate = _currentStep.validateBeforeNavigate ?? true;
    _skippable = _currentStep.skippable ?? false;
  }

  void _saveChanges() {
    final updatedStep = _currentStep.copyWith(
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim().isEmpty
          ? null
          : _subtitleController.text.trim(),
      stepType: _selectedStepType,
      showProgress: _showProgress,
      validateBeforeNavigate: _validateBeforeNavigate,
      skippable: _skippable,
    );

    widget.onStepUpdated(updatedStep);
    setState(() {
      _currentStep = updatedStep;
      _hasChanges = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Step updated')),
    );
  }

  void _addField() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FieldBuilderScreen(
          professionId: widget.professionId,
          flowId: widget.flowId,
          stepId: widget.stepId,
          onFieldCreated: (newField) {
            setState(() {
              _currentStep = _currentStep.copyWith(
                fields: [..._currentStep.fields, newField],
              );
              _hasChanges = true;
            });
          },
        ),
      ),
    );
  }

  void _editField(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FieldBuilderScreen(
          professionId: widget.professionId,
          flowId: widget.flowId,
          stepId: widget.stepId,
          initialField: _currentStep.fields[index],
          onFieldCreated: (updatedField) {
            final fields = List<FieldConfig>.from(_currentStep.fields);
            fields[index] = updatedField;

            setState(() {
              _currentStep = _currentStep.copyWith(fields: fields);
              _hasChanges = true;
            });
          },
        ),
      ),
    );
  }

  void _deleteField(int index) async {
    final field = _currentStep.fields[index];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Field'),
        content: Text('Are you sure you want to delete "${field.label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final fields = List<FieldConfig>.from(_currentStep.fields);
      fields.removeAt(index);

      setState(() {
        _currentStep = _currentStep.copyWith(fields: fields);
        _hasChanges = true;
      });
    }
  }

  void _moveFieldUp(int index) {
    if (index == 0) return;

    final fields = List<FieldConfig>.from(_currentStep.fields);
    final temp = fields[index];
    fields[index] = fields[index - 1];
    fields[index - 1] = temp;

    setState(() {
      _currentStep = _currentStep.copyWith(fields: fields);
      _hasChanges = true;
    });
  }

  void _moveFieldDown(int index) {
    if (index >= _currentStep.fields.length - 1) return;

    final fields = List<FieldConfig>.from(_currentStep.fields);
    final temp = fields[index];
    fields[index] = fields[index + 1];
    fields[index + 1] = temp;

    setState(() {
      _currentStep = _currentStep.copyWith(fields: fields);
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step: ${_currentStep.title}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_hasChanges)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChanges,
              tooltip: 'Save Changes',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Step Properties',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _hasChanges = true;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _subtitleController,
                      decoration: const InputDecoration(
                        labelText: 'Subtitle (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        setState(() {
                          _hasChanges = true;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedStepType,
                      decoration: const InputDecoration(
                        labelText: 'Step Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'form', child: Text('Form')),
                        DropdownMenuItem(
                            value: 'cardSelection', child: Text('Card Selection')),
                        DropdownMenuItem(value: 'modal', child: Text('Modal')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStepType = value!;
                          _hasChanges = true;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Step ID: ${_currentStep.stepId}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Show Progress'),
                      value: _showProgress,
                      onChanged: (value) {
                        setState(() {
                          _showProgress = value!;
                          _hasChanges = true;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Validate Before Navigate'),
                      value: _validateBeforeNavigate,
                      onChanged: (value) {
                        setState(() {
                          _validateBeforeNavigate = value!;
                          _hasChanges = true;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Skippable'),
                      value: _skippable,
                      onChanged: (value) {
                        setState(() {
                          _skippable = value!;
                          _hasChanges = true;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Fields',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addField,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Field'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_currentStep.fields.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No fields yet. Add a field to get started.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _currentStep.fields.length,
                itemBuilder: (context, index) {
                  final field = _currentStep.fields[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(
                        field.label,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'ID: ${field.fieldId} | Type: ${field.fieldType.name}${field.required ? " | Required" : ""}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_upward),
                            onPressed: index == 0 ? null : () => _moveFieldUp(index),
                            tooltip: 'Move Up',
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_downward),
                            onPressed: index >= _currentStep.fields.length - 1
                                ? null
                                : () => _moveFieldDown(index),
                            tooltip: 'Move Down',
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editField(index),
                            tooltip: 'Edit Field',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteField(index),
                            tooltip: 'Delete Field',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }
}
