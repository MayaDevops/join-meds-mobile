import 'package:flutter/material.dart';


// colors
const Color mainBlue = Color(0xff00A4E1);
const Color inputBorderClr = Color(0xff606060);

// input fields borders

final enabledBorder = OutlineInputBorder(
borderSide: const BorderSide(color: inputBorderClr, width: 2.0),
borderRadius: BorderRadius.circular(10),
);

final focusedBorder = OutlineInputBorder(
  borderSide: const BorderSide(color: inputBorderClr, width: 2.0),
  borderRadius: BorderRadius.circular(10),
);

const hintStyle = TextStyle(
  color: inputBorderClr,
  fontSize: 16.0,
);

const errorStyle = TextStyle(fontSize: 15);

final errorBorder = OutlineInputBorder(
  borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
  borderRadius: BorderRadius.circular(10),
);

final focusedErrorBorder = OutlineInputBorder(
  borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
  borderRadius: BorderRadius.circular(10),
);

const subHeadForms = TextStyle(

  fontSize: 18,
  fontWeight: FontWeight.w500,
  color: inputBorderClr,
);

const appBarText = TextStyle(
    color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500);
