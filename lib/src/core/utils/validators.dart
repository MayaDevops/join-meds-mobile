/// Form field validators shared across screens.
class Validators {
  Validators._();

  // Source - https://stackoverflow.com/a/40647805
  // Posted by Rob
  // Retrieved 2026-09-11, License - CC BY-SA 3.0
  //
  // 3-20 letters/digits, and not made up only of zeros.
  static final RegExp passportNumberPattern =
      RegExp(r'^(?!^0+$)[a-zA-Z0-9]{3,20}$');

  /// Passport number is optional: empty passes, anything else must match
  /// [passportNumberPattern].
  static String? passportNumber(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return null;

    if (!passportNumberPattern.hasMatch(input)) {
      return 'Enter a valid passport number (3-20 letters and numbers)';
    }
    return null;
  }
}
