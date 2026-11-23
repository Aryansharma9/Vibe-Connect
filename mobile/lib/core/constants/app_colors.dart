import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Coral & Violet gradient vibe)
  static const Color primary = Color(0xFFFF4D6D);
  static const Color primaryDark = Color(0xFFC9184A);
  static const Color secondary = Color(0xFF7209B7);
  static const Color accent = Color(0xFF4CC9F0);

  // Background & Surfaces
  static const Color background = Color(0xFF0F0E17);
  static const Color surface = Color(0xFF1E1B2E);
  static const Color surfaceLight = Color(0xFF2C2744);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA7A2C4);
  static const Color textMuted = Color(0xFF6C6788);

  // Campus Badge & Verification
  static const Color verifiedBlue = Color(0xFF00B4D8);
  static const Color successGreen = Color(0xFF06D6A0);
  static const Color campusLietGold = Color(0xFFFFB703);
  static const Color errorRed = Color(0xFFFF3366);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF4D6D), Color(0xFF7209B7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lietBadgeGradient = LinearGradient(
    colors: [Color(0xFFFFB703), Color(0xFFFB8500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
