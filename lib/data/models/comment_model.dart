import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_model.freezed.dart';
part 'comment_model.g.dart';

/// Firestore posts/{postId}/comments 서브컬렉션의 댓글 데이터 모델
/// 
/// Firebase Firestore의 posts/{postId}/comments 서브컬렉션에서 댓글 정보를 관리하기 위한 데이터 모델입니다.
/// freezed와 json_serializable을 사용하여 불변 객체로 구현되었습니다.
@freezed
class CommentModel with _$CommentModel {
  const factory CommentModel({
    /// 댓글 고유 식별자
    required String commentId,
    
    /// 댓글이 속한 게시물 ID
    required String postId,
    
    /// 댓글 작성자 UID
    required String authorUid,
    
    /// 댓글 내용
    required String content,
    
    /// 댓글 생성 시간 (DateTime)
    required DateTime createdAt,
    
    /// 댓글 수정 시간 (선택사항)
    DateTime? updatedAt,
  }) = _CommentModel;

  /// Firestore 문서에서 CommentModel로 변환
  factory CommentModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Document data is null');
    }
    
    return CommentModel(
      commentId: doc.id, // Firestore 문서 ID 사용
      postId: data['postId'] as String? ?? '',
      authorUid: data['authorUid'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: _timestampFromJson(data['createdAt']),
      updatedAt: data['updatedAt'] != null ? _timestampFromJson(data['updatedAt']) : null,
    );
  }

  /// JSON에서 CommentModel로 변환
  factory CommentModel.fromJson(Map<String, dynamic> json) => _$CommentModelFromJson(json);
}

/// Timestamp를 DateTime으로 변환하는 헬퍼 함수
DateTime _timestampFromJson(dynamic timestamp) {
  try {
    if (timestamp == null) {
      return DateTime.now();
    } else if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is Map<String, dynamic>) {
      // Firestore Timestamp JSON 형태
      final seconds = timestamp['_seconds'] as int? ?? 0;
      final nanoseconds = timestamp['_nanoseconds'] as int? ?? 0;
      return DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + (nanoseconds / 1000000).round(),
      );
    } else if (timestamp is int) {
      // Unix timestamp (seconds)
      return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    } else if (timestamp is String) {
      // ISO 8601 문자열
      return DateTime.parse(timestamp);
    } else {
      print('알 수 없는 timestamp 형식: $timestamp');
      return DateTime.now();
    }
  } catch (e) {
    print('timestamp 변환 에러: $e, timestamp: $timestamp');
    return DateTime.now();
  }
}

/// CommentModel 확장 메서드
extension CommentModelExtension on CommentModel {
  /// Firestore 문서 데이터로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'authorUid': authorUid,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// 댓글이 수정되었는지 확인
  bool get isEdited => updatedAt != null;

  /// 댓글 생성 후 경과 시간 (예: "3일 전")
  String get timeSinceCreated {
    final now = DateTime.now();
    final created = createdAt;
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

  /// 댓글 수정 후 경과 시간 (예: "3일 전")
  String get timeSinceUpdated {
    if (updatedAt == null) return '';
    
    final now = DateTime.now();
    final updated = updatedAt!;
    final difference = now.difference(updated);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전 수정';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전 수정';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전 수정';
    } else {
      return '방금 전 수정';
    }
  }

  /// 댓글 요약 (내용의 처음 50자)
  String get summary {
    if (content.length <= 50) return content;
    return '${content.substring(0, 50)}...';
  }

  /// 댓글이 긴지 확인 (100자 이상)
  bool get isLongComment => content.length >= 100;

  /// 댓글이 비어있는지 확인
  bool get isEmpty => content.trim().isEmpty;

  /// 댓글 길이
  int get length => content.length;
}

/// CommentModel 생성 헬퍼 클래스
class CommentModelBuilder {
  /// 새 댓글 생성
  static CommentModel createNew({
    required String commentId,
    required String postId,
    required String authorUid,
    required String content,
  }) {
    return CommentModel(
      commentId: commentId,
      postId: postId,
      authorUid: authorUid,
      content: content,
      createdAt: DateTime.now(),
    );
  }

  /// 댓글 수정
  static CommentModel updateComment({
    required CommentModel originalComment,
    required String content,
  }) {
    return originalComment.copyWith(
      content: content,
      updatedAt: DateTime.now(),
    );
  }

  /// 댓글 내용 검증
  static bool isValidContent(String content) {
    final trimmedContent = content.trim();
    return trimmedContent.isNotEmpty && trimmedContent.length <= 1000;
  }

  /// 댓글 내용 정리 (앞뒤 공백 제거, 연속 공백 정리)
  static String cleanContent(String content) {
    return content.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}

