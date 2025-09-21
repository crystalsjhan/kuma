import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plant_community_app/core/router/app_router.dart';

/// 회원가입 화면
/// 
/// 새로운 사용자 계정을 생성하는 화면입니다.
/// 이메일, 비밀번호, 비밀번호 확인 필드를 포함하며,
/// 최신 디자인 트렌드를 반영한 직관적인 UI를 제공합니다.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // TextEditingController 선언
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // 폼 키
  final _formKey = GlobalKey<FormState>();
  
  // 비밀번호 표시 여부
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  // 로딩 상태
  bool _isLoading = false;
  
  // 약관 동의 상태
  bool _agreeToTerms = false;
  bool _agreeToPrivacy = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// 회원가입 처리
  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms || !_agreeToPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이용약관 및 개인정보처리방침에 동의해주세요'),
        ),
      );
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
      // 3. Firebase Auth로 회원가입 - UserCredential 객체 반환받기
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // 새로 생성된 사용자 정보에 접근
      final user = userCredential.user;
      
      if (mounted && user != null) {
        // 4. 성공 시 SnackBar 표시 (사용자 정보 포함)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원 가입 성공!\nUID: ${user.uid}\nEmail: ${user.email}'),
            backgroundColor: Colors.green,
          ),
        );
        
        // TODO: 성공 후 화면 이동 로직 (홈 화면이나 추가 프로필 설정 화면 등)
        // AppRouter.goHome(context); // 화면 이동은 이후에 관리
      }
    } catch (e) {
      if (mounted) {
        // 5. FirebaseAuthException 처리
        if (e is FirebaseAuthException) {
          String errorMessage;
          switch (e.code) {
            case 'weak-password':
              errorMessage = '비밀번호는 6자리 이상이어야 합니다.';
              break;
            case 'email-already-in-use':
              errorMessage = '이미 사용 중인 이메일입니다.';
              break;
            default:
              errorMessage = '회원 가입 실패: ${e.message}';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else {
          // 기타 예외 처리
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('회원 가입 실패: ${e.toString()}'),
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
      appBar: AppBar(
        title: const Text('회원가입'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20.0),
                
                // 환영 메시지
                _buildWelcomeMessage(theme),
                
                const SizedBox(height: 40.0),
                
                // 회원가입 폼
                _buildSignupForm(theme),
                
                const SizedBox(height: 24.0),
                
                // 약관 동의
                _buildTermsAgreement(theme),
                
                const SizedBox(height: 32.0),
                
                // 회원가입 버튼
                _buildSignupButton(theme),
                
                const SizedBox(height: 24.0),
                
                // 로그인 링크
                _buildLoginLink(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 환영 메시지
  Widget _buildWelcomeMessage(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '반려 식물 커뮤니티에\n오신 것을 환영합니다!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
            height: 1.3,
          ),
        ),
        
        const SizedBox(height: 12.0),
        
        Text(
          '식물과 함께하는 따뜻한 공간에서\n새로운 경험을 시작해보세요.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  /// 회원가입 폼
  Widget _buildSignupForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 이름 입력 필드
        Text(
          '이름',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: _nameController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: '이름을 입력해주세요',
            prefixIcon: Icon(
              Icons.person_outlined,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '이름을 입력해주세요';
            }
            if (value.length < 2) {
              return '이름은 2자 이상이어야 합니다';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 20.0),
        
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
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: '비밀번호를 입력해주세요 (6자 이상)',
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
        
        const SizedBox(height: 20.0),
        
        // 비밀번호 확인 입력 필드
        Text(
          '비밀번호 확인',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_isConfirmPasswordVisible,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleSignup(),
          decoration: InputDecoration(
            hintText: '비밀번호를 다시 입력해주세요',
            prefixIcon: Icon(
              Icons.lock_outlined,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '비밀번호 확인을 입력해주세요';
            }
            if (value != _passwordController.text) {
              return '비밀번호가 일치하지 않습니다';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 약관 동의
  Widget _buildTermsAgreement(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '약관 동의',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onBackground,
          ),
        ),
        
        const SizedBox(height: 12.0),
        
        // 이용약관 동의
        Row(
          children: [
            Checkbox(
              value: _agreeToTerms,
              onChanged: (value) {
                setState(() {
                  _agreeToTerms = value ?? false;
                });
              },
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _agreeToTerms = !_agreeToTerms;
                  });
                },
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    children: [
                      const TextSpan(text: '이용약관에 동의합니다 '),
                      TextSpan(
                        text: '(필수)',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: 이용약관 화면으로 이동
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('이용약관은 준비 중입니다'),
                  ),
                );
              },
              child: Text(
                '보기',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        
        // 개인정보처리방침 동의
        Row(
          children: [
            Checkbox(
              value: _agreeToPrivacy,
              onChanged: (value) {
                setState(() {
                  _agreeToPrivacy = value ?? false;
                });
              },
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _agreeToPrivacy = !_agreeToPrivacy;
                  });
                },
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    children: [
                      const TextSpan(text: '개인정보처리방침에 동의합니다 '),
                      TextSpan(
                        text: '(필수)',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: 개인정보처리방침 화면으로 이동
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('개인정보처리방침은 준비 중입니다'),
                  ),
                );
              },
              child: Text(
                '보기',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 회원가입 버튼
  Widget _buildSignupButton(ThemeData theme) {
    return SizedBox(
      height: 56.0,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignup,
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
                '회원가입',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }

  /// 로그인 링크
  Widget _buildLoginLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '이미 계정이 있으신가요? ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        TextButton(
          onPressed: () {
            AppRouter.goToLogin(context);
          },
          child: Text(
            '로그인',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
