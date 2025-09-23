import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Firestore users 컬렉션의 사용자 데이터 모델
/// 
/// Firebase Authentication과 Firestore의 users 컬렉션에서 
/// 사용자 정보를 관리하기 위한 데이터 모델입니다.
/// freezed와 json_serializable을 사용하여 불변 객체로 구현되었습니다.
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    /// 사용자 고유 식별자 (Firebase Auth UID)
    required String uid,
    
    /// 사용자 이메일 주소
    required String email,
    
    /// 사용자 표시 이름 (선택사항)
    String? displayName,
    
    /// 사용자 프로필 사진 URL (선택사항)
    String? photoURL,
    
    /// 계정 생성 시간 (DateTime)
    required DateTime createdAt,
  }) = _UserModel;

  /// Firestore 문서에서 UserModel로 변환
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: data['uid'] as String,
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
      photoURL: data['photoURL'] as String?,
      createdAt: _timestampFromJson(data['createdAt']),
    );
  }

  /// JSON에서 UserModel로 변환
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}

/// Timestamp를 DateTime으로 변환하는 헬퍼 함수
DateTime _timestampFromJson(dynamic timestamp) {
  if (timestamp is Timestamp) {
    return timestamp.toDate();
  } else if (timestamp is Map<String, dynamic>) {
    // Firestore Timestamp JSON 형태
    return DateTime.fromMillisecondsSinceEpoch(
      (timestamp['_seconds'] as int) * 1000 + 
      ((timestamp['_nanoseconds'] as int) / 1000000).round(),
    );
  } else if (timestamp is int) {
    // Unix timestamp (seconds)
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  } else if (timestamp is String) {
    // ISO 8601 문자열
    return DateTime.parse(timestamp);
  } else {
    throw ArgumentError('Invalid timestamp format: $timestamp');
  }
}


/// UserModel 확장 메서드
extension UserModelExtension on UserModel {
  /// Firestore 문서 데이터로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// 사용자 표시 이름 또는 이메일 반환
  String get displayNameOrEmail => displayName ?? email;

  /// 프로필 사진이 있는지 확인
  bool get hasProfilePhoto => photoURL != null && photoURL!.isNotEmpty;

  /// 계정 생성일을 DateTime으로 변환 (이미 DateTime이므로 그대로 반환)
  DateTime get createdAtDateTime => createdAt;

  /// 계정 생성 후 경과 시간 (예: "3일 전")
  String get timeSinceCreated {
    final now = DateTime.now();
    final created = createdAtDateTime;
    final difference = now.difference(created);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}

/// UserModel 생성 헬퍼 클래스
class UserModelBuilder {
  /// Firebase Auth User에서 UserModel 생성
  static UserModel fromFirebaseUser(
    String uid,
    String email, {
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// 기본 UserModel 생성 (회원가입 시)
  static UserModel createNew({
    required String uid,
    required String email,
    String? displayName,
    String? photoURL,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      createdAt: DateTime.now(),
    );
  }
}
