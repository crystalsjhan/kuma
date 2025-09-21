import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase Auth 관련 Provider들
/// 
/// 앱 전체에서 인증 상태를 관리하기 위한 Riverpod Provider들을 정의합니다.
/// StreamProvider를 사용하여 실시간 인증 상태 변경을 감지합니다.

/// FirebaseAuth 인스턴스를 제공하는 기본 Provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// 사용자의 인증 상태 변경 스트림을 제공하는 StreamProvider
/// 
/// 이 Provider는 Firebase Auth의 authStateChanges() 스트림을 구독하여
/// 사용자의 로그인/로그아웃 상태 변경을 실시간으로 감지합니다.
/// 
/// 반환값:
/// - User? 객체: 로그인된 사용자 정보 (로그인 상태)
/// - null: 로그인되지 않은 상태
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return firebaseAuth.authStateChanges();
});

/// 현재 로그인된 사용자 정보를 제공하는 Provider
/// 
/// authStateChangesProvider의 현재 값을 기반으로
/// 로그인된 사용자 정보를 제공합니다.
final currentUserProvider = Provider<User?>((ref) {
  final authStateAsync = ref.watch(authStateChangesProvider);
  return authStateAsync.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// 사용자의 로그인 상태를 boolean으로 제공하는 Provider
/// 
/// true: 로그인됨
/// false: 로그인되지 않음
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});
