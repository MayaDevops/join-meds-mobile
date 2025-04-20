import 'package:flutter/material.dart';
import 'package:untitled/constants/constant.dart';


class TextFormWidget2 extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;

  const TextFormWidget2({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.suffixIcon,
    required this.keyboardType,
    required this.validator,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText, // ✅ Ensure obscureText is correctly applied
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
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
