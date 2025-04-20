import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/constant.dart';


class OtpSizedBox extends StatelessWidget {
  final Widget child;
  const OtpSizedBox({
    super.key, required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65,
      width: 55,
      child: child,
    );
  }
}

class OtpField extends StatelessWidget {

  const OtpField({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: inputBorderClr,
      ),
      onChanged: (value) {
        if (value.length == 1) {
          FocusScope.of(context).nextFocus();
        }
      },
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      inputFormatters: [
        LengthLimitingTextInputFormatter(1),
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        enabledBorder: enabledBorder,
        focusedErrorBorder: focusedErrorBorder,
      ),
    );
  }
}
