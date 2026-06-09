import 'package:flutter/material.dart';

class AppColors {
  static const Color bgDark = Color(0xFF09090E);
  static const Color bgCard = Color(0xBF14141E);
  static const Color bgPhone = Color(0xFF0E0E16);

  static const Color neonCyan = Color(0xFF00F2FE);
  static const Color neonViolet = Color(0xFF8A2BE2);
  static const Color neonPink = Color(0xFFFF007F);
  static const Color neonGold = Color(0xFFFFB300);
  static const Color neonRed = Color(0xFFFF3366);
  static const Color neonGreen = Color(0xFF00E676);

  static const Color textPrimary = Color(0xFFF5F5FA);
  static const Color textSecondary = Color(0xFFA0A0BA);
  static const Color textMuted = Color(0xFF65657A);

  static const Color glassBorder = Color(0x1AFFFFFF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [neonCyan, neonViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [neonPink, neonViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
