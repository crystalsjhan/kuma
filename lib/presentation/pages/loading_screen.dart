import 'package:flutter/material.dart';

/// 로딩 화면
/// 
/// 인증 상태를 확인하는 동안 표시되는 로딩 화면입니다.
/// Design System을 적용한 깔끔한 로딩 UI를 제공합니다.
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 로고
            Container(
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Icon(
                Icons.local_florist,
                size: 40.0,
                color: colorScheme.onPrimary,
              ),
            ),
            
            const SizedBox(height: 32.0),
            
            // 앱 이름
            Text(
              '반려 식물 커뮤니티',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            
            const SizedBox(height: 8.0),
            
            // 부제목
            Text(
              '식물과 함께하는 따뜻한 공간',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            
            const SizedBox(height: 48.0),
            
            // 로딩 인디케이터
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                colorScheme.primary,
              ),
              strokeWidth: 3.0,
            ),
            
            const SizedBox(height: 24.0),
            
            // 로딩 메시지
            Text(
              '잠시만 기다려주세요...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
