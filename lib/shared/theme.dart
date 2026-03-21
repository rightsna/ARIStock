import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 앱의 전역 테마 설정을 관리하는 클래스입니다.
/// 비개발자도 이해하기 쉬운 깔끔하고 현대적인 디자인을 지향합니다.
class AppTheme {
  // 메인 브랜드 색상 (세련된 블루 및 딥 다크)
  static const Color primaryBlue = Color(0xFF2962FF);
  static const Color darkBackground = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color accentGreen = Color(0xFF00C853); // 상승 (Profit)
  static const Color accentRed = Color(0xFFD50000);   // 하락 (Loss)

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: accentGreen,
      surface: surfaceDark,
    ),
    // 텍스트 테마 (Google Fonts 사용)
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
    ),
    // 카드 디자인 통일
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
    ),
    // 앱바 디자인
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      centerTitle: false,
    ),
  );
}
