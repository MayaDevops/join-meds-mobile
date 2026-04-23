import 'package:flutter/material.dart';
import 'package:untitled/constants/constant.dart';

// Forms main heading
class FormsMainHead extends StatelessWidget {
  final String text;
  const FormsMainHead({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(text,style: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.w500,
      ),),
    );
  }
}

// input fields label headings
class LabelText extends StatelessWidget {
  final String labelText;
  const LabelText({super.key,  required this.labelText});

  @override
  Widget build(BuildContext context) {
    return Container(

      alignment: Alignment.bottomLeft,
      child: Text(
        labelText,
        style:
        TextStyle(fontSize: 20, fontWeight: FontWeight.w500,color: inputBorderClr),
      ),
    );
  }
}