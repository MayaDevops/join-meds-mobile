import 'package:flutter/material.dart';
import '../../../domain/models/field_config.dart';

/// Card selection field widget for large card-based options
/// Based on academic status screens (b_pharm_academic_status.dart)
class CardSelectionField extends StatelessWidget {
  final FieldConfig config;
  final String? value;
  final ValueChanged<String?> onChanged;

  const CardSelectionField({
    super.key,
    required this.config,
    this.value,
    required this.onChanged,
  });

  IconData _getIcon(String? iconName) {
    if (iconName == null) return Icons.check_circle;

    switch (iconName.toLowerCase()) {
      case 'menu_book':
        return Icons.account_balance_outlined;
      case 'school':
        return Icons.edit_document;
      case 'work':
        return Icons.work_outline;
      case 'assignment':
        return Icons.assignment_outlined;
      case 'verified':
        return Icons.verified_outlined;
      case 'done':
        return Icons.done_outline;
      case 'description':
        return Icons.description_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final options = config.options ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label/Title
        if (config.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              config.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

        // Subtitle
        if (config.hint != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              config.hint!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

        // Cards
        Row(
          children: options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < options.length - 1 ? 12 : 0,
                ),
                child: _buildCard(option, screenWidth),
              ),
            );
          }).toList(),
        ),

        // Error text
        if (config.required && (value == null || value!.isEmpty))
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              config.validation?.requiredMessage ?? 'Please select an option',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCard(FieldOption option, double screenWidth) {
    final isSelected = value == option.value;

    return InkWell(
      onTap: () => onChanged(option.value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xff00A4E1) : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xff00A4E1).withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              _getIcon(option.icon),
              size: 48,
              color: isSelected ? const Color(0xff00A4E1) : Colors.grey.shade700,
            ),
            const SizedBox(height: 16),

            // Label
            Text(
              option.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xff00A4E1) : Colors.black87,
                height: 1.3,
              ),
            ),

            // Description (if provided)
            if (option.description != null) ...[
              const SizedBox(height: 6),
              Text(
                option.description!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}