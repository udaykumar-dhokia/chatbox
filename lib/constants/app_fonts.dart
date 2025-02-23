import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  static TextStyle primaryFont({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    Color color = Colors.black,
  }) {
    return GoogleFonts.mulish(
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }

  static TextStyle secondaryFont({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w300,
    Color color = Colors.grey,
  }) {
    return GoogleFonts.roboto(
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }

  static TextStyle codeFont({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w300,
    Color color = Colors.grey,
  }) {
    return GoogleFonts.firaCode(
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}
