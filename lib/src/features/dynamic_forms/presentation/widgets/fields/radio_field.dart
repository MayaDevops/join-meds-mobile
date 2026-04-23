import 'package:flutter/material.dart';
import '../../../domain/models/field_config.dart';

/// Radio button field widget
/// Based on patterns from b_pharm_degree_ongoing.dart
class RadioField extends StatelessWidget {
  final FieldConfig config;
  final String? value;
  final ValueChanged<String?> onChanged;

  const RadioField({
    super.key,
    required this.config,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final layout = config.layout ?? 'wrap'; // wrap, row, column
    final options = config.options ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          config.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        // Radio options
        _buildRadioLayout(layout, options),

        // Error text if required and empty
        if (config.required && (value == null || value!.isEmpty))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              config.validation?.requiredMessage ?? 'This field is required',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRadioLayout(String layout, List<FieldOption> options) {
    // Use Column layout for container-based selection (stacked vertically)
    return Column(
      children: options.map((option) => _buildRadioOption(option)).toList(),
    );
  }

  Widget _buildRadioOption(FieldOption option) {
    final isSelected = value == option.value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onChanged(option.value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Radio circle indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xff00A4E1) : Colors.grey.shade400,
                    width: 2,
                  ),
                  color: Colors.white,
                ),
                child: isSelected
                    ? Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xff00A4E1),
                    ),
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 12),
              // Label text
              Expanded(
                child: Text(
                  option.label,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}