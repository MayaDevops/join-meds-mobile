/// Defines conditional operators for evaluating form data
enum OperatorType {
  /// Check if field value equals a specific value
  /// Example: academicStatus equals "completed"
  equals,

  /// Check if field value does not equal a specific value
  /// Example: postGradStatus notEquals "PG-Holder"
  notEquals,

  /// Check if field value contains a substring
  /// Example: specialization contains "Cardio"
  contains,

  /// Check if field value does not contain a substring
  /// Example: university notContains "AIIMS"
  notContains,

  /// Check if field is empty or null
  /// Example: workExperience isEmpty
  isEmpty,

  /// Check if field is not empty
  /// Example: organisation isNotEmpty
  isNotEmpty,

  /// Check if numeric value is greater than
  /// Example: experience_years greaterThan 5
  greaterThan,

  /// Check if numeric value is less than
  /// Example: current_year lessThan 4
  lessThan,

  /// Check if numeric value is greater than or equal
  /// Example: age greaterThanOrEqual 18
  greaterThanOrEqual,

  /// Check if numeric value is less than or equal
  /// Example: year lessThanOrEqual 6
  lessThanOrEqual,

  /// Check if value is in a list
  /// Example: profession inList ["Doctor", "Nurse"]
  inList,

  /// Check if value is not in a list
  /// Example: courseType notInList ["Diploma"]
  notInList,
}

/// Extension to convert string to OperatorType enum
extension OperatorTypeExtension on String {
  OperatorType toOperatorType() {
    switch (toLowerCase()) {
      case 'equals':
      case '==':
        return OperatorType.equals;
      case 'notequals':
      case 'not_equals':
      case '!=':
        return OperatorType.notEquals;
      case 'contains':
        return OperatorType.contains;
      case 'notcontains':
      case 'not_contains':
        return OperatorType.notContains;
      case 'isempty':
      case 'is_empty':
        return OperatorType.isEmpty;
      case 'isnotempty':
      case 'is_not_empty':
        return OperatorType.isNotEmpty;
      case 'greaterthan':
      case 'greater_than':
      case '>':
        return OperatorType.greaterThan;
      case 'lessthan':
      case 'less_than':
      case '<':
        return OperatorType.lessThan;
      case 'greaterthanorequal':
      case 'greater_than_or_equal':
      case '>=':
        return OperatorType.greaterThanOrEqual;
      case 'lessthanorequal':
      case 'less_than_or_equal':
      case '<=':
        return OperatorType.lessThanOrEqual;
      case 'inlist':
      case 'in_list':
      case 'in':
        return OperatorType.inList;
      case 'notinlist':
      case 'not_in_list':
      case 'notin':
        return OperatorType.notInList;
      default:
        throw ArgumentError('Unknown operator type: $this');
    }
  }
}

/// Extension to convert OperatorType to string
extension OperatorTypeToString on OperatorType {
  String toShortString() {
    return toString().split('.').last;
  }

  /// Get symbolic representation
  String toSymbol() {
    switch (this) {
      case OperatorType.equals:
        return '==';
      case OperatorType.notEquals:
        return '!=';
      case OperatorType.greaterThan:
        return '>';
      case OperatorType.lessThan:
        return '<';
      case OperatorType.greaterThanOrEqual:
        return '>=';
      case OperatorType.lessThanOrEqual:
        return '<=';
      default:
        return toShortString();
    }
  }
}
