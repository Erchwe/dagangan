import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ColorBlindMode { normal, deuteranopia, protanopia, tritanopia }

final themeProvider = StateNotifierProvider<ThemeNotifier, ColorBlindMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ColorBlindMode> {
  ThemeNotifier() : super(ColorBlindMode.normal); // Default: Normal vision

  void setColorBlindMode(ColorBlindMode mode) {
    state = mode;
  }
}

final themeDataProvider = Provider<ThemeData>((ref) {
  final mode = ref.watch(themeProvider);
  switch (mode) {
    case ColorBlindMode.deuteranopia:
      return deuteranopiaTheme;
    case ColorBlindMode.protanopia:
      return protanopiaTheme;
    case ColorBlindMode.tritanopia:
      return tritanopiaTheme;
    default:
      return normalTheme;
  }
});
final ThemeData normalTheme = ThemeData(
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.blue,
  ).copyWith(
    primary: Color(0xFF6A11CB),
    onPrimary: Colors.white,
    secondary: Colors.amber,
    onSecondary: Colors.black,
    tertiary: Colors.red,
    onTertiary: Colors.green
  ),
  scaffoldBackgroundColor: const Color(0xFFF5F5F5),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF6A11CB),
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF6A11CB),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
);

final ThemeData deuteranopiaTheme = ThemeData(
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.teal,
  ).copyWith(
    primary: Color.fromARGB(255, 0, 174, 255),
    onPrimary: Colors.black,
    secondary: Colors.amber,
    onSecondary: Colors.black,
    tertiary: Colors.teal,
    onTertiary: Colors.amber
  ),
  scaffoldBackgroundColor: const Color(0xFFF5F5F5),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 0, 174, 255),
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 0, 174, 255),
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
);

final ThemeData protanopiaTheme = ThemeData(
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.amber,
  ).copyWith(
    primary: Colors.amber,
    onPrimary: Colors.black,
    secondary: Colors.amberAccent,
    onSecondary: Colors.black,
    tertiary: Colors.teal,
    onTertiary: Colors.amber
  ),
  scaffoldBackgroundColor: const Color(0xFFF5F5F5),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.amber,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.amber,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
);

final ThemeData tritanopiaTheme = ThemeData(
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.pink,
  ).copyWith(
    primary: Colors.pink,
    onPrimary: Colors.white,
    secondary: Colors.pinkAccent,
    onSecondary: Colors.white,
    tertiary: Colors.pink,
    onTertiary: Colors.lightBlue
  ),
  scaffoldBackgroundColor: const Color(0xFFF5F5F5),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.pink,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.pink,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
);
