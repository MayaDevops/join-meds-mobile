import 'package:flutter/material.dart';
import '../../../domain/models/field_config.dart';

/// Grid selection field widget
/// Based on doctor specialization selection patterns
class GridField extends StatelessWidget {
  final FieldConfig config;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool allowCustomInput;

  const GridField({
    super.key,
    required this.config,
    this.value,
    required this.onChanged,
    this.allowCustomInput = false,
  });

  @override
  Widget build(BuildContext context) {
    final options = config.options ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (config.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              config.label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        // List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            final isSelected = value == option.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onChanged(option.value),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 24,
                          width: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xff00A4E1)
                                  : Colors.grey.shade400,
                              width: isSelected ? 6 : 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            option.label,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Custom input field (if "Others" is selected and allowed)
        if (allowCustomInput && value == 'Others') ...[
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Specify ${config.label}',
              hintText: 'Enter custom ${config.label.toLowerCase()}',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xff606060),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xff606060),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xff00A4E1),
                  width: 2,
                ),
              ),
            ),
            onChanged: (customValue) {
              // Could emit custom value back to parent
              // For now, just validate
            },
            validator: (val) {
              if (value == 'Others' && (val == null || val.trim().isEmpty)) {
                return 'Please specify ${config.label.toLowerCase()}';
              }
              return null;
            },
          ),
        ],

        // Error text
        if (config.required && (value == null || value!.isEmpty))
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              config.validation?.requiredMessage ?? 'Please select an option',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}
