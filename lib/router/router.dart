import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plant_community_app/providers/auth_providers.dart';
import 'package:plant_community_app/presentation/pages/login_screen.dart';
import 'package:plant_community_app/presentation/pages/signup_screen.dart';
import 'package:plant_community_app/presentation/pages/post_list_page.dart';
import 'package:plant_community_app/presentation/pages/profile_screen.dart';
import 'package:plant_community_app/presentation/pages/loading_screen.dart';

/// GoRouter 설정
/// 
/// 앱의 라우팅을 관리하며, 인증 상태에 따른 자동 리다이렉트 기능을 제공합니다.
/// Riverpod Provider와 연동하여 실시간 인증 상태 변경을 감지합니다.

/// GoRouter 인스턴스를 제공하는 Riverpod Provider
final goRouterProvider = Provider<GoRouter>((ref) {
  // 인증 상태 변경을 감지하기 위한 ValueNotifier
  final authStateNotifier = ValueNotifier<User?>(null);
  
  // authStateChangesProvider를 구독하여 ValueNotifier 업데이트
  ref.listen(authStateChangesProvider, (previous, next) {
    next.when(
      data: (user) {
        // 디버그 로그 추가
        print('Auth state changed: ${user?.email ?? 'null'}');
        authStateNotifier.value = user;
        // 리다이렉트 트리거를 위해 강제로 알림
        authStateNotifier.notifyListeners();
      },
      loading: () {
        // 로딩 중일 때는 현재 값을 유지
        print('Auth state loading...');
      },
      error: (error, stackTrace) {
        // 에러 발생 시 null로 설정
        print('Auth state error: $error');
        authStateNotifier.value = null;
        authStateNotifier.notifyListeners();
      },
    );
  });

  return GoRouter(
    // 초기 경로 설정
    initialLocation: '/loading',
    
    // 디버그 로그 활성화
    debugLogDiagnostics: true,
    
    // 인증 상태 변경 시 redirect 로직 재실행
    refreshListenable: authStateNotifier,
    
    // 리다이렉트 로직
    redirect: (context, state) {
      // 현재 경로
      final currentPath = state.uri.toString();
      
      // 현재 사용자 상태 확인
      final currentUser = authStateNotifier.value;
      
      print('Redirect check - Path: $currentPath, User: ${currentUser?.email ?? 'null'}');
      
      // 로딩 화면에서 처리 - 직접 리다이렉트
      if (currentPath == '/loading') {
        if (currentUser != null) {
          print('Redirecting logged in user to home');
          return '/'; // 로그인된 사용자는 홈으로
        } else {
          print('Redirecting anonymous user to login');
          return '/login'; // 로그인되지 않은 사용자는 로그인 화면으로
        }
      }
      
      // 인증이 필요한 경로에 로그인하지 않은 사용자가 접근하는 경우
      if (currentUser == null && !_isAuthRoute(currentPath)) {
        return '/login';
      }
      
      // 로그인된 사용자가 로그인/회원가입 화면에 접근하는 경우
      if (currentUser != null && (currentPath == '/login' || currentPath == '/signup')) {
        return '/';
      }
      
      // 리다이렉트하지 않음
      return null;
    },
    
    // 라우트 정의
    routes: [
      // 로딩 화면
      GoRoute(
        path: '/loading',
        name: 'loading',
        builder: (context, state) => const LoadingScreen(),
      ),
      
      // 로그인 화면
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // 회원가입 화면
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      
      // 홈 화면 (게시물 목록)
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const PostListPage(),
      ),
      
      // 프로필 화면
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      
      // 비밀번호 찾기 화면 (추후 구현 예정)
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const _ComingSoonPage(
          title: '비밀번호 찾기',
          subtitle: '비밀번호를 재설정할 수 있습니다',
        ),
      ),
    ],
    
    // 에러 화면
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('페이지를 찾을 수 없습니다'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80.0,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24.0),
              Text(
                '404',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                '요청하신 페이지를 찾을 수 없습니다',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32.0),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home),
                label: const Text('홈으로 가기'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});

/// 인증 관련 경로인지 확인하는 헬퍼 함수
bool _isAuthRoute(String path) {
  return path == '/login' || 
         path == '/signup' || 
         path == '/forgot-password' ||
         path == '/loading';
}

/// 준비 중 화면
class _ComingSoonPage extends StatelessWidget {
  const _ComingSoonPage({
    required this.title,
    required this.subtitle,
  });
  
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 80.0,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24.0),
              Text(
                '준비 중입니다',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32.0),
              ElevatedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('돌아가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
