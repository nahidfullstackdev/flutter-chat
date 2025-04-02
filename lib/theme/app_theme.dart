import 'package:flutter/material.dart';
import 'package:flutter_chat/colors.dart';

class AppTheme {
  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderSide: BorderSide(color: color, width: 1.5),
    borderRadius: BorderRadius.circular(10),
  );

  // Dark Theme
  static final darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: backgroundColor,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: messageColor),
    ),
    appBarTheme: const AppBarTheme(backgroundColor: messageColor),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(20),
      enabledBorder: _border(Colors.grey),
      focusedBorder: _border(messageColor),
    ),
    cardColor: messageColor,
  );

  // Light Theme
  static final lightThemeMode = ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.white, // Light background
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue, // Light theme app bar
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(20),
      enabledBorder: _border(Colors.grey),
      focusedBorder: _border(Colors.blueAccent),
    ),
    cardColor: Colors.blue, // Light theme card color
  );
}
