
import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: Color(0xFF00E2D4), // Light Gray
    scaffoldBackgroundColor: Color(0xFFFFFFFF), // White
    cardColor: Color(0xFFFCFCFD), // Very Light Gray
    textTheme: TextTheme(
      displayLarge: TextStyle(color: Color(0xFF000000), fontSize: 24, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Color(0xFF000000), fontSize: 16),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Color(0xFF00E2D4), // Button color cyan
      textTheme: ButtonTextTheme.primary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF00E2D4), // AppBar color cyan
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFFFFFFFF)), // Icon color white
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF00E2D4), // FAB color cyan
    ), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Color(0xFF00E1D3)).copyWith(surface: Color(0xFFF6F7F9)),
  );
}
