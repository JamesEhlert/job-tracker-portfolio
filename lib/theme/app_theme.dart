import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 1. Definimos nossas Cores Oficiais aqui (Slate & Teal)
  static const Color primary = Color(0xFF334155);    // Slate 700
  static const Color secondary = Color(0xFF0D9488);  // Teal 600
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFEF4444);      // Red 500
  
  static const Color textDark = Color(0xFF1E293B);   // Slate 800
  static const Color textLight = Color(0xFF64748B);  // Slate 500

  // 2. Criamos o Tema Geral
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Esquema de Cores Centralizado
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
      ),

      scaffoldBackgroundColor: background,

      // Tipografia Padrão (Inter)
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),

      // Estilo Padrão da AppBar
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textDark, 
          fontSize: 20, 
          fontWeight: FontWeight.w600
        ),
        iconTheme: IconThemeData(color: primary),
      ),

      // CORREÇÃO AQUI: Usar CardThemeData em vez de CardTheme
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      // Estilo Padrão dos Botões
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),

      // Estilo Padrão dos Inputs (Formulários)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textLight),
      ),
    );
  }
}