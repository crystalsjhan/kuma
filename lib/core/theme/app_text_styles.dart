import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 반려 식물 앱의 타이포그래피 시스템
/// Design System 문서에 정의된 텍스트 스타일을 기반으로 구성
class AppTextStyles {
  AppTextStyles._();

  // Base Font Family
  static const String _fontFamily = 'NotoSansKR';

  /// AppBar 제목용 스타일
  static TextStyle get headlineLarge => GoogleFonts.notoSansKr(
        fontWeight: FontWeight.bold,
        fontSize: 22.0,
        letterSpacing: -0.5,
      );

  /// 게시물 제목용 스타일
  static TextStyle get titleLarge => GoogleFonts.notoSansKr(
        fontWeight: FontWeight.bold,
        fontSize: 18.0,
        letterSpacing: -0.25,
      );

  /// 섹션 제목용 스타일
  static TextStyle get titleMedium => GoogleFonts.notoSansKr(
        fontWeight: FontWeight.bold,
        fontSize: 16.0,
      );

  /// 게시물 내용용 스타일
  static TextStyle get bodyLarge => GoogleFonts.notoSansKr(
        fontWeight: FontWeight.normal,
        fontSize: 16.0,
        height: 1.5,
      );

  /// 기본 텍스트 스타일
  static TextStyle get bodyMedium => GoogleFonts.notoSansKr(
        fontWeight: FontWeight.normal,
        fontSize: 14.0,
      );

  /// 버튼 텍스트 스타일
  static TextStyle get labelLarge => GoogleFonts.notoSansKr(
        fontWeight: FontWeight.bold,
        fontSize: 14.0,
      );

  /// 중간 라벨 스타일
  static TextStyle get labelMedium => GoogleFonts.notoSansKr(
        fontWeight: FontWeight.w500,
        fontSize: 12.0,
      );

  /// 캡션, 메타 정보용 스타일
  static TextStyle get bodySmall => GoogleFonts.notoSansKr(
        fontWeight: FontWeight.normal,
        fontSize: 12.0,
      );

  /// TextTheme 생성
  static TextTheme createTextTheme(Color textColor, Color textSecondaryColor) {
    return TextTheme(
      headlineLarge: headlineLarge.copyWith(color: textColor),
      titleLarge: titleLarge.copyWith(color: textColor),
      titleMedium: titleMedium.copyWith(color: textColor),
      bodyLarge: bodyLarge.copyWith(color: textColor),
      bodyMedium: bodyMedium.copyWith(color: textColor),
      labelLarge: labelLarge.copyWith(color: textColor),
      labelMedium: labelMedium.copyWith(color: textColor),
      bodySmall: bodySmall.copyWith(color: textSecondaryColor),
    );
  }
}
