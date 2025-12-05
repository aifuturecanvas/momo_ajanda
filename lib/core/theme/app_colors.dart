import 'package:flutter/material.dart';

/// Uygulama renk paleti
class AppColors {
  // Ana renkler
  static const Color primary = Color(0xFF6B4EFF);
  static const Color primaryLight = Color(0xFF9D8AFF);
  static const Color primaryDark = Color(0xFF4A35B0);

  // Defter renkleri
  static const Color notebookPaper = Color(0xFFFFFEF5);
  static const Color notebookLine = Color(0xFFE8E4D9);
  static const Color notebookMargin = Color(0xFFFFCDD2);
  static const Color notebookBinding = Color(0xFF8D6E63);

  // Durum renkleri
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Nötr renkler
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);

  // Gece modu renkleri
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkPaper = Color(0xFF2C2C2C);
  static const Color darkLine = Color(0xFF3D3D3D);
}

/// Defter temaları
class NotebookTheme {
  final String name;
  final Color paperColor;
  final Color lineColor;
  final Color marginColor;
  final Color bindingColor;
  final Color textColor;

  const NotebookTheme({
    required this.name,
    required this.paperColor,
    required this.lineColor,
    required this.marginColor,
    required this.bindingColor,
    required this.textColor,
  });

  // Klasik krem defter
  static const classic = NotebookTheme(
    name: 'Klasik',
    paperColor: Color(0xFFFFFEF5),
    lineColor: Color(0xFFE8E4D9),
    marginColor: Color(0xFFFFCDD2),
    bindingColor: Color(0xFF8D6E63),
    textColor: Color(0xFF1A1A1A),
  );

  // Beyaz defter
  static const white = NotebookTheme(
    name: 'Beyaz',
    paperColor: Color(0xFFFFFFFF),
    lineColor: Color(0xFFE0E0E0),
    marginColor: Color(0xFF90CAF9),
    bindingColor: Color(0xFF1976D2),
    textColor: Color(0xFF1A1A1A),
  );

  // Koyu tema defter
  static const dark = NotebookTheme(
    name: 'Gece',
    paperColor: Color(0xFF2C2C2C),
    lineColor: Color(0xFF3D3D3D),
    marginColor: Color(0xFF5C6BC0),
    bindingColor: Color(0xFF303F9F),
    textColor: Color(0xFFE0E0E0),
  );

  // Vintage defter
  static const vintage = NotebookTheme(
    name: 'Vintage',
    paperColor: Color(0xFFF5E6D3),
    lineColor: Color(0xFFD4C4B0),
    marginColor: Color(0xFFBCAAA4),
    bindingColor: Color(0xFF5D4037),
    textColor: Color(0xFF3E2723),
  );

  // Tüm temalar
  static const List<NotebookTheme> all = [classic, white, dark, vintage];
}
