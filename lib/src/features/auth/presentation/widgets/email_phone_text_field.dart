import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_text_field.dart';

class EmailPhoneTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String) onChanged;
  final bool isPhoneNumber;

  const EmailPhoneTextField({
    super.key,
    required this.controller,
    required this.validator,
    required this.onChanged,
    this.isPhoneNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: isPhoneNumber
          ? 'Enter 10 digit phone number'
          : 'Phone Number',
      keyboardType:
          isPhoneNumber ? TextInputType.phone : TextInputType.emailAddress,
      onChanged: onChanged,
      inputFormatters: isPhoneNumber
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ]
          : null,
      prefixIcon: isPhoneNumber
          ? Padding(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+91',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      color: const Color(0xFF666666),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 24,
                    color: const Color(0xFFE0E0E0),
                  ),
                ],
              ),
            )
          : null,
      validator: validator,
    );
  }
}
