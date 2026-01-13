/// Defines all supported field types in the dynamic form system
enum FieldType {
  /// Radio button selection (single choice)
  /// Used for: Academic year selection, experience type
  /// Example: 1st Year, 2nd Year, 3rd Year, 4th Year
  radio,

  /// Searchable dropdown menu
  /// Used for: University selection (700+ options)
  /// Supports search and filter functionality
  dropdown,

  /// Text input field with validation
  /// Used for: Organization name, custom specialization
  /// Supports pattern validation, min/max length
  text,

  /// Date picker field
  /// Used for: From/To dates in work experience
  /// Supports min/max date constraints
  date,

  /// Grid layout for multiple options
  /// Used for: Doctor specializations
  /// Displays options in a grid format
  grid,

  /// Large card selection UI
  /// Used for: Academic status (Ongoing vs Completed)
  /// Shows icon and label in card format
  cardSelection,

  /// Dynamic list of repeating fields
  /// Used for: Work experience entries
  /// Allows add/remove of multiple entries
  dynamicList,

  /// Modal bottom sheet trigger
  /// Used for: Yes/No questions, PG status
  /// Triggers a bottom sheet modal
  modalTrigger,
}

/// Extension to convert string to FieldType enum
extension FieldTypeExtension on String {
  FieldType toFieldType() {
    switch (toLowerCase()) {
      case 'radio':
        return FieldType.radio;
      case 'dropdown':
        return FieldType.dropdown;
      case 'text':
        return FieldType.text;
      case 'date':
        return FieldType.date;
      case 'grid':
        return FieldType.grid;
      case 'cardselection':
      case 'card_selection':
        return FieldType.cardSelection;
      case 'dynamiclist':
      case 'dynamic_list':
        return FieldType.dynamicList;
      case 'modaltrigger':
      case 'modal_trigger':
        return FieldType.modalTrigger;
      default:
        throw ArgumentError('Unknown field type: $this');
    }
  }
}

/// Extension to convert FieldType to string
extension FieldTypeToString on FieldType {
  String toShortString() {
    return toString().split('.').last;
  }
}
