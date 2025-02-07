import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShadTheme {
  // Colors
  static const background = Color(0xFFFFFFFF);
  static const foreground = Color(0xFF09090B);
  static const muted = Color(0xFF71717A);
  static const mutedForeground = Color(0xFF71717A);
  static const card = Color(0xFFFFFFFF);
  static const cardForeground = Color(0xFF09090B);
  static const popover = Color(0xFFFFFFFF);
  static const popoverForeground = Color(0xFF09090B);
  static const border = Color(0xFFE4E4E7);
  static const input = Color(0xFFE4E4E7);
  static const primary = Color(0xFF18181B);
  static const primaryForeground = Color(0xFFFFFFFF);
  static const secondary = Color(0xFFF4F4F5);
  static const secondaryForeground = Color(0xFF18181B);
  static const accent = Color(0xFFF4F4F5);
  static const accentForeground = Color(0xFF18181B);
  static const destructive = Color(0xFFEF4444);
  static const destructiveForeground = Color(0xFFFFFFFF);
  static const ring = Color(0xFF18181B);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          background: background,
          primary: primary,
          secondary: secondary,
          surface: card,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: border),
          ),
        ),
      );
}
