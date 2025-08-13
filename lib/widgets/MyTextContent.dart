import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Mytextcontent extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? backgroundColor;
  final Color? textColor;

  const Mytextcontent({
    Key? key,
    required this.text,
    required this.fontSize,
    required this.backgroundColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(6.0),
      child: Text(
        text,
        style: GoogleFonts.roboto(color: textColor,fontSize: fontSize,fontWeight: FontWeight.bold),
      ),
    );
  }
}
