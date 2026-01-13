import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/step_config.dart';
import '../../../domain/models/field_config.dart';
import '../../providers/form_state_provider.dart';
import '../dynamic_field_builder.dart';

/// Renders a single form step based on its configuration
class FormStepRenderer extends StatelessWidget {
  final StepConfig step;

  const FormStepRenderer({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instructions
          if (step.instructions != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xff00A4E1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xff00A4E1).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xff00A4E1),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step.instructions!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff606060),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // // Subtitle
          // if (step.subtitle != null) ...[
          //   Text(
          //     step.subtitle!,
          //     style: const TextStyle(
          //       fontSize: 16,
          //       color: Color(0xff606060),
          //     ),
          //   ),
          //   const SizedBox(height: 20),
          // ],

          // Fields
          ...step.fields.map((field) => _buildField(context, field)).toList(),
        ],
      ),
    );
  }

  Widget _buildField(BuildContext context, FieldConfig field) {
    return Consumer<FormStateProvider>(
      builder: (context, provider, child) {
        final value = provider.getFieldValue(field.fieldId);
        final error = provider.getFieldError(field.fieldId);

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Field widget
              DynamicFieldBuilder(
                config: field,
                value: value,
                onChanged: (newValue) {
                  provider.updateField(field.fieldId, newValue);
                },
                dropdownOptions: field.dataSource != null
                    ? provider.getSharedData(field.dataSource!.path ?? '')
                    : null,
              ),

              // Error message
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    error,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
