import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF8685EF),
  scaffoldBackgroundColor: const Color(0xFFFAFAFA),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF171717),
    secondary: Color(0xFFFF8906),
    surface: Color(0xFFFAFAFA),
    primaryContainer: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF2F2F2),
    error: Color(0xFFE5484D),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
        fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xE7000000)),
    titleMedium: TextStyle(
        fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xE7000000)),
    titleSmall: TextStyle(
        fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xE7000000)),
    bodySmall: TextStyle(fontSize: 12.0, color: Color(0xE7000000)),
    bodyMedium: TextStyle(fontSize: 14.0, color: Color(0xE7000000)),
    bodyLarge: TextStyle(fontSize: 16.0, color: Color(0xE7000000)),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF8685EF),
  scaffoldBackgroundColor: const Color(0xFF121212),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF8685EF),
    secondary: Color(0xFFFF8906),
    surface: Color(0xFF121212),
    primaryContainer: Color(0xFF1E1E1E),
    secondaryContainer: Color(0xFF2C2C2C),
    error: Color(0xFFCF6679),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
        fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
    titleMedium: TextStyle(
        fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
    titleSmall: TextStyle(
        fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
    bodySmall: TextStyle(fontSize: 12.0, color: Color(0xFFFFFFFF)),
    bodyMedium: TextStyle(fontSize: 14.0, color: Color(0xFFFFFFFF)),
    bodyLarge: TextStyle(fontSize: 16.0, color: Color(0xFFFFFFFF)),
  ),
);
