import 'package:app/utils/color_constants.dart';
import 'package:flutter/material.dart';

class maintTheme {
  maintTheme._();

  static ThemeData defaultTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xffFAFAFF),

    textSelectionTheme: TextSelectionThemeData(
      selectionColor: maintColor.primaryComplement,
      selectionHandleColor: maintColor.primaryComplement,
    ),
  );
}
