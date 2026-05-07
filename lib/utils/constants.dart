import 'package:flutter/material.dart';

/// App-wide color constants.
class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42E8);

  // Accent / secondary
  static const Color accent = Color(0xFF00BFA6);
  static const Color accentLight = Color(0xFF5DF2D6);

  // Background & surface
  static const Color background = Color(0xFF0A0E21);
  static const Color surface = Color(0xFF1D1F33);
  static const Color cardDark = Color(0xFF1E2747);
  static const Color cardGlass = Color(0x1AFFFFFF); // 10% white

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF42A5F5);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% white
  static const Color textHint = Color(0x80FFFFFF); // 50% white

  // Topic status colors
  static const Color notStarted = Color(0xFFEF5350);
  static const Color inProgress = Color(0xFFFFB74D);
  static const Color completed = Color(0xFF4CAF50);

  // Chart colors
  static const List<Color> chartColors = [
    Color(0xFF6C63FF),
    Color(0xFF00BFA6),
    Color(0xFFFF6B6B),
    Color(0xFFFFD93D),
    Color(0xFF42A5F5),
    Color(0xFFAB47BC),
    Color(0xFFFF7043),
    Color(0xFF26A69A),
  ];

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4A42E8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00BFA6), Color(0xFF00897B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0E21), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// App-wide spacing and sizing constants.
class AppSizes {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const double borderRadius = 16.0;
  static const double borderRadiusSm = 8.0;
  static const double borderRadiusLg = 24.0;

  static const double iconSm = 18.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
}

/// Hive box name constants.
class HiveBoxes {
  static const String subjects = 'subjects';
  static const String topics = 'topics';
  static const String sessions = 'sessions';
  static const String syncQueue = 'sync_queue';
}
