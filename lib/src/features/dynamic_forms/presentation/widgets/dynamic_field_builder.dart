import 'package:flutter/material.dart';
import '../../domain/models/field_config.dart';
import '../../domain/enums/field_type.dart';
import 'fields/radio_field.dart';
import 'fields/text_field_widget.dart';
import 'fields/date_field.dart';
import 'fields/dropdown_field.dart';
import 'fields/card_selection_field.dart';
import 'fields/grid_field.dart';
import 'fields/dynamic_list_field.dart';

/// Factory widget that builds the appropriate field widget based on FieldConfig
class DynamicFieldBuilder extends StatelessWidget {
  final FieldConfig config;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final List<String>? dropdownOptions; // For dynamic data from Firebase

  const DynamicFieldBuilder({
    super.key,
    required this.config,
    this.value,
    required this.onChanged,
    this.dropdownOptions,
  });

  @override
  Widget build(BuildContext context) {
    // Check visibility condition
    if (!config.visible) {
      return const SizedBox.shrink();
    }

    return _buildFieldWidget();
  }

  Widget _buildFieldWidget() {
    switch (config.fieldType) {
      case FieldType.radio:
        return RadioField(
          config: config,
          value: value as String?,
          onChanged: (val) => onChanged(val),
        );

      case FieldType.text:
        return DynamicTextField(
          config: config,
          value: value as String?,
          onChanged: (val) => onChanged(val),
        );

      case FieldType.date:
        return DateField(
          config: config,
          value: value as DateTime?,
          onChanged: (val) => onChanged(val),
        );

      case FieldType.dropdown:
        return DropdownField(
          config: config,
          value: value as String?,
          onChanged: (val) => onChanged(val),
          options: dropdownOptions,
        );

      case FieldType.cardSelection:
        return CardSelectionField(
          config: config,
          value: value as String?,
          onChanged: (val) => onChanged(val),
        );

      case FieldType.grid:
        return GridField(
          config: config,
          value: value as String?,
          onChanged: (val) => onChanged(val),
          allowCustomInput: config.options?.any((opt) => opt.value == 'Others') ?? false,
        );

      case FieldType.dynamicList:
        return DynamicListField(
          config: config,
          values: value as List<Map<String, dynamic>>?,
          onChanged: (val) => onChanged(val),
        );

      case FieldType.modalTrigger:
        // Modal triggers are handled by navigation logic, not as form fields
        return const SizedBox.shrink();

      default:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Unsupported field type: ${config.fieldType.toShortString()}',
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
        );
    }
  }
}
