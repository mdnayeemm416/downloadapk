import 'package:adnetwork/config/theme/fonts.dart';
import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../font_manager.dart';
import '../value_manager.dart';
import 'app_colors.dart';

// ═══════════════════════════════════════════════════════════════
//  LIGHT THEME  –  "Trust & Growth" Palette
//  Primary: Deep Navy Blue (#1A237E)
//  Secondary: Emerald Green (#2E7D32)
//  Background: Light Grey (#F5F5F5)
//  Warning: Amber (#FFB300)
// ═══════════════════════════════════════════════════════════════
ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: AppColors.lBackgroundColor, // #F5F5F5
    primary: AppColors.primaryColor, // Deep Navy #1A237E
    secondary: AppColors.secondaryColor, // Emerald #2E7D32
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    primaryContainer: Colors.white,
    secondaryContainer: AppColors().lightBlueGreyBG, // Indigo 50
    tertiaryContainer: Colors.black87,
    tertiary: AppColors.warningColor, // Amber #FFB300
    error: AppColors.red,
  ),
  dividerColor: const Color(0xFFDBDBDB).withValues(alpha: .7),
  textTheme: const TextTheme().copyWith(
    bodyMedium: const TextStyle(color: Color(0xFF212121)),
    displayMedium: const TextStyle(color: Color(0xFF212121)),
  ),
  fontFamily: Fonts.poppins,
  inputDecorationTheme: InputDecorationTheme().copyWith(
    hintStyle: TextStyle(
      color: Colors.black45,
      fontWeight: FontWeightManager.medium,
    ),
    fillColor: AppColors.textFieldLight,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(width: 0, style: BorderStyle.none),
    ),
    errorMaxLines: 2,
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shadowColor: AppColors.primaryColor.withValues(alpha: .08),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Color(0xFFE0E0E0)),
    ),
  ),
  iconTheme: IconThemeData(color: AppColors.primaryColor),
  cardColor: Colors.white,
  dialogTheme: DialogThemeData().copyWith(backgroundColor: Colors.white),
  chipTheme: ChipThemeData().copyWith(
    selectedColor: AppColors.primaryColor,
    secondaryLabelStyle: TextStyle(color: Colors.white),
    labelStyle: TextStyle(color: Colors.black54),
    checkmarkColor: Colors.white,
  ),
  dropdownMenuTheme: DropdownMenuThemeData().copyWith(
    textStyle: TextStyle(color: Colors.black87),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(color: Colors.black45),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.secondaryColor,
    foregroundColor: Colors.white,
  ),
  navigationRailTheme: NavigationRailThemeData(
    backgroundColor: AppColors.primaryColor,
    selectedIconTheme: IconThemeData(color: Colors.white),
    unselectedIconTheme: IconThemeData(color: Colors.white60),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: AppColors.primaryColor,
    selectionColor: AppColors.primaryColor.withValues(alpha: .2),
    selectionHandleColor: AppColors.primaryColor,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.primaryColor,
    unselectedItemColor: Colors.grey.shade500,
  ),
);

// ═══════════════════════════════════════════════════════════════
//  DARK THEME  –  "Modern Tech" Palette
//  Background: Deep Charcoal (#121212)
//  Primary: Electric Violet (#7C4DFF)
//  Secondary: Cyan/Teal (#00B8D4)
//  Text: Off-white (#E0E0E0)
// ═══════════════════════════════════════════════════════════════
ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: AppColors.surfaceDark, // #121212
    primary: AppColors.electricViolet, // #7C4DFF
    secondary: AppColors.cyanTeal, // #00B8D4
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    primaryContainer: Colors.white.withValues(alpha: .04),
    secondaryContainer: AppColors().darkBlueGreyBG,
    tertiaryContainer: AppColors.offWhite,
    tertiary: AppColors.warningColor,
    error: AppColors.red,
  ),
  dividerColor: Color(0xFF4F4F4F),
  fontFamily: Fonts.poppins,
  textTheme: const TextTheme().copyWith(
    bodySmall: TextStyle(color: AppColors.offWhite),
    bodyMedium: TextStyle(color: AppColors.offWhite),
    displayMedium: TextStyle(color: AppColors.offWhite),
  ),
  cardTheme: CardThemeData(
    color: AppColors.cardDark,
    elevation: 4,
    shadowColor: Colors.black38,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Color(0xFF3A3A4A)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme().copyWith(
    hintStyle: TextStyle(
      color: AppColors.offWhite.withValues(alpha: .5),
      fontWeight: FontWeightManager.medium,
    ),
    fillColor: AppColors.textFieldDark,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(width: 0, style: BorderStyle.none),
    ),
    errorMaxLines: 2,
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
  ),
  cardColor: AppColors.cardDark,
  dialogTheme: DialogThemeData().copyWith(
    backgroundColor: AppColors.surfaceDark,
  ),
  chipTheme: ChipThemeData().copyWith(
    selectedColor: AppColors.electricViolet,
    labelStyle: TextStyle(color: AppColors.offWhite),
    checkmarkColor: Colors.white,
  ),
  dropdownMenuTheme: DropdownMenuThemeData().copyWith(
    textStyle: TextStyle(color: AppColors.offWhite),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(color: AppColors.offWhite.withValues(alpha: .6)),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.cyanTeal,
    foregroundColor: Colors.black,
  ),
  navigationRailTheme: NavigationRailThemeData(
    backgroundColor: AppColors.surfaceDark,
    selectedIconTheme: IconThemeData(color: AppColors.cyanTeal),
    unselectedIconTheme: IconThemeData(
      color: AppColors.offWhite.withValues(alpha: .5),
    ),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: AppColors.cyanTeal,
    selectionColor: AppColors.electricViolet.withValues(alpha: .3),
    selectionHandleColor: AppColors.cyanTeal,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.surfaceDark,
    selectedItemColor: AppColors.cyanTeal,
    unselectedItemColor: AppColors.offWhite.withValues(alpha: .4),
  ),
);

// ═══════════════════════════════════════════════════════════════
//  CUSTOM THEME BUILDER (IColors-based)
// ═══════════════════════════════════════════════════════════════
ThemeData createTheme(IColors iColors) => ThemeData(
  scaffoldBackgroundColor: iColors.scaffoldBackgroundColor,
  primaryColor: iColors.primaryColor,
  colorScheme: iColors.colorScheme,
  brightness: iColors.brightness,
  textTheme: _textTheme(iColors),
  appBarTheme: _appBarTheme(iColors),
  popupMenuTheme: _popupMenuThemeData(iColors),
  tabBarTheme: tabBarTheme(),
  textButtonTheme: _textButtonThemeData(iColors),
  elevatedButtonTheme: _elevatedButtonThemeData(iColors),
  inputDecorationTheme: _inputDecorationTheme(iColors),
  dividerColor: iColors.colorScheme!.secondaryContainer,
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: iColors.primaryColor,
  ),
);

TextTheme _textTheme(IColors iColors) {
  return TextTheme(
    displayLarge: getSemiBoldStyle(
      color: iColors.colorScheme!.secondary,
      fontSize: FontSize.s20,
    ),
    //for appbar
    headlineLarge: getBoldStyle(
      color: iColors.colorScheme!.onPrimary,
      fontSize: 18,
    ),
    bodySmall: getRegularStyle(
      color: iColors.colorScheme!.primaryContainer,
      fontSize: 13,
    ),
    //for list tile title
    headlineMedium: getMediumStyle(
      color: iColors.colorScheme!.onSurface,
      fontSize: FontSize.s17,
    ),
    labelLarge: getBoldStyle(
      color: iColors.colorScheme!.onPrimary,
      fontSize: 14,
    ),
    //for list tile subtitle
    bodyMedium: getMediumStyle(
      color: iColors.colorScheme!.onInverseSurface,
      fontSize: FontSize.s14,
    ),
    //for time card
    displaySmall: TextStyle(
      color: iColors.colorScheme!.onSurfaceVariant,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: getMediumStyle(
      color: iColors.colorScheme!.onSurface,
      fontSize: FontSize.s17,
    ),
    titleMedium: getMediumStyle(
      color: iColors.colorScheme!.onInverseSurface,
      fontSize: FontSize.s14,
    ),
    titleSmall: getSemiBoldStyle(
      color: iColors.colorScheme!.onSurfaceVariant,
      fontSize: FontSize.s14,
    ),
  );
}

AppBarTheme _appBarTheme(IColors colors) {
  return AppBarTheme(
    backgroundColor: colors.colorScheme!.primary,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: colors.colorScheme!.primary,
      statusBarIconBrightness: Brightness.light,
    ),
    titleTextStyle: TextStyle(
      color: colors.colorScheme!.onPrimary,
      fontSize: AppSize.s20,
      fontWeight: FontWeightManager.semiBold,
    ),
    actionsIconTheme: IconThemeData(
      color: colors.colorScheme!.primaryContainer,
      size: FontSize.s26,
    ),
  );
}

TabBarThemeData tabBarTheme() {
  return const TabBarThemeData(
    labelStyle: TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeightManager.bold,
    ),
  );
}

TextButtonThemeData _textButtonThemeData(IColors colors) {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      textStyle: TextStyle(
        color: colors.colorScheme!.secondary,
        fontWeight: FontWeightManager.medium,
      ),
    ),
  );
}

PopupMenuThemeData _popupMenuThemeData(IColors iColors) {
  return PopupMenuThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    textStyle: TextStyle(
      color: iColors.colorScheme!.onSurface,
      fontWeight: FontWeightManager.medium,
      fontSize: FontSize.s17,
    ),
  );
}

InputDecorationTheme _inputDecorationTheme(IColors iColors) {
  return InputDecorationTheme(
    hintStyle: TextStyle(color: iColors.colorScheme!.onInverseSurface),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: iColors.colorScheme!.secondary, width: 2),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: iColors.colorScheme!.secondary, width: 2),
    ),
  );
}

ElevatedButtonThemeData _elevatedButtonThemeData(IColors iColors) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: iColors.colorScheme!.secondary,
      textStyle: TextStyle(
        color: iColors.colorScheme!.onSecondary,
        fontWeight: FontWeightManager.medium,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.s20,
        vertical: AppSize.s14,
      ),
    ),
  );
}
