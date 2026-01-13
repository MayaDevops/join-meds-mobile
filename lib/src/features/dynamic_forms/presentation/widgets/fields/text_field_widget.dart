import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/models/field_config.dart';

/// Text input field widget with validation
/// Based on patterns from nurse_work_experience.dart
class DynamicTextField extends StatelessWidget {
  final FieldConfig config;
  final String? value;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  const DynamicTextField({
    super.key,
    required this.config,
    this.value,
    required this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveController = controller ?? TextEditingController(text: value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (config.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              config.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ),

        // Text field
        TextFormField(
          controller: effectiveController,
          readOnly: config.readOnly,
          enabled: !config.readOnly,
          keyboardType: _getKeyboardType(),
          maxLines: config.maxLines ?? 1,
          minLines: config.minLines ?? 1,
          inputFormatters: _getInputFormatters(),
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: config.hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 15,
            ),
            filled: true,
            fillColor: config.readOnly ? Colors.grey[100] : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
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
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
          ),
          validator: (val) => _validate(val),
          onChanged: onChanged,
        ),
      ],
    );
  }

  TextInputType _getKeyboardType() {
    switch (config.keyboardType?.toLowerCase()) {
      case 'number':
        return TextInputType.number;
      case 'email':
        return TextInputType.emailAddress;
      case 'phone':
        return TextInputType.phone;
      case 'url':
        return TextInputType.url;
      case 'multiline':
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    final formatters = <TextInputFormatter>[];

    // Max length
    if (config.validation?.maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(config.validation!.maxLength));
    }

    // Pattern-based filtering
    if (config.validation?.pattern != null) {
      try {
        final regex = RegExp(config.validation!.pattern!);
        formatters.add(FilteringTextInputFormatter.allow(regex));
      } catch (e) {
        print('Invalid regex pattern: ${config.validation!.pattern}');
      }
    }

    return formatters;
  }

  String? _validate(String? val) {
    if (config.validation == null) return null;

    final validation = config.validation!;

    // Required validation
    if (validation.required && (val == null || val.trim().isEmpty)) {
      return validation.requiredMessage ??
          validation.errorMessage ??
          'This field is required';
    }

    if (val == null || val.isEmpty) return null;

    // Min length validation
    if (validation.minLength != null && val.length < validation.minLength!) {
      return validation.minLengthMessage ??
          validation.errorMessage ??
          'Minimum ${validation.minLength} characters required';
    }

    // Max length validation
    if (validation.maxLength != null && val.length > validation.maxLength!) {
      return validation.maxLengthMessage ??
          validation.errorMessage ??
          'Maximum ${validation.maxLength} characters allowed';
    }

    // Pattern validation
    if (validation.pattern != null) {
      try {
        final regex = RegExp(validation.pattern!);
        if (!regex.hasMatch(val)) {
          return validation.patternMessage ??
              validation.errorMessage ??
              'Invalid format';
        }
      } catch (e) {
        print('Invalid regex pattern: ${validation.pattern}');
      }
    }

    return null;
  }
}