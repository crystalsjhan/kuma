import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plant_community_app/presentation/pages/post_list_page.dart';
import 'package:plant_community_app/presentation/pages/login_screen.dart';
import 'package:plant_community_app/presentation/pages/signup_screen.dart';

/// 앱의 라우팅 설정
/// 
/// go_router를 사용하여 선언적 라우팅을 구현합니다.
/// 추후 게시물 상세, 작성, 프로필 등의 화면이 추가될 때
/// 이 파일에서 라우트를 관리합니다.
class AppRouter {
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String postDetail = '/post/:id';
  static const String createPost = '/create-post';
  static const String editPost = '/edit-post/:id';
  static const String search = '/search';
  static const String profile = '/profile';
  static const String settings = '/settings';

  /// 라우터 인스턴스
  static final GoRouter router = GoRouter(
    initialLocation: login,
    debugLogDiagnostics: true,
    routes: [
      // 홈 화면 (게시물 목록)
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const PostListPage(),
      ),
      
      // 로그인 화면
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // 회원가입 화면
      GoRoute(
        path: signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      
      // 게시물 상세 화면 (추후 구현 예정)
      GoRoute(
        path: postDetail,
        name: 'postDetail',
        builder: (context, state) {
          final postId = state.pathParameters['id']!;
          return _buildComingSoonPage(
            context,
            title: '게시물 상세',
            subtitle: 'Post ID: $postId',
          );
        },
      ),
      
      // 게시물 작성 화면 (추후 구현 예정)
      GoRoute(
        path: createPost,
        name: 'createPost',
        builder: (context, state) => _buildComingSoonPage(
          context,
          title: '게시물 작성',
          subtitle: '새로운 게시물을 작성해보세요',
        ),
      ),
      
      // 게시물 수정 화면 (추후 구현 예정)
      GoRoute(
        path: editPost,
        name: 'editPost',
        builder: (context, state) {
          final postId = state.pathParameters['id']!;
          return _buildComingSoonPage(
            context,
            title: '게시물 수정',
            subtitle: 'Post ID: $postId',
          );
        },
      ),
      
      // 검색 화면 (추후 구현 예정)
      GoRoute(
        path: search,
        name: 'search',
        builder: (context, state) => _buildComingSoonPage(
          context,
          title: '검색',
          subtitle: '게시물을 검색해보세요',
        ),
      ),
      
      // 프로필 화면 (추후 구현 예정)
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => _buildComingSoonPage(
          context,
          title: '프로필',
          subtitle: '사용자 프로필을 확인해보세요',
        ),
      ),
      
      // 설정 화면 (추후 구현 예정)
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => _buildComingSoonPage(
          context,
          title: '설정',
          subtitle: '앱 설정을 변경해보세요',
        ),
      ),
    ],
    errorBuilder: (context, state) => _buildErrorPage(context, state.error),
  );

  /// 라우터 확장 메서드들
  /// 타입 안전한 내비게이션을 위한 헬퍼 메서드들입니다.
  
  /// 홈 화면으로 이동
  static void goHome(BuildContext context) {
    context.go(home);
  }
  
  /// 로그인 화면으로 이동
  static void goToLogin(BuildContext context) {
    context.go(login);
  }
  
  /// 회원가입 화면으로 이동
  static void goToSignup(BuildContext context) {
    context.go(signup);
  }
  
  /// 게시물 상세 화면으로 이동
  static void goToPostDetail(BuildContext context, String postId) {
    context.go('/post/$postId');
  }
  
  /// 게시물 작성 화면으로 이동
  static void goToCreatePost(BuildContext context) {
    context.go(createPost);
  }
  
  /// 게시물 수정 화면으로 이동
  static void goToEditPost(BuildContext context, String postId) {
    context.go('/edit-post/$postId');
  }
  
  /// 검색 화면으로 이동
  static void goToSearch(BuildContext context) {
    context.go(search);
  }
  
  /// 프로필 화면으로 이동
  static void goToProfile(BuildContext context) {
    context.go(profile);
  }
  
  /// 설정 화면으로 이동
  static void goToSettings(BuildContext context) {
    context.go(settings);
  }
  
  /// 뒤로 가기
  static void goBack(BuildContext context) {
    context.pop();
  }

  /// 준비 중 화면 빌더
  /// 아직 구현되지 않은 화면들을 위한 임시 화면입니다.
  static Widget _buildComingSoonPage(
    BuildContext context, {
    required String title,
    String? subtitle,
  }) {
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
              if (subtitle != null) ...[
                const SizedBox(height: 8.0),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
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

  /// 에러 화면 빌더
  /// 라우팅 에러가 발생했을 때 표시되는 화면입니다.
  static Widget _buildErrorPage(BuildContext context, Exception? error) {
    return Scaffold(
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
              if (error != null) ...[
                const SizedBox(height: 16.0),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32.0),
              ElevatedButton.icon(
                onPressed: () => context.go(home),
                icon: const Icon(Icons.home),
                label: const Text('홈으로 가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 라우터 확장 메서드
/// GoRouter의 기능을 확장하여 더 편리한 사용을 제공합니다.
extension AppRouterExtension on BuildContext {
  /// 현재 라우트 이름 가져오기
  String? get currentRouteName {
    final router = GoRouter.of(this);
    final RouteMatchList matchList = router.routerDelegate.currentConfiguration;
    if (matchList.matches.isNotEmpty) {
      final route = matchList.matches.last.route;
      if (route is GoRoute) {
        return route.name;
      }
    }
    return null;
  }
  
  /// 현재 위치가 홈인지 확인
  bool get isHome => GoRouterState.of(this).uri.toString() == AppRouter.home;
  
  /// 현재 위치가 특정 경로인지 확인
  bool isCurrentPath(String path) => GoRouterState.of(this).uri.toString() == path;
}
