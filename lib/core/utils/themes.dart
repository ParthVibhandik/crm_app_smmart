import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Light Theme (Optional - kept clean)
ThemeData light = ThemeData(
  useMaterial3: true,
  fontFamily: GoogleFonts.outfit().fontFamily,
  primaryColor: ColorResources.primaryColor,
  secondaryHeaderColor: ColorResources.secondaryColor,
  scaffoldBackgroundColor: const Color(0xFFF8F9FA),
  colorScheme: ColorScheme.fromSeed(
    seedColor: ColorResources.primaryColor,
    surface: Colors.white,
    brightness: Brightness.light,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: ColorResources.primaryColor,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    iconTheme: IconThemeData(color: Colors.white),
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),
  textTheme: GoogleFonts.outfitTextTheme(),
);

// Dark "Future/Neon" Theme - The Main Star
ThemeData dark = ThemeData(
  useMaterial3: true,
  fontFamily: GoogleFonts.outfit().fontFamily,
  primaryColor: ColorResources.neonCyan,
  secondaryHeaderColor: ColorResources.electricPurple,
  scaffoldBackgroundColor: ColorResources.voidBackground,
  brightness: Brightness.dark,

  colorScheme: const ColorScheme.dark(
    primary: ColorResources.neonCyan,
    secondary: ColorResources.electricPurple,
    surface: ColorResources.cardSurface,
    onPrimary: Colors.black,
    onSurface: Colors.white,
    error: Colors.redAccent,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    iconTheme: IconThemeData(color: Colors.white),
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: ColorResources.neonCyan,
    foregroundColor: Colors.black,
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: ColorResources.glassBlack,
    hintStyle: GoogleFonts.outfit(color: Colors.white38),
    labelStyle: GoogleFonts.outfit(color: Colors.white70),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: ColorResources.neonCyan, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1),
    ),
  ),

  cardTheme: CardThemeData(
    color: ColorResources.cardSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  drawerTheme: const DrawerThemeData(
    backgroundColor: ColorResources.voidBackground,
    surfaceTintColor: Colors.transparent,
  ),

  // Typography System
  textTheme: TextTheme(
    // Headlines - Orbitron
    displayLarge: GoogleFonts.orbitron(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
    displayMedium: GoogleFonts.orbitron(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
    displaySmall: GoogleFonts.orbitron(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
    headlineMedium: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
    
    // Body - Outfit
    bodyLarge: GoogleFonts.outfit(fontSize: 16, color: Colors.white),
    bodyMedium: GoogleFonts.outfit(fontSize: 14, color: Colors.white70),
    titleMedium: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
    labelLarge: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
  ),

  iconTheme: const IconThemeData(color: ColorResources.neonCyan),
);
