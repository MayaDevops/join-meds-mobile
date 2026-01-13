enum ActionType {
  navigate,
  showModal,
  conditionalNavigate,
  apiCall,
  setField,
  showMessage,
  goBack,
}

extension ActionTypeExtension on ActionType {
  String toShortString() {
    return toString().split('.').last;
  }
}

extension StringToActionType on String {
  ActionType toActionType() {
    switch (this) {
      case 'navigate':
        return ActionType.navigate;
      case 'showModal':
        return ActionType.showModal;
      case 'conditionalNavigate':
        return ActionType.conditionalNavigate;
      case 'apiCall':
        return ActionType.apiCall;
      case 'setField':
        return ActionType.setField;
      case 'showMessage':
        return ActionType.showMessage;
      case 'goBack':
        return ActionType.goBack;
      default:
        throw ArgumentError('Unknown action type: $this');
    }
  }
}
