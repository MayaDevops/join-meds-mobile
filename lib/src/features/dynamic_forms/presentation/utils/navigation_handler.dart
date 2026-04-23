import 'package:flutter/material.dart';
import '../../domain/models/navigation_config.dart';
import '../../domain/enums/navigation_type.dart';
import '../../domain/enums/action_type.dart';

/// Handles navigation logic and conditional actions
class NavigationHandler {
  /// Evaluate a navigation rule and return the next step ID
  /// Returns null if navigation is not configured (auto-proceed to next step)
  static Future<String?> evaluateNavigation({
    NavigationConfig? navigation,
    required Map<String, dynamic> formData,
    required BuildContext context,
    Function(ModalConfig)? onShowModal,
  }) async {
    // If no navigation configured, return null to auto-proceed
    if (navigation == null) return null;

    switch (navigation.type) {
      case NavigationType.direct:
        return navigation.nextStep;

      case NavigationType.conditional:
        return await _handleConditionalNavigation(
          navigation,
          formData,
          context,
          onShowModal,
        );

      case NavigationType.modal:
        // Modal navigation handled separately
        return null;

      case NavigationType.none:
        return null;
    }
  }

  /// Handle conditional navigation with rules
  static Future<String?> _handleConditionalNavigation(
    NavigationConfig navigation,
    Map<String, dynamic> formData,
    BuildContext context,
    Function(ModalConfig)? onShowModal,
  ) async {
    if (navigation.rules == null) return navigation.defaultNextStep;

    // Evaluate rules in order
    for (final rule in navigation.rules!) {
      if (rule.condition.evaluate(formData)) {
        // Execute all actions for this rule
        for (final action in rule.actions) {
          final result = await executeAction(
            action,
            formData,
            context,
            onShowModal,
          );

          // If action returns a step ID, navigate there
          if (result is String) {
            return result;
          }
        }
        // Rule matched but no navigation action, stop here
        return null;
      }
    }

    // No rules matched, use default
    return navigation.defaultNextStep;
  }

  /// Execute a navigation action
  static Future<dynamic> executeAction(
    NavigationAction action,
    Map<String, dynamic> formData,
    BuildContext context,
    Function(ModalConfig)? onShowModal,
  ) async {
    switch (action.type) {
      case ActionType.navigate:
        return action.nextStep;

      case ActionType.showModal:
        if (action.modalConfig != null && onShowModal != null) {
          onShowModal(action.modalConfig!);
        }
        return null;

      case ActionType.conditionalNavigate:
        if (action.condition != null && action.condition!.evaluate(formData)) {
          return action.nextStep;
        }
        return null;

      case ActionType.setField:
        if (action.fieldId != null) {
          formData[action.fieldId!] = action.fieldValue;
        }
        return null;

      case ActionType.showMessage:
        if (action.message != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(action.message!)),
          );
        }
        return null;

      case ActionType.goBack:
        if (context.mounted) {
          Navigator.of(context).pop();
        }
        return null;

      case ActionType.apiCall:
        // API calls handled by FormStateProvider
        return null;
    }
  }

  /// Show modal bottom sheet and return result
  static Future<String?> showModal(
    BuildContext context,
    ModalConfig config,
  ) async {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      isDismissible: config.dismissible,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => _ModalBottomSheetContent(config: config),
    );
  }
}

/// Modal bottom sheet content widget
class _ModalBottomSheetContent extends StatefulWidget {
  final ModalConfig config;

  const _ModalBottomSheetContent({required this.config});

  @override
  State<_ModalBottomSheetContent> createState() =>
      _ModalBottomSheetContentState();
}

class _ModalBottomSheetContentState extends State<_ModalBottomSheetContent> {
  String? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            widget.config.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          // Subtitle
          if (widget.config.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.config.subtitle!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff606060),
              ),
            ),
          ],

          const Divider(height: 30),

          // Options
          ...widget.config.options.map((option) {
            final value = option['value'] ?? '';
            final label = option['label'] ?? '';

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedValue = value;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Radio<String>(
                      value: value,
                      groupValue: _selectedValue,
                      onChanged: (val) {
                        setState(() {
                          _selectedValue = val;
                        });
                      },
                      activeColor: const Color(0xff00A4E1),
                    ),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 20),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedValue != null
                  ? () {
                      Navigator.of(context).pop(_selectedValue);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff00A4E1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
