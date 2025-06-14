import 'package:flutter/material.dart';
import '../constants/constant.dart';



class MainButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const MainButton({super.key, required this.text,required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return  ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.all(15),),
            backgroundColor: WidgetStatePropertyAll(mainBlue),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),),
          ),

          child: Text(text,style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
          ),),
    );
  }
}




