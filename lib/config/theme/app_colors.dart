import 'package:flutter/material.dart';

class AppColors {
  // ─────────────────────────────────────────────────
  // "Trust & Growth" Light Mode Palette
  // ─────────────────────────────────────────────────
  /// Deep Navy Blue – Sidebars, navigation, primary branding
  static const Color primaryColor = Color(0xFF1A237E);

  /// Emerald Green – Live status, ROI, profit indicators
  static const Color secondaryColor = Color(0xFF2E7D32);

  /// High-Contrast White / Light Grey – Main workspace background
  static const Color lBackgroundColor = Color(0xFFF5F5F5);

  /// Amber – Pending approvals, low-budget alerts
  static const Color warningColor = Color(0xFFFFB300);

  // ─────────────────────────────────────────────────
  // "Modern Tech" Dark Mode Palette
  // ─────────────────────────────────────────────────
  /// Deep Charcoal / Black – Dark mode background
  static const Color surfaceDark = Color(0xFF121212);

  /// Electric Violet – AI-driven, cutting-edge feel
  static const Color electricViolet = Color(0xFF7C4DFF);

  /// Cyan / Teal – Buttons and primary CTAs (dark mode)
  static const Color cyanTeal = Color(0xFF00B8D4);

  /// Off-white – Text on dark backgrounds
  static const Color offWhite = Color(0xFFE0E0E0);

  // ─────────────────────────────────────────────────
  // Shared / Utility Colors
  // ─────────────────────────────────────────────────
  static const Color red = Color(0xFFFB4134);
  static Color green = const Color(0xFF2E7D32);
  static Color blue = Colors.blue.shade500;

  static const Color black3 = Color(0xFF252525);
  static const Color cream = Color(0xFFFFFDD0);

  /// Card / elevated surface in dark mode
  static const Color cardDark = Color(0xFF1E1E2C);
  static const Color btnDarkBlue = Color(0xFF282E41);

  /// Sidebar highlight color (light mode)
  static const Color sidebarHighlight = Color(0xFF283593); // Indigo 800

  /// Floating action button color
  static const Color flotingSideActionButtonColor = Color(0xFF3B3D60);

  final Color darkBlueGreyBG = const Color(0xFF2C2C3E);
  final Color lightBlueGreyBG = const Color(0xFFE8EAF6); // Indigo 50

  static const Color blue700 = Color(0xFF1565C0);

  static const Color darkBlueGrey = Color(0xFF171B26);

  static const Color textFieldDark = Color(0xFF2A2A3C);
  static const Color textFieldLight = Color(0xFFE8EAF6); // Indigo 50

  // ─────────────────────────────────────────────────
  // Status Colors (Ad Network specifics)
  // ─────────────────────────────────────────────────
  static const Color statusLive = Color(0xFF2E7D32);       // Green – live campaigns
  static const Color statusPaused = Color(0xFFFFB300);     // Amber – paused
  static const Color statusStopped = Color(0xFFFB4134);    // Red – stopped
  static const Color statusDraft = Color(0xFF9E9E9E);      // Grey – draft

  static const Color profitPositive = Color(0xFF2E7D32);   // Green
  static const Color profitNegative = Color(0xFFFB4134);   // Red
}

abstract class IColors {
  AppColors get _colors;

  Color? scaffoldBackgroundColor;
  Color? appBarColor;
  Color? primaryColor;

  Brightness? brightness;

  ColorScheme? colorScheme;
}
