import 'package:flutex_admin/common/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ColorResources {
  // Premium Core Colors
  static const Color primaryColor = Color(0xFF4F46E5); // Indigo 600 - Validated for impact
  static const Color secondaryColor = Color(0xFF0EA5E9); // Sky 500
  static const Color tertiaryColor = Color(0xFF8B5CF6); // Violet 500

  // Backgrounds & Surfaces
  static const Color screenBgColor = Color(0xFFF8FAFC); // Slate 50
  static const Color screenBgColorDark = Color(0xFF0F172A); // Slate 900
  
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color cardColorDark = Color(0xFF1E293B); // Slate 800
  
  static const Color secondaryScreenBgColor = Color(0xFFEEF2FF); // Indigo 50
  
  // Text Colors
  static const Color primaryTextColor = Color(0xFF1E293B); // Slate 800
  static const Color contentTextColor = Color(0xFF64748B); // Slate 500
  static const Color primaryStatusBarColor = screenBgColorDark;
  
  static const Color underlineTextColor = primaryColor;
  static const Color lineColor = Color(0xFFE2E8F0); // Slate 200
  static const Color borderColor = Color(0xFFCBD5E1); // Slate 300
  
  static const Color inputColor = Color(0xFFFFFFFF); 
  static const Color inputColorDark = Color(0xFF334155); // Slate 700

  // Hints
  static const Color hintColor = Color(0xFF94A3B8); // Slate 400
  static const Color hintColorDark = Color(0xFF64748B);

  // Expanded Palette for UI freshness
  static const Color lightBackgroundColor = Color(0xFFF1F5F9);
  static const Color darkColor = Color(0xFF1E293B);
  static const Color textDarkColor = Color(0xFF334155);
  static const Color blueGreyColor = Color(0xFF64748B);
  static const Color lightBlueGreyColor = Color(0xFFCBD5E1);
  
  // Functional Colors
  static const Color blueColor = Color(0xFF3B82F6);
  static const Color redColor = Color(0xFFEF4444);
  static const Color greenColor = Color(0xFF10B981); // Emerald 500
  static const Color yellowColor = Color(0xFFF59E0B); // Amber 500
  static const Color purpleColor = Color(0xFF8B5CF6);

  // AppBar
  static const Color appBarColor = primaryColor;
  static const Color appBarContentColor = colorWhite;

  // TextField
  static Color labelTextColor = Color(0xFF475569);
  static const Color textFieldDisableBorderColor = Color(0xFFE2E8F0);
  static const Color textFieldEnableBorderColor = primaryColor;
  static const Color hintTextColor = Color(0xFF94A3B8);

  // Buttons
  static const Color primaryButtonColor = primaryColor;
  static const Color primaryButtonTextColor = colorWhite;
  static const Color secondaryButtonColor = colorWhite;
  static const Color secondaryButtonTextColor = Color(0xFF1E293B);

  // Icons
  static const Color iconColor = Color(0xFF64748B);
  static const Color filterEnableIconColor = primaryColor;
  static const Color filterIconColor = iconColor;
  static const Color searchEnableIconColor = redColor;
  static const Color searchIconColor = iconColor;
  static const Color bottomSheetCloseIconColor = Color(0xFF0F172A);

  // Base
  static const Color colorWhite = Color(0xFFFFFFFF);
  static const Color colorBlack = Color(0xFF000000);
  static const Color colorGreen = Color(0xFF10B981);
  static const Color colorGreen100 = Color(0xFFD1FAE5);
  static const Color colorOrange = Color(0xFFF59E0B);
  static const Color colorOrange100 = Color(0xFFFEF3C7);
  static const Color colorRed = Color(0xFFEF4444);
  static const Color colorRed100 = Color(0xFFFEE2E2);
  static const Color colorGrey = Color(0xFF64748B);
  static const Color lightGray = Color(0xFFF8FAFC);
  static const Color colorlighterGrey = Color(0xFF94A3B8);
  static const Color colorLightGrey = Color(0xFFE2E8F0);
  static const Color transparentColor = Colors.transparent;

  // Getters & Helpers
  static Color getPrimaryColor() => primaryColor;
  static Color getScreenBgColor() => Get.find<ThemeController>().darkTheme ? screenBgColorDark : screenBgColor;
  
  static Color projectStatusColor(String state) {
    switch (state) {
      case '1':
      case 'Not Started':
        return lightBlueGreyColor;
      case '2':
      case 'In Progress':
        return blueColor;
      case '3':
      case 'On Hold':
        return yellowColor;
      case '4':
      case 'Finished':
        return greenColor;
      case '5':
      case 'Cancelled':
        return redColor;
      default:
        return blueColor;
    }
  }

  static Color taskStatusColor(String state) {
    switch (state) {
      case '1': return lightBlueGreyColor;
      case '2': return blueColor;
      case '3': return yellowColor;
      case '4': return blueColor;
      case '5': return greenColor;
      default: return blueColor;
    }
  }

  static Color taskPriorityColor(String state) {
    switch (state) {
      case '1': return lightBlueGreyColor;
      case '2': return blueColor;
      case '3': return yellowColor;
      case '4': return redColor;
      default: return blueColor;
    }
  }

  static Color invoiceStatusColor(String state) {
    switch (state) {
      case '1': return redColor;
      case '2': return greenColor;
      case '3': return colorOrange;
      case '4': return yellowColor;
      case '5': return colorGrey;
      case '6': return lightBlueGreyColor;
      default: return blueColor;
    }
  }

  static Color invoiceTextStatusColor(String state) {
    switch (state) {
      case 'Unpaid': return redColor;
      case 'Paid': return greenColor;
      case 'Partialy Paid': return colorOrange;
      case 'Overdue': return redColor;
      case 'Cancelled': return redColor;
      case 'Draft': return lightBlueGreyColor;
      default: return blueColor;
    }
  }

  static Color contractStatusColor(String state) {
    switch (state) {
      case '0': return blueColor;
      case '1': return greenColor;
      case '2': return redColor;
      case '3': return yellowColor;
      case '4': return lightBlueGreyColor;
      default: return blueColor;
    }
  }

  static Color estimateStatusColor(String state) {
    switch (state) {
      case '1': return lightBlueGreyColor;
      case '2': return blueColor;
      case '3': return redColor;
      case '4': return greenColor;
      case '5': return redColor;
      default: return blueColor;
    }
  }

  static Color estimateTextStatusColor(String state) {
    switch (state) {
      case 'Draft': return lightBlueGreyColor;
      case 'Not Sent': return blueColor;
      case 'Sent': return redColor;
      case 'Expired': return greenColor; // Logic seems weird in original, but keeping mapping
      case 'Declined': return redColor;
      case 'Accepted': return redColor;
      default: return blueColor;
    }
  }
  
  static Color proposalTextStatusColor(String state) {
    switch (state) {
      case 'Draft': return lightBlueGreyColor;
      case 'Sent': return blueColor;
      case 'Open': return redColor;
      case 'Revised': return greenColor;
      case 'Declined': return redColor;
      case 'Accepted': return greenColor;
      default: return blueColor;
    }
  }

  static Color proposalStatusColor(String state) {
    switch (state) {
      case '1': return blueColor;
      case '2': return redColor;
      case '3': return greenColor;
      case '4': return colorOrange;
      case '5': return blueColor;
      case '6': return colorGrey;
      default: return blueColor;
    }
  }

  static Color ticketStatusColor(String state) {
    switch (state) {
      case '1': return redColor;
      case '2': return greenColor;
      case '3': return blueColor;
      case '4': return yellowColor;
      case '5': return lightBlueGreyColor; // Closed
      default: return blueColor;
    }
  }

  static Color ticketPriorityColor(String state) {
    switch (state) {
      case '1': return greenColor;
      case '2': return yellowColor;
      case '3': return redColor;
      default: return blueColor;
    }
  }

  static Color getGreyText() => colorBlack.withValues(alpha: 0.5);
  static Color getSecondaryScreenBgColor() => secondaryScreenBgColor;
  static Color getAppBarColor() => appBarColor;
  static Color getAppBarContentColor() => appBarContentColor;
  static Color getHeadingTextColor() => primaryTextColor;
  static Color getContentTextColor() => contentTextColor;
  static Color getLabelTextColor() => labelTextColor;
  static Color getHintTextColor() => hintTextColor;
  static Color getTextFieldDisableBorder() => textFieldDisableBorderColor;
  static Color getTextFieldEnableBorder() => textFieldEnableBorderColor;
  static Color getPrimaryButtonColor() => primaryButtonColor;
  static Color getPrimaryButtonTextColor() => primaryButtonTextColor;
  static Color getSecondaryButtonColor() => secondaryButtonColor;
  static Color getSecondaryButtonTextColor() => secondaryButtonTextColor;
  static Color getIconColor() => iconColor;
  static Color getFilterDisableIconColor() => filterIconColor;
  static Color getFilterEnableIconColor() => filterEnableIconColor;
  static Color getSearchIconColor() => searchIconColor;
  static Color getSearchEnableIconColor() => redColor;
  
  static Color getUnselectedIconColor() {
    return Get.find<ThemeController>().darkTheme ? const Color(0xFF94A3B8) : textFieldDisableBorderColor;
  }

  static Color getSelectedIconColor() {
    return Get.find<ThemeController>().darkTheme ? colorWhite : colorBlack;
  }

  static Color getTransparentColor() => transparentColor;
  static Color getTextColor() => Get.find<ThemeController>().darkTheme ? colorWhite : colorBlack;
  static Color getCardBgColor() => colorWhite;
}
