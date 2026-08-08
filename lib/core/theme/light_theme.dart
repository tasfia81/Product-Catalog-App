import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFB8841D),
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color(0xFFB8841D),
    onPrimary: const Color(0xFFFFFFFF),
    secondary: const Color(0xFF554300),
    surface: const Color(0xFFFFFFFF),
    onSurface: const Color(0xFF000000),
    surfaceContainerHighest: const Color(0x0D1B1C1C),
    outline: const Color(0x994D4635),
    onSurfaceVariant: const Color(0xFF666666),
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Color(0xFFFFFFFF),
    foregroundColor: Color(0xFF000000),
  ),
  cardTheme: CardThemeData(
    elevation: 1,
    color: const Color(0xFFFFFFFF),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0x0D1B1C1C), width: 1),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0x0D1B1C1C),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
);
