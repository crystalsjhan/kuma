import 'package:flutter/material.dart';
import 'package:plant_community_app/core/theme/app_colors.dart';
import 'package:plant_community_app/core/theme/app_text_styles.dart';
import 'package:plant_community_app/core/theme/app_component_themes.dart';

/// 반려 식물 앱의 메인 테마 설정
/// Light Theme와 Dark Theme를 모두 제공
class AppTheme {
  AppTheme._();

  /// Light Theme 설정
  static ThemeData get lightTheme {
    const colorScheme = AppColors.lightColorScheme;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTextStyles.createTextTheme(
        AppColors.onBackgroundLight,
        AppColors.textSecondaryLight,
      ),
      elevatedButtonTheme: AppComponentThemes.elevatedButtonTheme(colorScheme),
      outlinedButtonTheme: AppComponentThemes.outlinedButtonTheme(colorScheme),
      textButtonTheme: AppComponentThemes.textButtonTheme(colorScheme),
      inputDecorationTheme: AppComponentThemes.inputDecorationTheme(colorScheme),
      cardTheme: AppComponentThemes.cardTheme(colorScheme),
      appBarTheme: AppComponentThemes.appBarTheme(colorScheme),
      bottomNavigationBarTheme: AppComponentThemes.bottomNavigationBarTheme(colorScheme),
      floatingActionButtonTheme: AppComponentThemes.floatingActionButtonTheme(colorScheme),
      scaffoldBackgroundColor: colorScheme.background,
      dividerColor: colorScheme.outline,
      
      // Material 3 추가 설정
      splashFactory: InkRipple.splashFactory,
    );
  }

  /// Dark Theme 설정
  static ThemeData get darkTheme {
    const colorScheme = AppColors.darkColorScheme;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTextStyles.createTextTheme(
        AppColors.onBackgroundDark,
        AppColors.textSecondaryDark,
      ),
      elevatedButtonTheme: AppComponentThemes.elevatedButtonTheme(colorScheme),
      outlinedButtonTheme: AppComponentThemes.outlinedButtonTheme(colorScheme),
      textButtonTheme: AppComponentThemes.textButtonTheme(colorScheme),
      inputDecorationTheme: AppComponentThemes.inputDecorationTheme(colorScheme),
      cardTheme: AppComponentThemes.cardTheme(colorScheme),
      appBarTheme: AppComponentThemes.appBarTheme(colorScheme),
      bottomNavigationBarTheme: AppComponentThemes.bottomNavigationBarTheme(colorScheme),
      floatingActionButtonTheme: AppComponentThemes.floatingActionButtonTheme(colorScheme),
      scaffoldBackgroundColor: colorScheme.background,
      dividerColor: colorScheme.outline,
      
      // Material 3 추가 설정
      splashFactory: InkRipple.splashFactory,
    );
  }
}
