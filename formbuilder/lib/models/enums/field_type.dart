enum FieldType {
  radio,
  dropdown,
  text,
  date,
  grid,
  cardSelection,
  dynamicList,
  modalTrigger,
}

extension FieldTypeExtension on FieldType {
  String toShortString() {
    return toString().split('.').last;
  }

  bool get isSelectionType {
    return this == FieldType.radio ||
        this == FieldType.dropdown ||
        this == FieldType.grid ||
        this == FieldType.cardSelection;
  }
}

extension StringToFieldType on String {
  FieldType toFieldType() {
    switch (this) {
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
      case 'cardSelection':
        return FieldType.cardSelection;
      case 'dynamicList':
        return FieldType.dynamicList;
      case 'modalTrigger':
        return FieldType.modalTrigger;
      default:
        throw ArgumentError('Unknown field type: $this');
    }
  }
}
