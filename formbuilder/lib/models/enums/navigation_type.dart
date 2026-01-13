enum NavigationType {
  direct,
  conditional,
  modal,
  none,
}

extension NavigationTypeExtension on NavigationType {
  String toShortString() {
    return toString().split('.').last;
  }
}

extension StringToNavigationType on String {
  NavigationType toNavigationType() {
    switch (this) {
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
