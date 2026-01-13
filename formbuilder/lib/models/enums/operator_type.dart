enum OperatorType {
  equals,
  notEquals,
  contains,
  notContains,
  isEmpty,
  isNotEmpty,
  greaterThan,
  lessThan,
  greaterThanOrEqual,
  lessThanOrEqual,
  inList,
  notInList,
}

extension OperatorTypeExtension on OperatorType {
  String toShortString() {
    return toString().split('.').last;
  }
}

extension StringToOperatorType on String {
  OperatorType toOperatorType() {
    switch (this) {
      case 'equals':
        return OperatorType.equals;
      case 'notEquals':
        return OperatorType.notEquals;
      case 'contains':
        return OperatorType.contains;
      case 'notContains':
        return OperatorType.notContains;
      case 'isEmpty':
        return OperatorType.isEmpty;
      case 'isNotEmpty':
        return OperatorType.isNotEmpty;
      case 'greaterThan':
        return OperatorType.greaterThan;
      case 'lessThan':
        return OperatorType.lessThan;
      case 'greaterThanOrEqual':
        return OperatorType.greaterThanOrEqual;
      case 'lessThanOrEqual':
        return OperatorType.lessThanOrEqual;
      case 'inList':
        return OperatorType.inList;
      case 'notInList':
        return OperatorType.notInList;
      default:
        return OperatorType.equals;
    }
  }
}
