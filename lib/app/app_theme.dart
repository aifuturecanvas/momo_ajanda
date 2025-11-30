import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Taslaklardan alınan ana marka renklerimiz
const Color momoBlue = Color(0xFF5A95E8);
const Color momoBackground = Color(0xFFF5F8FA); // Hafif kırık beyaz/mavi
const Color momoDarkText = Color(0xFF333A49);
const Color momoLightGrey = Color(0xFFE8EAF0); // Giriş alanları için

class AppTheme {
  static ThemeData getTheme() {
    return ThemeData(
      // 1. GENEL RENKLER VE TEMEL AYARLAR
      primaryColor: momoBlue,
      scaffoldBackgroundColor: momoBackground, // Tüm ekranların arka plan rengi
      splashColor: momoBlue.withOpacity(0.1),
      highlightColor: momoBlue.withOpacity(0.1),

      // 2. YAZI TİPİ VE STİLLERİ
      textTheme: GoogleFonts.nunitoSansTextTheme(
        ThemeData.light().textTheme,
      ).copyWith(
        headlineSmall: const TextStyle(
          color: momoDarkText,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: const TextStyle(
          color: momoDarkText,
          fontWeight: FontWeight.bold,
        ),
        titleMedium:
            const TextStyle(color: momoDarkText, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: momoDarkText.withOpacity(0.8)),
        bodyMedium: TextStyle(color: momoDarkText.withOpacity(0.9)),
      ),

      // 3. BUTON STİLLERİ
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: momoBlue,
          foregroundColor: Colors.white,
          elevation: 0, // Tasarımdaki gibi düz ve gölgesiz
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: momoBlue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),

      // 4. GİRİŞ ALANI (TEXTFIELD) STİLLERİ
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: momoBlue, width: 2),
        ),
      ),

      // 5. KART STİLLERİ
      cardTheme: CardTheme(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200, width: 1)),
        margin: const EdgeInsets.only(
            bottom: 0), // Dikey boşluğu ListView'dan vereceğiz
      ),

      // 6. ALT NAVİGASYON MENÜSÜ STİLİ
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: momoBlue,
        unselectedItemColor: Colors.grey.shade500,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // 7. APPBAR STİLİ
      appBarTheme: AppBarTheme(
        backgroundColor: momoBackground, // Arka planla aynı renk
        foregroundColor: momoDarkText, // Geri butonu gibi ikonların rengi
        elevation: 0,
        titleTextStyle: GoogleFonts.nunitoSans(
          color: momoDarkText,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
