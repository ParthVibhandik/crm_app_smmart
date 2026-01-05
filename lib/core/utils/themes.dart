import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData light = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: 'Montserrat-Arabic',
  primaryColor: ColorResources.primaryColor,
  scaffoldBackgroundColor: ColorResources.screenBgColor,
  colorScheme: const ColorScheme.light(
    primary: ColorResources.primaryColor,
    secondary: ColorResources.secondaryColor,
    tertiary: ColorResources.tertiaryColor,
    surface: ColorResources.cardColor,
    error: ColorResources.redColor,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: ColorResources.primaryTextColor,
  ),
  
  appBarTheme: const AppBarTheme(
    backgroundColor: ColorResources.primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontSize: 20,
      fontFamily: 'Montserrat-Arabic',
    ),
    iconTheme: IconThemeData(color: Colors.white),
    actionsIconTheme: IconThemeData(color: Colors.white),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarColor: Colors.transparent, // Let AppBar color show
      statusBarIconBrightness: Brightness.light,
    ),
  ),

  cardTheme: const CardThemeData(
    color: ColorResources.cardColor,
    elevation: 2,
    shadowColor: Color(0x0D000000), // Black 5%
    margin: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: ColorResources.inputColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: ColorResources.borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: ColorResources.borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: ColorResources.primaryColor, width: 2),
    ),
    hintStyle: const TextStyle(color: ColorResources.hintColor, fontSize: 14),
    labelStyle: const TextStyle(color: ColorResources.hintColor),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: ColorResources.primaryColor,
    foregroundColor: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
  ),

  dataTableTheme: DataTableThemeData(
    headingRowColor: WidgetStateProperty.all(ColorResources.lightBlueGreyColor.withValues(alpha: 0.3)),
    dataRowColor: WidgetStateProperty.all(Colors.white),
     headingTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: ColorResources.primaryTextColor),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ColorResources.primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    ),
  ),
  
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: ColorResources.primaryTextColor),
    displayMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: ColorResources.primaryTextColor),
    displaySmall: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: ColorResources.primaryTextColor),
    headlineMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: ColorResources.primaryTextColor),
    bodyLarge: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: ColorResources.primaryTextColor),
    bodyMedium: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: ColorResources.primaryTextColor),
    bodySmall: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: ColorResources.contentTextColor),
    labelLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: ColorResources.primaryTextColor),
  ),
  
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: ColorResources.primaryColor,
    unselectedItemColor: ColorResources.hintColor,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
  
  dividerTheme: const DividerThemeData(
    color: ColorResources.lineColor,
    thickness: 1,
  ),
  
  iconTheme: const IconThemeData(color: ColorResources.iconColor),
);

ThemeData dark = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: 'Montserrat-Arabic',
  primaryColor: ColorResources.primaryColor,
  scaffoldBackgroundColor: ColorResources.screenBgColorDark,
  colorScheme: const ColorScheme.dark(
    primary: ColorResources.primaryColor,
    secondary: ColorResources.secondaryColor,
    tertiary: ColorResources.tertiaryColor,
    surface: ColorResources.cardColorDark,
    error: ColorResources.redColor,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
  ),
  
  appBarTheme: const AppBarTheme(
    backgroundColor: ColorResources.cardColorDark, // Darker App bar for dark mode
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontSize: 20,
      fontFamily: 'Montserrat-Arabic',
    ),
    iconTheme: IconThemeData(color: Colors.white),
    actionsIconTheme: IconThemeData(color: Colors.white),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  ),

  cardTheme: const CardThemeData(
    color: ColorResources.cardColorDark,
    elevation: 0,
    margin: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      side: BorderSide(color: Color(0xFF334155), width: 1), 
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: ColorResources.inputColorDark,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: ColorResources.primaryColor, width: 2),
    ),
    hintStyle: const TextStyle(color: ColorResources.hintColorDark, fontSize: 14),
    labelStyle: const TextStyle(color: ColorResources.hintColorDark),
  ),
  
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ColorResources.primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    ),
  ),
  
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white),
    displayMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
    displaySmall: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
    headlineMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
    bodyLarge: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Colors.white),
    bodyMedium: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Colors.white),
    bodySmall: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: ColorResources.hintColor), // Muted text
    labelLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
  ),

  drawerTheme: const DrawerThemeData(
    backgroundColor: ColorResources.screenBgColorDark,
    surfaceTintColor: ColorResources.screenBgColorDark,
  ),
  
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: ColorResources.cardColorDark,
    selectedItemColor: ColorResources.secondaryColor,
    unselectedItemColor: ColorResources.hintColor,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
  
  dividerTheme: const DividerThemeData(
    color: Color(0xFF334155),
    thickness: 1,
  ),
  
  iconTheme: const IconThemeData(color: Colors.white),
);
