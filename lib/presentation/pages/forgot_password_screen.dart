import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

/// 비밀번호 찾기 화면
/// 
/// 사용자가 비밀번호를 잊었을 때 이메일을 통해 비밀번호 재설정 링크를 받을 수 있는 화면입니다.
/// Design System을 적용한 깔끔하고 직관적인 UI를 제공합니다.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // TextEditingController 선언
  final _emailController = TextEditingController();
  
  // 폼 키
  final _formKey = GlobalKey<FormState>();
  
  // 로딩 상태
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// 비밀번호 재설정 메일 발송 처리
  Future<void> _handleSendResetEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 이메일 가져오기
    final email = _emailController.text.trim();
    
    // 이메일 유효성 검사 (비어있거나 @ 포함 여부 확인)
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('유효한 이메일을 입력해주세요.'),
        ),
      );
      return;
    }

    // 로딩 상태 설정
    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase Auth로 비밀번호 재설정 메일 발송
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      
      if (mounted) {
        // 성공 시 SnackBar 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('비밀번호 재설정 메일이 발송되었습니다. 이메일을 확인해주세요.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // 로그인 화면으로 돌아가기
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        // FirebaseAuthException 처리
        if (e is FirebaseAuthException) {
          String errorMessage;
          switch (e.code) {
            case 'user-not-found':
              errorMessage = '등록되지 않은 이메일입니다.';
              break;
            default:
              errorMessage = '메일 발송에 실패했습니다: ${e.message}';
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
              content: Text('메일 발송에 실패했습니다: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } finally {
      // 로딩 상태 해제
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
        title: const Text('비밀번호 찾기'),
        centerTitle: true,
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
                const SizedBox(height: 40.0),
                
                // 헤더 섹션
                _buildHeader(theme),
                
                const SizedBox(height: 40.0),
                
                // 이메일 입력 폼
                _buildEmailForm(theme),
                
                const SizedBox(height: 32.0),
                
                // 재설정 메일 발송 버튼
                _buildSendButton(theme),
                
                const SizedBox(height: 24.0),
                
                // 도움말 텍스트
                _buildHelpText(theme),
                
                const SizedBox(height: 40.0),
                
                // 로그인 화면으로 돌아가기 링크
                _buildBackToLoginLink(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 헤더 섹션
  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        // 아이콘
        Container(
          width: 80.0,
          height: 80.0,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Icon(
            Icons.lock_reset,
            size: 40.0,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 24.0),
        
        // 제목
        Text(
          '비밀번호를 잊으셨나요?',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12.0),
        
        // 부제목
        Text(
          '가입하신 이메일 주소를 입력하시면\n비밀번호 재설정 링크를 보내드립니다.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 이메일 입력 폼
  Widget _buildEmailForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleSendResetEmail(),
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
      ],
    );
  }

  /// 재설정 메일 발송 버튼
  Widget _buildSendButton(ThemeData theme) {
    return SizedBox(
      height: 56.0,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleSendResetEmail,
        icon: _isLoading
            ? SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : const Icon(Icons.send),
        label: Text(
          _isLoading ? '발송 중...' : '재설정 메일 발송',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  /// 도움말 텍스트
  Widget _buildHelpText(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.primary,
            size: 20.0,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              '메일이 오지 않는다면 스팸 폴더를 확인해보세요.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 로그인 화면으로 돌아가기 링크
  Widget _buildBackToLoginLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '비밀번호가 기억나셨나요? ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        TextButton(
          onPressed: () => context.pop(),
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
