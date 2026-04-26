import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0A0A1A);
  static const Color surface = Color(0xFF111128);
  static const Color cell = Color(0xFF1A1A3E);
  static const Color border = Color(0xFF2D2D6B);
  static const Color borderHover = Color(0xFF4A4AAA);

  static const Color xColor = Color(0xFF00E5FF);
  static const Color oColor = Color(0xFFFF4081);
  static const Color gold = Color(0xFFFFD700);
  static const Color purple = Color(0xFF7C3AED);
  static const Color muted = Color(0xFF888AB0);

  static const Color xDark = Color(0xFF001A2E);
  static const Color oDark = Color(0xFF2E0015);

  static LinearGradient xGradient = const LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF0077FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient oGradient = const LinearGradient(
    colors: [Color(0xFFFF4081), Color(0xFFCC0055)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient titleGradient = const LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFFFF4081)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static List<BoxShadow> xGlow = [
    BoxShadow(color: xColor.withOpacity(0.5), blurRadius: 20, spreadRadius: 2),
    BoxShadow(color: xColor.withOpacity(0.3), blurRadius: 40),
  ];

  static List<BoxShadow> oGlow = [
    BoxShadow(color: oColor.withOpacity(0.5), blurRadius: 20, spreadRadius: 2),
    BoxShadow(color: oColor.withOpacity(0.3), blurRadius: 40),
  ];

  static List<BoxShadow> xGlowSoft = [
    BoxShadow(color: xColor.withOpacity(0.15), blurRadius: 15),
  ];
  static List<BoxShadow> oGlowSoft = [
    BoxShadow(color: oColor.withOpacity(0.15), blurRadius: 15),
  ];
}
