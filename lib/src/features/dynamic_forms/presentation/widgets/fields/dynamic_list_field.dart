import 'package:flutter/material.dart';
import '../../../domain/models/field_config.dart';
import '../../../domain/enums/field_type.dart';
import 'radio_field.dart';
import 'text_field_widget.dart';
import 'date_field.dart';
import 'dropdown_field.dart';

/// Dynamic list field for repeating form sections
/// Based on work experience patterns from nurse_work_experience.dart
class DynamicListField extends StatefulWidget {
  final FieldConfig config;
  final List<Map<String, dynamic>>? values;
  final ValueChanged<List<Map<String, dynamic>>> onChanged;

  const DynamicListField({
    super.key,
    required this.config,
    this.values,
    required this.onChanged,
  });

  @override
  State<DynamicListField> createState() => _DynamicListFieldState();
}

class _DynamicListFieldState extends State<DynamicListField> {
  late List<Map<String, dynamic>> _entries;
  late List<GlobalKey<FormState>> _formKeys;

  @override
  void initState() {
    super.initState();
    _entries = widget.values?.isNotEmpty == true
        ? List.from(widget.values!)
        : [_createEmptyEntry()];
    _formKeys = List.generate(_entries.length, (_) => GlobalKey<FormState>());
  }

  Map<String, dynamic> _createEmptyEntry() {
    final entry = <String, dynamic>{};

    // Initialize all template fields with default values
    if (widget.config.template != null) {
      for (final field in widget.config.template!) {
        entry[field.fieldId] = field.defaultValue;
      }
    }

    return entry;
  }

  void _addEntry() {
    setState(() {
      _entries.add(_createEmptyEntry());
      _formKeys.add(GlobalKey<FormState>());
    });
    widget.onChanged(_entries);
  }

  void _removeEntry(int index) {
    if (_entries.length > (widget.config.minEntries ?? 1)) {
      setState(() {
        _entries.removeAt(index);
        _formKeys.removeAt(index);
      });
      widget.onChanged(_entries);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'At least ${widget.config.minEntries ?? 1} entry is required',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateEntry(int index, String fieldId, dynamic value) {
    setState(() {
      _entries[index][fieldId] = value;
    });
    widget.onChanged(_entries);
  }

  bool validateAll() {
    bool isValid = true;
    for (final key in _formKeys) {
      if (key.currentState?.validate() == false) {
        isValid = false;
      }
    }
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    final maxEntries = widget.config.maxEntries;
    final canAddMore = maxEntries == null || _entries.length < maxEntries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Entries list (reversed display order - newest first)
        ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _entries.length,
          itemBuilder: (context, index) {
            // Reverse the display order
            final displayIndex = _entries.length - 1 - index;
            final entryNumber = _entries.length - displayIndex;
            return _buildEntryCard(displayIndex, entryNumber);
          },
        ),

        // Add more button
        if (canAddMore) ...[
          const SizedBox(height: 16),
          InkWell(
            onTap: _addEntry,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xff00A4E1),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.config.addButtonText ?? 'Add More',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xff00A4E1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEntryCard(int index, int entryNumber) {
    return Form(
      key: _formKeys[index],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with entry number and remove button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.config.label} $entryNumber',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (_entries.length > (widget.config.minEntries ?? 1))
                OutlinedButton.icon(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    size: 18,
                    color: Colors.grey.shade700,
                  ),
                  label: Text(
                    'Remove',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300, width: 1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _removeEntry(index),
                ),
            ],
          ),

          // const SizedBox(height: 16),
          // Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 16),

          // Template fields
          ...widget.config.template?.map((fieldConfig) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildTemplateField(index, fieldConfig),
            );
          }).toList() ??
              [],
        ],
      ),
    );
  }

  Widget _buildTemplateField(int entryIndex, FieldConfig fieldConfig) {
    final currentValue = _entries[entryIndex][fieldConfig.fieldId];

    switch (fieldConfig.fieldType) {
      case FieldType.radio:
        return RadioField(
          config: fieldConfig,
          value: currentValue as String?,
          onChanged: (value) => _updateEntry(entryIndex, fieldConfig.fieldId, value),
        );

      case FieldType.text:
        return DynamicTextField(
          config: fieldConfig,
          value: currentValue as String?,
          onChanged: (value) => _updateEntry(entryIndex, fieldConfig.fieldId, value),
        );

      case FieldType.date:
        return DateField(
          config: fieldConfig,
          value: currentValue as DateTime?,
          onChanged: (value) => _updateEntry(entryIndex, fieldConfig.fieldId, value),
        );

      case FieldType.dropdown:
        return DropdownField(
          config: fieldConfig,
          value: currentValue as String?,
          onChanged: (value) => _updateEntry(entryIndex, fieldConfig.fieldId, value),
        );

      default:
        return Text('Unsupported field type: ${fieldConfig.fieldType}');
    }
  }
}