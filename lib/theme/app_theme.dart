// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Cores principais da identidade visual
  static const Color primaryRed = Color(0xFFDC0A2D);
  static const Color primaryDarkRed = Color(0xFFB00824);
  static const Color darkText = Color(0xFF1D1D1D);
  static const Color lightGray = Color(0xFFF5F5F5);

  // Fonte principal
  static const String primaryFont = 'Poppins';

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: primaryFont,
      scaffoldBackgroundColor: lightGray,

      // Esquema de cores geral
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRed,
        primary: primaryRed,
        brightness: Brightness.light,
      ),

      // Tema para AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: primaryFont,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Tema para Textos
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: primaryFont,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        displayMedium: TextStyle(
          fontFamily: primaryFont,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        displaySmall: TextStyle(
          fontFamily: primaryFont,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        headlineLarge: TextStyle(
          fontFamily: primaryFont,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        headlineMedium: TextStyle(
          fontFamily: primaryFont,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        headlineSmall: TextStyle(
          fontFamily: primaryFont,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        bodyLarge: TextStyle(color: darkText, fontSize: 16),
        bodyMedium: TextStyle(color: darkText, fontSize: 14),
      ),

      // Tema para Campos de Texto (Inputs)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        labelStyle: TextStyle(color: Colors.grey.shade600),
        hintStyle: TextStyle(color: Colors.grey.shade500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2.5),
        ),
      ),

      // Tema para Botões Elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: primaryFont,
          ),
        ),
      ),
    );
  }
}
