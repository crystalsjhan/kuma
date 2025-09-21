import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plant_community_app/core/router/app_router.dart';

/// 프로필 화면
/// 
/// 사용자의 프로필 정보를 표시하고 계정 관련 기능을 제공하는 화면입니다.
/// Design System을 적용한 깔끔하고 직관적인 UI를 제공합니다.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  /// 현재 로그인된 사용자 정보 가져오기
  void _getCurrentUser() {
    _currentUser = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  /// 로그아웃 처리
  Future<void> _handleLogout() async {
    // 확인 다이얼로그 표시
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말로 로그아웃하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('로그아웃'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        // 1. Firebase Auth 로그아웃
        await FirebaseAuth.instance.signOut();
        
        if (mounted) {
          // 2. 성공 시 SnackBar 표시
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('로그아웃 되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
          // TODO: 화면 이동은 상태 관리 리스너가 처리할 예정
        }
      } catch (e) {
        if (mounted) {
          // 3. 에러 처리
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('로그아웃 중 오류가 발생했습니다: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _currentUser == null
            ? _buildNotLoggedInState(theme)
            : _buildProfileContent(theme),
      ),
    );
  }

  /// 로그인하지 않은 상태 UI
  Widget _buildNotLoggedInState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80.0,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24.0),
            Text(
              '로그인이 필요합니다',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '로그인하여 프로필을 확인해보세요',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),
            ElevatedButton.icon(
              onPressed: () => AppRouter.goToLogin(context),
              icon: const Icon(Icons.login),
              label: const Text('로그인'),
            ),
          ],
        ),
      ),
    );
  }

  /// 프로필 콘텐츠
  Widget _buildProfileContent(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 헤더
          _buildProfileHeader(theme),
          
          const SizedBox(height: 32.0),
          
          // 프로필 정보 카드
          _buildProfileInfoCard(theme),
          
          const SizedBox(height: 24.0),
          
          // 계정 설정 섹션
          _buildAccountSection(theme),
          
          const SizedBox(height: 24.0),
          
          // 로그아웃 버튼 (가장 아래)
          _buildLogoutButton(theme),
          
          const SizedBox(height: 32.0),
        ],
      ),
    );
  }

  /// 프로필 헤더
  Widget _buildProfileHeader(ThemeData theme) {
    return Column(
      children: [
        // 프로필 이미지
        CircleAvatar(
          radius: 50.0,
          backgroundColor: theme.colorScheme.primary,
          child: Text(
            _currentUser?.email?.substring(0, 1).toUpperCase() ?? 'U',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(height: 16.0),
        
        // 사용자 이름
        Text(
          _currentUser?.displayName ?? '사용자',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
        
        const SizedBox(height: 4.0),
        
        // 이메일
        Text(
          _currentUser?.email ?? '',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  /// 프로필 정보 카드
  Widget _buildProfileInfoCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '계정 정보',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            
            const SizedBox(height: 16.0),
            
            _buildInfoRow(
              theme,
              icon: Icons.email_outlined,
              label: '이메일',
              value: _currentUser?.email ?? '없음',
            ),
            
            const SizedBox(height: 12.0),
            
            _buildInfoRow(
              theme,
              icon: Icons.verified_user_outlined,
              label: '이메일 인증',
              value: _currentUser?.emailVerified == true ? '인증됨' : '미인증',
              valueColor: _currentUser?.emailVerified == true 
                  ? Colors.green 
                  : Colors.orange,
            ),
            
            const SizedBox(height: 12.0),
            
            _buildInfoRow(
              theme,
              icon: Icons.calendar_today_outlined,
              label: '가입일',
              value: _currentUser?.metadata.creationTime != null
                  ? '${_currentUser!.metadata.creationTime!.year}.${_currentUser!.metadata.creationTime!.month.toString().padLeft(2, '0')}.${_currentUser!.metadata.creationTime!.day.toString().padLeft(2, '0')}'
                  : '알 수 없음',
            ),
          ],
        ),
      ),
    );
  }

  /// 정보 행 위젯
  Widget _buildInfoRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20.0,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 계정 설정 섹션
  Widget _buildAccountSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '계정 설정',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
        
        const SizedBox(height: 16.0),
        
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.edit_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('프로필 편집'),
                subtitle: const Text('프로필 정보를 수정합니다'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('프로필 편집 기능은 준비 중입니다'),
                    ),
                  );
                },
              ),
              
              Divider(height: 1.0, color: theme.colorScheme.outline),
              
              ListTile(
                leading: Icon(
                  Icons.security_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('비밀번호 변경'),
                subtitle: const Text('계정 비밀번호를 변경합니다'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('비밀번호 변경 기능은 준비 중입니다'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 로그아웃 버튼 (가장 아래)
  Widget _buildLogoutButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleLogout,
        icon: _isLoading
            ? SizedBox(
                width: 16.0,
                height: 16.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              )
            : const Icon(Icons.logout),
        label: Text(
          _isLoading ? '로그아웃 중...' : '로그아웃',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.error,
          side: BorderSide(color: theme.colorScheme.error),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }
}
