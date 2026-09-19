import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens and typography system for the Half & Half party drawing game.
/// Aligned with the deep violet and vibrant festive aesthetic of the game.
class HalfAndHalfTheme {
  // Brand Colors
  static const Color bgDark = Color(0xff120924);
  static const Color bgCard = Color(0xff1d0e38);
  static const Color bgCardSurface = Color(0xff251347);
  static const Color purplePrimary = Color(0xff7c3aed);
  static const Color purpleLight = Color(0xffc4b5fd);
  static const Color purpleAccent = Color(0xffa78bfa);
  static const Color purpleBorder = Color(0xff4c1d95);
  static const Color purpleBorderLight = Color(0xff6d28d9);

  // Festive Accents
  static const Color accentYellow = Color(0xfffacc15);
  static const Color accentGold = Color(0xffe8bd42);
  static const Color accentOrange = Color(0xfff97316);
  static const Color accentCyan = Color(0xff06b6d4);
  static const Color accentPink = Color(0xffec4899);
  static const Color accentGreen = Color(0xff22c55e);

  // Gradients
  static const LinearGradient cardGradient = LinearGradient(
    colors: <Color>[Color(0xff251347), Color(0xff180b2d)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: <Color>[Color(0xff8b5cf6), Color(0xff6d28d9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Typography System (Fredoka: Playful, rounded, modern game typography)
  static TextStyle title({
    double fontSize = 20,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = 0.5,
    double? height,
  }) {
    return GoogleFonts.fredoka(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle header({
    double fontSize = 16,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = 0.4,
  }) {
    return GoogleFonts.fredoka(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle body({
    double fontSize = 13,
    Color color = const Color(0xffc4b5fd),
    FontWeight fontWeight = FontWeight.w500,
    double? letterSpacing,
  }) {
    return GoogleFonts.fredoka(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle button({
    double fontSize = 14,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = 0.5,
  }) {
    return GoogleFonts.fredoka(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle badge({
    double fontSize = 11,
    Color color = const Color(0xfffacc15),
    FontWeight fontWeight = FontWeight.w600,
    double letterSpacing = 0.3,
  }) {
    return GoogleFonts.fredoka(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }
}

