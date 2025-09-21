import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_community_app/core/constants/app_constants.dart';
import 'package:plant_community_app/core/router/app_router.dart';
import 'package:plant_community_app/core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 반려 식물 커뮤니티 앱의 메인 진입점
/// 
/// 이 앱은 다음 기술을 사용하여 구현되었습니다:
/// - Clean Architecture
/// - Riverpod 상태 관리
/// - go_router 라우팅
/// - Material Design 3
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);

  runApp(
    // Riverpod ProviderScope로 앱 전체를 감쌉니다.
    // 이를 통해 앱 전반에서 Provider들을 사용할 수 있습니다.
    const ProviderScope(
      child: PlantCommunityApp(),
    ),
  );
}

/// 반려 식물 커뮤니티 메인 앱 클래스
class PlantCommunityApp extends StatelessWidget {
  const PlantCommunityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // 앱 기본 정보
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // 테마 설정
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // 시스템 설정에 따라 자동 변경
      
      // 라우터 설정
      routerConfig: AppRouter.router,
      
      // 빌더를 통한 추가 설정
      builder: (context, child) {
        return MediaQuery(
          // 텍스트 스케일 팩터 제한 (접근성 고려)
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
          ),
          child: child!,
        );
      },
    );
  }
}
