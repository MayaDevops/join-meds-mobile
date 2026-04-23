/// Defines navigation behavior types for form steps
enum NavigationType {
  /// Direct navigation to a specific step
  /// Navigates immediately to the next step without conditions
  /// Example: Degree ongoing → Country preference
  direct,

  /// Conditional navigation based on field values
  /// Evaluates conditions before determining next step
  /// Example: If academic status = "completed" → show PG modal
  conditional,

  /// Triggers a modal dialog for user input
  /// Shows bottom sheet and uses result for next navigation
  /// Example: "Are you a Post Graduate?" modal
  modal,

  /// No navigation (final step or intermediate action)
  /// Used when step doesn't navigate anywhere
  none,
}

/// Extension to convert string to NavigationType enum
extension NavigationTypeExtension on String {
  NavigationType toNavigationType() {
    switch (toLowerCase()) {
      case 'direct':
        return NavigationType.direct;
      case 'conditional':
        return NavigationType.conditional;
      case 'modal':
        return NavigationType.modal;
      case 'none':
        return NavigationType.none;
      default:
        throw ArgumentError('Unknown navigation type: $this');
    }
  }
}

/// Extension to convert NavigationType to string
extension NavigationTypeToString on NavigationType {
  String toShortString() {
    return toString().split('.').last;
  }
}
