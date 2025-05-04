import 'package:flutter/material.dart';

class AppColors {
  // Light mode colors
  static const Color primaryTextLight = Color(0xFF01579B);
  static const Color secondaryTextLight = Color(0xFF757575);
  static const Color buttonAccentLight = Color(0xFF0288D1);
  static const Color cardBackgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundLight = Color(0xFFE3F2FD);
  static const Color gradientStartLight = Color(0xFF0288D1);
  static const Color gradientEndLight = Color(0xFF4FC3F7);
 static const Color accentLight = Color(0xFFE8E8FF);
  // Dark mode colors
  static const Color primaryTextDark = Color(0xFFE3F2FD);
  static const Color secondaryTextDark = Color(0xFFB0BEC5);
  static const Color buttonAccentDark = Color(0xFF4FC3F7);
  static const Color cardBackgroundDark = Color(0xFF263238);
  static const Color backgroundDark = Color(0xFF1A2226);
  static const Color gradientStartDark = Color(0xFF0277BD);
  static const Color gradientEndDark = Color(0xFF4FC3F7);

  static const Color accentDark = Color(0xFF4FC3F7);
  // Theme-aware getters
  static Color primaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? primaryTextLight : primaryTextDark;
  static Color secondaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? secondaryTextLight : secondaryTextDark;
  static Color buttonAccent(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? buttonAccentLight : buttonAccentDark;
  static Color cardBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? cardBackgroundLight : cardBackgroundDark;
  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? backgroundLight : backgroundDark;
  static LinearGradient headerGradient(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? LinearGradient(colors: [gradientStartLight, gradientEndLight])
          : LinearGradient(colors: [gradientStartDark, gradientEndDark]);
           static Color accent(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light ? accentLight : accentDark;
}