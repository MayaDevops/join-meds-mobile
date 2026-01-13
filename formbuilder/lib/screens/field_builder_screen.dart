import 'package:flutter/material.dart';
import '../models/field_config.dart';
import '../models/enums/field_type.dart';

class FieldBuilderScreen extends StatefulWidget {
  final String professionId;
  final String flowId;
  final String stepId;
  final FieldConfig? initialField;
  final Function(FieldConfig) onFieldCreated;

  const FieldBuilderScreen({
    super.key,
    required this.professionId,
    required this.flowId,
    required this.stepId,
    this.initialField,
    required this.onFieldCreated,
  });

  @override
  State<FieldBuilderScreen> createState() => _FieldBuilderScreenState();
}

class _FieldBuilderScreenState extends State<FieldBuilderScreen> {
  final TextEditingController _fieldIdController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();
  final TextEditingController _apiMappingController = TextEditingController();

  FieldType _selectedFieldType = FieldType.text;
  bool _required = false;
  bool _searchable = false;
  List<FieldOption> _options = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialField != null) {
      final field = widget.initialField!;
      _fieldIdController.text = field.fieldId;
      _labelController.text = field.label;
      _hintController.text = field.hint ?? '';
      _apiMappingController.text = field.apiMapping ?? '';
      _selectedFieldType = field.fieldType;
      _required = field.required;
      _searchable = field.searchable;
      _options = field.options != null ? List.from(field.options!) : [];
    }
  }

  void _addOption() async {
    final valueController = TextEditingController();
    final labelController = TextEditingController();
    final iconController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Option'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: valueController,
                decoration: const InputDecoration(
                  labelText: 'Value',
                  hintText: 'e.g., ongoing',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: 'Label',
                  hintText: 'e.g., Degree Ongoing',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                  labelText: 'Icon (optional)',
                  hintText: 'e.g., menu_book',
                ),
              ),
            ],
          ),
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
    );

    if (result == true) {
      final value = valueController.text.trim();
      final label = labelController.text.trim();
      final icon = iconController.text.trim();

      if (value.isEmpty || label.isEmpty) return;

      setState(() {
        _options.add(FieldOption(
          value: value,
          label: label,
          icon: icon.isEmpty ? null : icon,
        ));
      });
    }
  }

  void _editOption(int index) async {
    final option = _options[index];
    final valueController = TextEditingController(text: option.value);
    final labelController = TextEditingController(text: option.label);
    final iconController = TextEditingController(text: option.icon ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Option'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: 'Value'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Label'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                  labelText: 'Icon (optional)',
                ),
              ),
            ],
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
      setState(() {
        _options[index] = FieldOption(
          value: valueController.text.trim(),
          label: labelController.text.trim(),
          icon: iconController.text.trim().isEmpty
              ? null
              : iconController.text.trim(),
        );
      });
    }
  }

  void _deleteOption(int index) {
    setState(() {
      _options.removeAt(index);
    });
  }

  void _moveOptionUp(int index) {
    if (index == 0) return;
    setState(() {
      final temp = _options[index];
      _options[index] = _options[index - 1];
      _options[index - 1] = temp;
    });
  }

  void _moveOptionDown(int index) {
    if (index >= _options.length - 1) return;
    setState(() {
      final temp = _options[index];
      _options[index] = _options[index + 1];
      _options[index + 1] = temp;
    });
  }

  void _saveField() {
    final fieldId = _fieldIdController.text.trim();
    final label = _labelController.text.trim();

    if (fieldId.isEmpty || label.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Field ID and Label are required')),
      );
      return;
    }

    // Validate that selection fields have options
    if (_selectedFieldType.isSelectionType && _options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selection fields must have at least one option')),
      );
      return;
    }

    final field = FieldConfig(
      fieldId: fieldId,
      fieldType: _selectedFieldType,
      label: label,
      hint: _hintController.text.trim().isEmpty
          ? null
          : _hintController.text.trim(),
      required: _required,
      searchable: _searchable,
      options: _selectedFieldType.isSelectionType ? _options : null,
      apiMapping: _apiMappingController.text.trim().isEmpty
          ? null
          : _apiMappingController.text.trim(),
    );

    widget.onFieldCreated(field);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialField == null ? 'Add Field' : 'Edit Field'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveField,
            tooltip: 'Save Field',
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
                      'Field Properties',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<FieldType>(
                      value: _selectedFieldType,
                      decoration: const InputDecoration(
                        labelText: 'Field Type',
                        border: OutlineInputBorder(),
                      ),
                      items: FieldType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.toShortString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFieldType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _fieldIdController,
                      decoration: const InputDecoration(
                        labelText: 'Field ID',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., academicStatus',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _labelController,
                      decoration: const InputDecoration(
                        labelText: 'Label',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Academic Status',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _hintController,
                      decoration: const InputDecoration(
                        labelText: 'Hint (optional)',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Select your status',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _apiMappingController,
                      decoration: const InputDecoration(
                        labelText: 'API Mapping (optional)',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., academic_status',
                      ),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Required'),
                      value: _required,
                      onChanged: (value) {
                        setState(() {
                          _required = value!;
                        });
                      },
                    ),
                    if (_selectedFieldType == FieldType.dropdown)
                      CheckboxListTile(
                        title: const Text('Searchable'),
                        value: _searchable,
                        onChanged: (value) {
                          setState(() {
                            _searchable = value!;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
            if (_selectedFieldType.isSelectionType) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text(
                    'Options',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _addOption,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Option'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_options.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No options yet. Add an option to get started.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _options.length,
                  itemBuilder: (context, index) {
                    final option = _options[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          option.label,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Value: ${option.value}${option.icon != null ? " | Icon: ${option.icon}" : ""}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_upward),
                              onPressed:
                                  index == 0 ? null : () => _moveOptionUp(index),
                              tooltip: 'Move Up',
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_downward),
                              onPressed: index >= _options.length - 1
                                  ? null
                                  : () => _moveOptionDown(index),
                              tooltip: 'Move Down',
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editOption(index),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteOption(index),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveField,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Save Field', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fieldIdController.dispose();
    _labelController.dispose();
    _hintController.dispose();
    _apiMappingController.dispose();
    super.dispose();
  }
}
