import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: Color.fromRGBO(26, 83, 92, 1), // Midnight Green
    scaffoldBackgroundColor: Colors.white, // Mint Cream
    cardColor: Color.fromRGBO(247, 255, 247, 1), // Mint Cream
    textTheme: TextTheme(
      displayLarge: TextStyle(color: Color.fromRGBO(26, 83, 92, 1), fontSize: 24, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Color.fromRGBO(26, 83, 92, 1), fontSize: 16),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Color.fromRGBO(78, 205, 196, 1), // Robin Egg Blue
      textTheme: ButtonTextTheme.primary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color.fromRGBO(78, 205, 196, 1), // Robin Egg Blue
      elevation: 0,
      iconTheme: IconThemeData(color: Color.fromRGBO(247, 255, 247, 1)), // Mint Cream
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color.fromRGBO(255, 107, 107, 1), // Light Red
    ), colorScheme: ColorScheme.light(
      primary: Color.fromRGBO(26, 83, 92, 1), // Midnight Green
      secondary: Color.fromRGBO(255, 230, 109, 1), // Naples Yellow
      surface: Color.fromRGBO(221, 224, 221, 1), // Mint Cream
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: Color.fromRGBO(26, 83, 92, 1), // Midnight Green
    scaffoldBackgroundColor: Colors.black, // AMOLED Black
    cardColor: Colors.black, // AMOLED Black
    textTheme: TextTheme(
      displayLarge: TextStyle(color: Color.fromRGBO(247, 255, 247, 1), fontSize: 24, fontWeight: FontWeight.bold), // Mint Cream
      bodyLarge: TextStyle(color: Color.fromRGBO(247, 255, 247, 1), fontSize: 16), // Mint Cream
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Color.fromRGBO(78, 205, 196, 1), // Robin Egg Blue
      textTheme: ButtonTextTheme.primary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color.fromRGBO(26, 83, 92, 1), // Midnight Green
      elevation: 0,
      iconTheme: IconThemeData(color: Color.fromRGBO(247, 255, 247, 1)), // Mint Cream
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color.fromRGBO(255, 107, 107, 1), // Light Red
    ), colorScheme: ColorScheme.dark(
      primary: Color.fromRGBO(26, 83, 92, 1), // Midnight Green
      secondary: Color.fromRGBO(255, 230, 109, 1), // Naples Yellow
      surface: Colors.black, // AMOLED Black
    ),
  );
}
