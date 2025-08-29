import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyHeadingText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? backgroundColor;
  final Color? textColor;
  final bool underline; // ✅ new flag

  const MyHeadingText({
    Key? key,
    required this.text,
    required this.fontSize,
    required this.backgroundColor,
    required this.textColor,
    this.underline = false, // ✅ default false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.quantico(
        color: textColor,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        decoration: underline ? TextDecoration.underline : TextDecoration.none, // ✅ underline toggle
      ),
    );
  }
}
