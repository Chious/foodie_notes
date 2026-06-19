import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  static TextStyle heroNumber({double fontSize = 60, Color? color}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: FontWeight.w300,
      letterSpacing: -2,
      height: 0.85,
      color: color ?? AppColors.dark,
    );
  }

  static TextStyle number({double fontSize = 22, Color? color}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.dark,
    );
  }

  static TextStyle label({Color? color}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
      color: color ?? AppColors.mutedText,
    );
  }

  static TextStyle sectionLabel({Color? color}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 2,
      color: color ?? AppColors.mutedText,
    );
  }

  static TextStyle title({double fontSize = 34, Color? color}) {
    return GoogleFonts.notoSansTc(
      fontSize: fontSize,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
      color: color ?? AppColors.dark,
    );
  }

  static TextStyle body({double fontSize = 15, Color? color}) {
    return GoogleFonts.notoSansTc(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.dark,
    );
  }

  static TextStyle bodyBold({double fontSize = 15, Color? color}) {
    return GoogleFonts.notoSansTc(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.dark,
    );
  }

  static TextStyle unit({double fontSize = 13, Color? color}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.mutedText,
    );
  }

  static TextStyle suffix({double fontSize = 15, Color? color}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      color: color ?? AppColors.mutedText,
    );
  }
}
