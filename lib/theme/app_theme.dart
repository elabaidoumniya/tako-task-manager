// lib/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Tako dark palette
  static const Color bg       = Color(0xFF0D0C1A);
  static const Color bg2      = Color(0xFF13122A);
  static const Color bg3      = Color(0xFF1A1933);
  static const Color card     = Color(0xFF131224);
  static const Color border   = Color(0xFF2A2850);
  static const Color primary  = Color(0xFF7C5CFC);
  static const Color primaryLight = Color(0xFF9B7FFE);
  static const Color accent   = Color(0xFF9B7FFE); // alias primaryLight
  static const Color text     = Color(0xFFFFFFFF);
  static const Color text2    = Color(0xFFA0A0C8);
  static const Color text3    = Color(0xFF6B6B90);
  static const Color green    = Color(0xFF22C55E);
  static const Color red      = Color(0xFFEF4444);
  static const Color orange   = Color(0xFFF59E0B);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C5CFC), Color(0xFF9B7FFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Alias utilisés dans register_screen
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    colors: [Color(0xFF0D0C1A), Color(0xFF13122A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0D0C1A), Color(0xFF13122A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primaryLight,
        surface: card,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: text,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: text,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardTheme(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bg2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: const TextStyle(color: text3),
        hintStyle: const TextStyle(color: text3),
        prefixIconColor: text3,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const StadiumBorder(),
          padding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          textStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryLight),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: bg3,
        headerBackgroundColor: primary,
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return text;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
      ),
    );
  }

  // Alias pour task_form_screen (plus utilisé mais on garde)
  static ThemeData get lightTheme => darkTheme;

  static Color priorityColor(int index) {
    switch (index) {
      case 0: return green;
      case 1: return orange;
      case 2: return red;
      default: return text3;
    }
  }

  static Color priorityBg(int index) {
    switch (index) {
      case 0: return const Color(0xFF0F2D1A);
      case 1: return const Color(0xFF2D1F07);
      case 2: return const Color(0xFF2D0F0F);
      default: return bg2;
    }
  }
}
