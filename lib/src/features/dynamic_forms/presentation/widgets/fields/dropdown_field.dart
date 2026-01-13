import 'package:flutter/material.dart';
import '../../../domain/models/field_config.dart';

/// Dropdown field widget with search support
/// Based on university selection patterns from b_pharm_degree_ongoing.dart
class DropdownField extends StatefulWidget {
  final FieldConfig config;
  final String? value;
  final ValueChanged<String?> onChanged;
  final List<String>? options; // For dynamic data from Firebase

  const DropdownField({
    super.key,
    required this.config,
    this.value,
    required this.onChanged,
    this.options,
  });

  @override
  State<DropdownField> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<DropdownField> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  void didUpdateWidget(DropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _selectedValue = widget.value;
    }
  }

  List<DropdownMenuEntry<String>> _getDropdownEntries() {
    // Use dynamic options if provided, otherwise use config options
    if (widget.options != null && widget.options!.isNotEmpty) {
      return widget.options!
          .map((option) => DropdownMenuEntry<String>(
        value: option,
        label: option,
      ))
          .toList();
    }

    // Use config options
    if (widget.config.options != null) {
      return widget.config.options!
          .map((option) => DropdownMenuEntry<String>(
        value: option.value,
        label: option.label,
      ))
          .toList();
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    final entries = _getDropdownEntries();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.config.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.config.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ),

        // Dropdown
        DropdownMenu<String>(
          width: MediaQuery.of(context).size.width - 32,
          enableSearch: widget.config.searchable,
          enableFilter: widget.config.searchable,
          hintText: widget.config.hint ?? 'Select ${widget.config.label}',
          initialSelection: _selectedValue,
          textStyle: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
          ),
          trailingIcon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey.shade600,
          ),
          selectedTrailingIcon: const Icon(
            Icons.keyboard_arrow_up,
            color: Color(0xff00A4E1),
          ),
          onSelected: (value) {
            setState(() {
              _selectedValue = value;
            });
            widget.onChanged(value);
          },
          dropdownMenuEntries: entries,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xff00A4E1),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
          ),
        ),

        // Error text
        if (widget.config.required && (_selectedValue == null || _selectedValue!.isEmpty))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.config.validation?.requiredMessage ?? 'This field is required',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}