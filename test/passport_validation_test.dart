import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:untitled/src/core/utils/validators.dart';
import 'package:untitled/src/shared/widgets/inputs/custom_text_field.dart';

void main() {
  group('Validators.passportNumber', () {
    test('accepts real-world passport formats', () {
      for (final valid in [
        'A1234567', // India
        'K9876543',
        '123456789', // US (digits only is allowed)
        'GB1234567',
        'ab12cd', // lowercase is allowed by the pattern
        'X0Y',
        'A' * 20,
      ]) {
        expect(Validators.passportNumber(valid), isNull, reason: valid);
      }
    });

    test('allows the field to be left empty (it is optional)', () {
      expect(Validators.passportNumber(''), isNull);
      expect(Validators.passportNumber('   '), isNull);
      expect(Validators.passportNumber(null), isNull);
    });

    test('rejects invalid values', () {
      for (final invalid in [
        'A1', // too short
        'A' * 21, // too long
        '000', // only zeros
        '0000000',
        'A123-456', // symbols
        'A123 456', // inner space
        'A1234567!',
      ]) {
        expect(Validators.passportNumber(invalid), isNotNull, reason: invalid);
      }
    });

    test('ignores surrounding whitespace, matching what is submitted', () {
      expect(Validators.passportNumber('  A1234567  '), isNull);
    });
  });

  testWidgets('passport field lets users type letters and blocks symbols',
      (tester) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: CustomTextField(
              controller: controller,
              hintText: 'Passport Number (Optional)',
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                LengthLimitingTextInputFormatter(20),
              ],
              validator: Validators.passportNumber,
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'A12-34 567');
    expect(controller.text, 'A1234567');
    expect(formKey.currentState!.validate(), isTrue);

    await tester.enterText(find.byType(TextFormField), 'Z' * 25);
    expect(controller.text.length, 20);

    await tester.enterText(find.byType(TextFormField), '00');
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(
      find.text('Enter a valid passport number (3-20 letters and numbers)'),
      findsOneWidget,
    );
  });
}
