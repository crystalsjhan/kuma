import 'package:flutter/material.dart';

/// 반려 식물 앱의 색상 시스템
/// Design System 문서에 정의된 색상을 기반으로 구성
class AppColors {
  AppColors._();

  // Light Theme Colors
  static const Color primaryLight = Color(0xFF608263); // 차분한 세이지 그린
  static const Color primaryVariantLight = Color(0xFF4A664F); // 더 진한 딥 그린
  static const Color secondaryLight = Color(0xFFD8A37B); // 부드러운 테라코타
  static const Color backgroundLight = Color(0xFFFFFFFF); // 흰색
  static const Color surfaceLight = Color(0xFFFAFAFA); // 매우 밝은 회색
  static const Color outlineLight = Color(0xFFE0E0E0); // 연한 회색
  static const Color onPrimaryLight = Color(0xFFFFFFFF); // Primary 위 텍스트
  static const Color onSecondaryLight = Color(0xFF000000); // Secondary 위 텍스트
  static const Color onBackgroundLight = Color(0xFF333333); // 기본 텍스트
  static const Color textSecondaryLight = Color(0xFF757575); // 보조 텍스트
  static const Color errorLight = Color(0xFFD32F2F); // 에러 색상

  // Dark Theme Colors
  static const Color primaryDark = Color(0xFFA8D5A9); // 밝고 부드러운 그린
  static const Color primaryVariantDark = Color(0xFFB9E0BA);
  static const Color secondaryDark = Color(0xFFEACAA8); // 연한 샌디 브라운
  static const Color backgroundDark = Color(0xFF121212); // 어두운 회색
  static const Color surfaceDark = Color(0xFF242424); // 약간 밝은 어두운 회색
  static const Color outlineDark = Color(0xFF555555); // 어두운 회색 구분선
  static const Color onPrimaryDark = Color(0xFF212121); // 진한 회색
  static const Color onSecondaryDark = Color(0xFF212121); // 진한 회색
  static const Color onBackgroundDark = Color(0xFFE0E0E0); // 밝은 회색 텍스트
  static const Color textSecondaryDark = Color(0xFFBDBDBD); // 연한 회색 보조 텍스트
  static const Color errorDark = Color(0xFFF8A098); // 밝은 오류 색상

  // Light Theme ColorScheme
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryLight,
    onPrimary: onPrimaryLight,
    secondary: secondaryLight,
    onSecondary: onSecondaryLight,
    surface: surfaceLight,
    onSurface: onBackgroundLight,
    background: backgroundLight,
    onBackground: onBackgroundLight,
    error: errorLight,
    onError: onPrimaryLight,
    outline: outlineLight,
  );

  // Dark Theme ColorScheme
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryDark,
    onPrimary: onPrimaryDark,
    secondary: secondaryDark,
    onSecondary: onSecondaryDark,
    surface: surfaceDark,
    onSurface: onBackgroundDark,
    background: backgroundDark,
    onBackground: onBackgroundDark,
    error: errorDark,
    onError: onPrimaryDark,
    outline: outlineDark,
  );
}

