import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Emeralds
  static const Color brand50 = Color(0xFFECFDF5);
  static const Color brand100 = Color(0xFFD1FAE5);
  static const Color brand200 = Color(0xFFA7F3D0);
  static const Color brand300 = Color(0xFF6EE7B7);
  static const Color brand500 = Color(0xFF10B981);
  static const Color brand600 = Color(0xFF059669);
  static const Color brand700 = Color(0xFF047857);
  static const Color brand800 = Color(0xFF065F46);
  static const Color brand900 = Color(0xFF064E3B);

  // Slates
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);

  // Teals
  static const Color teal50 = Color(0xFFF0FDFA);
  static const Color teal100 = Color(0xFFCCFBF1);
  static const Color teal200 = Color(0xFF99F6E4);
  static const Color teal600 = Color(0xFF0D9488);
  static const Color teal700 = Color(0xFF0F766E);
  static const Color teal800 = Color(0xFF115E59);
  static const Color teal950 = Color(0xFF042F2E);

  // Ambers
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber950 = Color(0xFF451A03);

  // Roses
  static const Color rose50 = Color(0xFFFFF1F2);
  static const Color rose100 = Color(0xFFFFE4E6);
  static const Color rose200 = Color(0xFFFECDD3);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color rose600 = Color(0xFFE11D48);
  static const Color rose900 = Color(0xFF881337);
  static const Color rose950 = Color(0xFF4C0519);

  static TextStyle sans({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = slate800,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle mono({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.normal,
    Color color = slate800,
    double? letterSpacing,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static BoxDecoration cardDecoration({
    Color backgroundColor = Colors.white,
    Color borderColor = brand100,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      color: backgroundColor.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: 1.2),
      boxShadow: [
        BoxShadow(
          color: const Color(0x0A0F172A),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
