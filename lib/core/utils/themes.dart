import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData light = ThemeData(
  primaryColor: ColorResources.primaryColor,
  secondaryHeaderColor: ColorResources.secondaryColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: ColorResources.primaryColor,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    actionsIconTheme: IconThemeData(color: Colors.white),
    foregroundColor: Colors.white,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
      fontFamily: 'Montserrat-Arabic',
    ),
    iconTheme: IconThemeData(color: Colors.white),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  ),
  fontFamily: 'Montserrat-Arabic',
  scaffoldBackgroundColor: ColorResources.screenBgColor,
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    foregroundColor: Colors.white,
    backgroundColor: ColorResources.secondaryColor,
    elevation: 4,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ColorResources.secondaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: ColorResources.primaryColor, width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    hintStyle: const TextStyle(color: ColorResources.hintColor, fontSize: 14),
    fillColor: ColorResources.inputColor,
    filled: true,
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 4,
    shadowColor: Colors.black.withValues(alpha: 0.05),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  cardColor: Colors.white,
  textTheme: const TextTheme(
    displaySmall: TextStyle(
      color: ColorResources.primaryTextColor,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: ColorResources.primaryTextColor,
      fontWeight: FontWeight.w400,
      fontSize: 14,
    ),
    bodySmall: TextStyle(
      color: ColorResources.contentTextColor,
      fontWeight: FontWeight.w400,
      fontSize: 12,
    ),
    bodyLarge: TextStyle(
      color: ColorResources.primaryColor,
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: ColorResources.primaryColor,
    unselectedItemColor: ColorResources.hintColor,
    showUnselectedLabels: true,
    elevation: 20,
    type: BottomNavigationBarType.fixed,
  ),
  hintColor: ColorResources.hintColor,
);

ThemeData dark = ThemeData(
  primaryColor: ColorResources.primaryColor,
  secondaryHeaderColor: ColorResources.secondaryColor,
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    backgroundColor: ColorResources.primaryColor,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    actionsIconTheme: IconThemeData(color: Colors.white),
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
      fontFamily: 'Montserrat-Arabic',
    ),
    iconTheme: IconThemeData(color: Colors.white),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  ),
  scaffoldBackgroundColor: ColorResources.screenBgColorDark,
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    foregroundColor: Colors.white,
    backgroundColor: ColorResources.secondaryColor,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ColorResources.secondaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: ColorResources.secondaryColor, width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    fillColor: ColorResources.inputColorDark,
    filled: true,
    hintStyle: const TextStyle(color: ColorResources.hintColorDark, fontSize: 14),
  ),
  cardTheme: CardThemeData(
    color: ColorResources.cardColorDark,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  cardColor: ColorResources.cardColorDark,
  textTheme: const TextTheme(
    displaySmall: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w400,
      fontSize: 14,
    ),
    bodySmall: TextStyle(
      color: ColorResources.hintColorDark,
      fontWeight: FontWeight.w400,
      fontSize: 12,
    ),
    bodyLarge: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  primaryIconTheme: const IconThemeData(color: Colors.white),
  hintColor: ColorResources.hintColorDark,
  expansionTileTheme: const ExpansionTileThemeData(iconColor: Colors.white, textColor: Colors.white),
);
