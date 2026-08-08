import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFB8841D),
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFFD4AF37), // Bright gold
    onPrimary: const Color(0xFF000000),
    secondary: const Color(0xFFB8841D),
    surface: const Color(0xFF1B1C1C), // Deep professional dark charcoal
    onSurface: const Color(0xFFFFFFFF),
    surfaceContainerHighest: const Color(0x0DFFFFFF),
    outline: const Color(0x994D4635),
    onSurfaceVariant: const Color(0xFFBBBBBB),
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Color(0xFF1B1C1C),
    foregroundColor: Color(0xFFFFFFFF),
  ),
  cardTheme: CardThemeData(
    elevation: 1,
    color: const Color(0x0DFFFFFF),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0x1AFFFFFF), width: 1),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0x0DFFFFFF),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
);
