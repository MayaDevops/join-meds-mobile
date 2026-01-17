import 'package:flutter/material.dart';
import '../models/v2_form_config.dart';

/// V2 Step Editor Screen - Edit step fields, edges, and API config
class V2StepEditorScreen extends StatefulWidget {
  final V2StepConfig step;
  final List<String> allStepIds;

  const V2StepEditorScreen({
    super.key,
    required this.step,
    required this.allStepIds,
  });

  @override
  State<V2StepEditorScreen> createState() => _V2StepEditorScreenState();
}

class _V2StepEditorScreenState extends State<V2StepEditorScreen> {
  late V2StepConfig _step;
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _apiEndpointController;
  String _selectedType = 'form';
  bool _skippable = false;

  @override
  void initState() {
    super.initState();
    _step = widget.step;
    _titleController = TextEditingController(text: _step.title);
    _subtitleController = TextEditingController(text: _step.subtitle ?? '');
    _apiEndpointController = TextEditingController(
      text: _step.api?.endpoint ?? '',
    );
    _selectedType = _step.type;
    _skippable = _step.skippable;
  }

  void _saveAndReturn() {
    final apiConfig = _apiEndpointController.text.trim().isNotEmpty
        ? V2ApiConfig(
            endpoint: _apiEndpointController.text.trim(),
            method: 'POST',
            mapping: _step.api?.mapping ?? {},
          )
        : null;

    final updatedStep = _step.copyWith(
      type: _selectedType,
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim().isEmpty
          ? null
          : _subtitleController.text.trim(),
      skippable: _skippable,
      api: apiConfig,
    );

    Navigator.pop(context, updatedStep);
  }

  Future<void> _addEdge() async {
    String? selectedStep;
    final conditionFieldController = TextEditingController();
    final conditionValueController = TextEditingController();
    bool hasCondition = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Edge'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedStep,
                  decoration: const InputDecoration(
                    labelText: 'Go To',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: '_complete',
                      child: Text('✓ Complete Flow'),
                    ),
                    ...widget.allStepIds
                        .where((id) => id != widget.step.id)
                        .map(
                          (id) => DropdownMenuItem(value: id, child: Text(id)),
                        ),
                  ],
                  onChanged: (value) {
                    setDialogState(() => selectedStep = value);
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Has Condition'),
                  value: hasCondition,
                  onChanged: (value) {
                    setDialogState(() => hasCondition = value);
                  },
                ),
                if (hasCondition) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: conditionFieldController,
                    decoration: const InputDecoration(
                      labelText: 'When Field',
                      hintText: 'e.g., academicStatus',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: conditionValueController,
                    decoration: const InputDecoration(
                      labelText: 'Equals Value',
                      hintText: 'e.g., ongoing',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedStep != null
                  ? () => Navigator.pop(context, true)
                  : null,
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result == true && selectedStep != null) {
      final newEdge = V2EdgeConfig(
        when: hasCondition && conditionFieldController.text.trim().isNotEmpty
            ? {
                conditionFieldController.text.trim(): conditionValueController
                    .text
                    .trim(),
              }
            : null,
        goto: selectedStep!,
      );

      setState(() {
        final updatedEdges = List<V2EdgeConfig>.from(_step.edges);
        updatedEdges.add(newEdge);
        _step = _step.copyWith(edges: updatedEdges);
      });
    }
  }

  void _deleteEdge(int index) {
    setState(() {
      final updatedEdges = List<V2EdgeConfig>.from(_step.edges);
      updatedEdges.removeAt(index);
      _step = _step.copyWith(edges: updatedEdges);
    });
  }

  Future<void> _addField() async {
    final idController = TextEditingController();
    final labelController = TextEditingController();
    String selectedType = 'text';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Field'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: 'Field ID',
                  hintText: 'e.g., currentYear',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: 'Label',
                  hintText: 'e.g., Current Year',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Field Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'text', child: Text('Text')),
                  DropdownMenuItem(value: 'radio', child: Text('Radio')),
                  DropdownMenuItem(value: 'dropdown', child: Text('Dropdown')),
                  DropdownMenuItem(value: 'date', child: Text('Date')),
                  DropdownMenuItem(value: 'grid', child: Text('Grid')),
                ],
                onChanged: (value) {
                  setDialogState(() => selectedType = value!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final newField = V2FieldConfig(
        id: idController.text.trim(),
        type: selectedType,
        label: labelController.text.trim().isEmpty
            ? null
            : labelController.text.trim(),
      );

      setState(() {
        final updatedFields = List<V2FieldConfig>.from(_step.fields ?? []);
        updatedFields.add(newField);
        _step = _step.copyWith(fields: updatedFields);
      });
    }
  }

  void _deleteField(int index) {
    setState(() {
      final updatedFields = List<V2FieldConfig>.from(_step.fields ?? []);
      updatedFields.removeAt(index);
      _step = _step.copyWith(fields: updatedFields);
    });
  }

  Future<void> _editFieldOptions(int fieldIndex) async {
    final field = _step.fields![fieldIndex];
    final optionsController = TextEditingController(
      text: field.options?.map((o) => o.value).join('\n') ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Options for ${field.id}'),
        content: TextField(
          controller: optionsController,
          maxLines: 10,
          decoration: const InputDecoration(
            labelText: 'Options (one per line)',
            border: OutlineInputBorder(),
            hintText: '1st Year\n2nd Year\n3rd Year',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      final options = optionsController.text
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .map((s) => V2FieldOption(value: s, label: s))
          .toList();

      setState(() {
        final updatedFields = List<V2FieldConfig>.from(_step.fields ?? []);
        updatedFields[fieldIndex] = field.copyWith(options: options);
        _step = _step.copyWith(fields: updatedFields);
      });
    }
  }

  Future<void> _editApiMapping() async {
    final mappings = Map<String, String>.from(_step.api?.mapping ?? {});
    final fieldIdController = TextEditingController();
    final apiFieldController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('API Field Mapping'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...mappings.entries.map(
                  (entry) => ListTile(
                    title: Text('${entry.key} → ${entry.value}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setDialogState(() {
                          mappings.remove(entry.key);
                        });
                      },
                    ),
                  ),
                ),
                const Divider(),
                TextField(
                  controller: fieldIdController,
                  decoration: const InputDecoration(
                    labelText: 'Form Field ID',
                    hintText: 'e.g., currentYear',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: apiFieldController,
                  decoration: const InputDecoration(
                    labelText: 'API Field Name',
                    hintText: 'e.g., currentYear',
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    if (fieldIdController.text.isNotEmpty &&
                        apiFieldController.text.isNotEmpty) {
                      setDialogState(() {
                        mappings[fieldIdController.text.trim()] =
                            apiFieldController.text.trim();
                        fieldIdController.clear();
                        apiFieldController.clear();
                      });
                    }
                  },
                  child: const Text('Add Mapping'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );

    setState(() {
      if (_step.api != null || mappings.isNotEmpty) {
        _step = _step.copyWith(
          api: V2ApiConfig(
            endpoint: _apiEndpointController.text.trim(),
            method: 'POST',
            mapping: mappings,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step: ${_step.id}'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveAndReturn),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Step Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Step Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'cardSelection',
                          child: Text('Card Selection'),
                        ),
                        DropdownMenuItem(value: 'form', child: Text('Form')),
                        DropdownMenuItem(value: 'modal', child: Text('Modal')),
                        DropdownMenuItem(value: 'grid', child: Text('Grid')),
                        DropdownMenuItem(value: 'list', child: Text('List')),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedType = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _subtitleController,
                      decoration: const InputDecoration(
                        labelText: 'Subtitle (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Skippable'),
                      value: _skippable,
                      onChanged: (value) {
                        setState(() => _skippable = value);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Fields Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Fields',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _addField,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Field'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_step.fields?.isEmpty ?? true)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No fields'),
                ),
              )
            else
              ...(_step.fields!.asMap().entries.map((entry) {
                final field = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(field.id),
                    subtitle: Text(
                      '${field.type} | ${field.label ?? "no label"}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (field.type == 'radio' || field.type == 'dropdown')
                          IconButton(
                            icon: const Icon(Icons.list, color: Colors.blue),
                            onPressed: () => _editFieldOptions(entry.key),
                            tooltip: 'Edit Options',
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteField(entry.key),
                        ),
                      ],
                    ),
                  ),
                );
              })),

            const SizedBox(height: 24),

            // Edges Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Navigation Edges',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _addEdge,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Edge'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_step.edges.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No edges (step has no navigation)'),
                ),
              )
            else
              ...(_step.edges.asMap().entries.map((entry) {
                final edge = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: edge.goto == '_complete'
                      ? Colors.green.shade50
                      : Colors.grey.shade50,
                  child: ListTile(
                    leading: Icon(
                      edge.goto == '_complete'
                          ? Icons.check_circle
                          : Icons.arrow_forward,
                      color: edge.goto == '_complete'
                          ? Colors.green
                          : Colors.blue,
                    ),
                    title: Text(
                      edge.goto == '_complete' ? 'Complete Flow' : edge.goto,
                    ),
                    subtitle: edge.when != null
                        ? Text(
                            'When: ${edge.when!.entries.map((e) => "${e.key} = ${e.value}").join(", ")}',
                          )
                        : const Text('Always (default)'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteEdge(entry.key),
                    ),
                  ),
                );
              })),

            const SizedBox(height: 24),

            // API Config Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'API Configuration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _editApiMapping,
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Mapping'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _apiEndpointController,
                      decoration: const InputDecoration(
                        labelText: 'API Endpoint',
                        hintText: '/api/user-details/save',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (_step.api?.mapping.isNotEmpty ?? false) ...[
                      const SizedBox(height: 16),
                      const Text('Mappings:'),
                      ...(_step.api!.mapping.entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Text('• ${e.key} → ${e.value}'),
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAndReturn,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text('Save Step', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _apiEndpointController.dispose();
    super.dispose();
  }
}
