import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plant_community_app/core/router/app_router.dart';

/// 로그인 화면
/// 
/// 이메일과 비밀번호를 입력받아 사용자를 인증하는 화면입니다.
/// 최신 디자인 트렌드를 반영한 깔끔하고 직관적인 UI를 제공합니다.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // TextEditingController 선언
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // 폼 키
  final _formKey = GlobalKey<FormState>();
  
  // 비밀번호 표시 여부
  bool _isPasswordVisible = false;
  
  // 로딩 상태
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 로그인 처리
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 1. 이메일과 비밀번호 가져오기
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이메일과 비밀번호를 입력해주세요.'),
        ),
      );
      return;
    }

    // 2. 로딩 상태 설정
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. Firebase Auth로 로그인
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      if (mounted) {
        // 4. 성공 시 SnackBar 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인 성공!'),
            backgroundColor: Colors.green,
          ),
        );
        // 로그인 성공 시 홈 화면으로 이동
        AppRouter.goHome(context);
      }
    } catch (e) {
      if (mounted) {
        // 5. FirebaseAuthException 처리
        if (e is FirebaseAuthException) {
          String errorMessage;
          // 실제 Firebase Auth 에러 코드를 확인하여 디버깅
          print('Firebase Auth Error Code: ${e.code}');
          print('Firebase Auth Error Message: ${e.message}');
          
          switch (e.code) {
            case 'user-not-found':
            case 'wrong-password':
            case 'invalid-credential':
              errorMessage = '이메일 또는 비밀번호가 올바르지 않습니다.';
              break;
            case 'invalid-email':
              errorMessage = '유효하지 않은 이메일 형식입니다.';
              break;
            case 'user-disabled':
              errorMessage = '비활성화된 계정입니다.';
              break;
            case 'too-many-requests':
              errorMessage = '너무 많은 로그인 시도가 있었습니다. 잠시 후 다시 시도해주세요.';
              break;
            case 'network-request-failed':
              errorMessage = '네트워크 연결을 확인해주세요.';
              break;
            default:
              errorMessage = '로그인 실패: ${e.message} (코드: ${e.code})';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else {
          // 기타 예외 처리
          print('Non-Firebase Exception: ${e.toString()}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('로그인 실패: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } finally {
      // 6. 로딩 상태 해제
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60.0),
                
                // 앱 로고/제목 영역
                _buildHeader(theme),
                
                const SizedBox(height: 60.0),
                
                // 로그인 폼
                _buildLoginForm(theme),
                
                const SizedBox(height: 32.0),
                
                // 로그인 버튼
                _buildLoginButton(theme),
                
                const SizedBox(height: 24.0),
                
                // 회원가입 링크
                _buildSignupLink(theme),
                
                const SizedBox(height: 40.0),
                
                // 소셜 로그인 (추후 구현)
                _buildSocialLogin(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 헤더 영역 (로고/제목)
  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        // 앱 아이콘
        Container(
          width: 80.0,
          height: 80.0,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Icon(
            Icons.local_florist,
            size: 40.0,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        
        const SizedBox(height: 24.0),
        
        // 앱 제목
        Text(
          '반려 식물 커뮤니티',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
        
        const SizedBox(height: 8.0),
        
        // 부제목
        Text(
          '식물과 함께하는 따뜻한 공간',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  /// 로그인 폼
  Widget _buildLoginForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 이메일 입력 필드
        Text(
          '이메일',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: '이메일을 입력해주세요',
            prefixIcon: Icon(
              Icons.email_outlined,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '이메일을 입력해주세요';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return '올바른 이메일 형식을 입력해주세요';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 20.0),
        
        // 비밀번호 입력 필드
        Text(
          '비밀번호',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleLogin(),
          decoration: InputDecoration(
            hintText: '비밀번호를 입력해주세요',
            prefixIcon: Icon(
              Icons.lock_outlined,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '비밀번호를 입력해주세요';
            }
            if (value.length < 6) {
              return '비밀번호는 6자 이상이어야 합니다';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16.0),
        
        // 비밀번호 찾기 링크
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // TODO: 비밀번호 찾기 화면으로 이동
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('비밀번호 찾기 기능은 준비 중입니다'),
                ),
              );
            },
            child: Text(
              '비밀번호를 잊으셨나요?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 로그인 버튼
  Widget _buildLoginButton(ThemeData theme) {
    return SizedBox(
      height: 56.0,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        child: _isLoading
            ? SizedBox(
                width: 24.0,
                height: 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : Text(
                '로그인',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }

  /// 회원가입 링크
  Widget _buildSignupLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '계정이 없으신가요? ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        TextButton(
          onPressed: () {
            AppRouter.goToSignup(context);
          },
          child: Text(
            '회원가입',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// 소셜 로그인 (추후 구현)
  Widget _buildSocialLogin(ThemeData theme) {
    return Column(
      children: [
        // 구분선
        Row(
          children: [
            Expanded(
              child: Divider(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '또는',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24.0),
        
        // 소셜 로그인 버튼들
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('구글 로그인은 준비 중입니다'),
                    ),
                  );
                },
                icon: const Icon(Icons.g_mobiledata, size: 24.0),
                label: const Text('Google'),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('애플 로그인은 준비 중입니다'),
                    ),
                  );
                },
                icon: const Icon(Icons.apple, size: 24.0),
                label: const Text('Apple'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
