import 'package:flutter/material.dart';
import '../constants/constant.dart';

class TextFormWidget extends StatelessWidget {
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final String hintText;
  final TextInputType keyboardType;
  final bool readOnly;
  final bool obscureText;
  final Widget? suffixIcon;
  final void Function(String)? onChanged; // simple and optional

  const TextFormWidget({
    super.key,
    required this.controller,
    this.validator,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.suffixIcon,
    this.obscureText = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      obscureText: obscureText,
      onChanged: onChanged,
      cursorColor: inputBorderClr,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        hintText: hintText,
        hintStyle: hintStyle,
        enabledBorder: enabledBorder,
        focusedBorder: focusedBorder,
        errorStyle: errorStyle,
        errorBorder: errorBorder,
        focusedErrorBorder: focusedErrorBorder,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
