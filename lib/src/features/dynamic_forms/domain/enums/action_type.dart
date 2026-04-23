/// Defines types of actions that can be executed during navigation
enum ActionType {
  /// Navigate to a specific step
  /// Direct navigation to named step
  /// Example: Navigate to "degree_ongoing" step
  navigate,

  /// Show a modal bottom sheet
  /// Display modal for user selection
  /// Example: Show "Are you a PhD holder?" modal
  showModal,

  /// Conditional navigation based on field value
  /// Navigate only if condition is met
  /// Example: If postGradStatus == "PG-Holder" → navigate to speciality
  conditionalNavigate,

  /// Make an API call
  /// Submit data to backend
  /// Example: Save academic status to user profile
  apiCall,

  /// Update a field value
  /// Set or modify form data
  /// Example: Set internship status based on modal result
  setField,

  /// Show a toast or snackbar message
  /// Display feedback to user
  /// Example: "Data saved successfully"
  showMessage,

  /// Navigate back to previous step
  /// Return to last screen
  goBack,
}

/// Extension to convert string to ActionType enum
extension ActionTypeExtension on String {
  ActionType toActionType() {
    switch (toLowerCase()) {
      case 'navigate':
        return ActionType.navigate;
      case 'showmodal':
      case 'show_modal':
        return ActionType.showModal;
      case 'conditionalnavigate':
      case 'conditional_navigate':
        return ActionType.conditionalNavigate;
      case 'apicall':
      case 'api_call':
        return ActionType.apiCall;
      case 'setfield':
      case 'set_field':
        return ActionType.setField;
      case 'showmessage':
      case 'show_message':
        return ActionType.showMessage;
      case 'goback':
      case 'go_back':
        return ActionType.goBack;
      default:
        throw ArgumentError('Unknown action type: $this');
    }
  }
}

/// Extension to convert ActionType to string
extension ActionTypeToString on ActionType {
  String toShortString() {
    return toString().split('.').last;
  }
}
