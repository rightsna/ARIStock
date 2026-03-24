import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 앱의 전역 테마 설정을 관리하는 클래스입니다.
/// 비개발자도 이해하기 쉬운 깔끔하고 현대적인 디자인을 지향합니다.
class AppTheme {
  // 메인 브랜드 색상 (현대적이고 밝은 코발트 블루)
  static const Color primaryBlue = Color(0xFF3182F6);
  static const Color backgroundLight = Color(0xFFF2F4F6); // 밝은 회색 배경
  static const Color surfaceWhite = Color(0xFFFFFFFF);    // 카드용 순백색
  static const Color accentGreen = Color(0xFF2CB856);    // 상승 (Profit) - 더 밝고 선명하게
  static const Color accentRed = Color(0xFFF04452);       // 하락 (Loss) - 고채도 레드
  
  static const Color textMain = Color(0xFF191F28);       // 메인 텍스트
  static const Color textSub = Color(0xFF4E5968);        // 서브 텍스트
  
  // Const 지원을 위해 하드코딩된 알파값 사용
  static const Color textMain10 = Color(0x1A191F28);
  static const Color textMain24 = Color(0x3D191F28);
  static const Color textMain38 = Color(0x61191F28);
  static const Color textMain54 = Color(0x8A191F28);
  static const Color textMain60 = Color(0x99191F28);
  static const Color textMain70 = Color(0xB3191F28);

  static const Color surfaceDark = Color(0xFF1A1C1E); // 어두운 테마용 서브 배경
  static const Color darkBackground = Color(0xFF0F1011); // 어두운 테마용 메인 배경

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: ColorScheme.light(
      primary: primaryBlue,
      secondary: accentGreen,
      surface: surfaceWhite,
      onPrimary: Colors.white,
      onSurface: textMain,
    ),
    // 텍스트 테마 (Google Fonts 사용)
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
      displayLarge: const TextStyle(fontWeight: FontWeight.bold, color: textMain),
      titleLarge: const TextStyle(fontWeight: FontWeight.w600, color: textMain, fontSize: 18),
      bodyLarge: const TextStyle(color: textMain),
      bodyMedium: const TextStyle(color: textSub),
    ),
    // 카드 디자인 (그림자 추가 및 테두리 제거)
    cardTheme: CardThemeData(
      color: surfaceWhite,
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    // 앱바 디자인
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textMain),
      titleTextStyle: TextStyle(
        color: textMain,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    // 버튼 테마 수정 (가시성 확보)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    ),
  );

  // 기존 darkTheme은 유지는 하되, 기본을 lightTheme으로 전환하기 위해 이름을 바꿈
  static final ThemeData darkTheme = lightTheme; // 일단 라이트 테마를 기본으로 사용하도록 설정
}
