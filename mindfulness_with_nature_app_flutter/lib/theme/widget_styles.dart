// lib/theme/widget_styles.dart
import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppStyles {
  // Card styles
  static BoxDecoration get subtleCard => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.softShadow,
        blurRadius: 12,
        offset: Offset(0, 2),
      ),
    ],
  );
  
  static BoxDecoration get minimalCard => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.paleSage, width: 1),
  );
  
  static BoxDecoration get softGradientCard => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.paleSkyBlue, AppColors.paleSand],
    ),
    borderRadius: BorderRadius.circular(20),
  );
  
  // Meditation session card
  static BoxDecoration get sessionCard => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white, AppColors.paleSand],
    ),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.softSage, width: 1),
  );
  
  // Button styles
  static ButtonStyle get softElevatedButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.softSkyBlue,
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  );
  
  static ButtonStyle get minimalButton => TextButton.styleFrom(
    foregroundColor: AppColors.sageGreen,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
  
  // Text styles
  static TextStyle get heading1 => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.charcoal,
    fontFamily: 'Inter',
  );
  
  static TextStyle get heading2 => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.charcoal,
    fontFamily: 'Inter',
  );
  
  static TextStyle get bodyText => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.slate,
    fontFamily: 'Inter',
    height: 1.6,
  );
  
  static TextStyle get caption => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.stone,
    fontFamily: 'Inter',
  );
  
  // Input styles
  static InputDecoration get searchInput => InputDecoration(
    filled: true,
    fillColor: Colors.white,
    hintText: 'Search...',
    prefixIcon: Icon(Icons.search, color: AppColors.stone),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}