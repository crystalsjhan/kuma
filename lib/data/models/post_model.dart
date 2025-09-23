import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plant_community_app/domain/entities/post.dart';

part 'post_model.freezed.dart';
part 'post_model.g.dart';

/// Firestore posts 컬렉션의 게시물 데이터 모델
/// 
/// Firebase Firestore의 posts 컬렉션에서 게시물 정보를 관리하기 위한 데이터 모델입니다.
/// freezed와 json_serializable을 사용하여 불변 객체로 구현되었습니다.
@freezed
class PostModel with _$PostModel {
  const factory PostModel({
    /// 게시물 고유 식별자
    required String postId,
    
    /// 작성자 사용자 ID
    required String authorUid,
    
    /// 게시물 제목
    required String title,
    
    /// 게시물 내용
    required String content,
    
    /// 첨부 이미지 URL 목록 (선택사항)
    List<String>? imageURLs,
    
    /// 게시물 생성 시간 (DateTime)
    required DateTime createdAt,
    
    /// 게시물 수정 시간 (선택사항)
    DateTime? updatedAt,
    
    /// 좋아요 수 (기본값: 0)
    @Default(0) int likeCount,
    
    /// 댓글 수 (기본값: 0)
    @Default(0) int commentCount,
    
    /// 게시물 타입 (기본값: 'post')
    @Default('post') String type,
  }) = _PostModel;

  /// Firestore 문서에서 PostModel로 변환
  factory PostModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return PostModel(
      postId: doc.id, // Firestore 문서 ID 사용
      authorUid: data['authorUid'] as String,
      title: data['title'] as String,
      content: data['content'] as String,
      imageURLs: (data['imageURLs'] as List<dynamic>?)?.cast<String>(),
      createdAt: _timestampFromJson(data['createdAt']),
      updatedAt: data['updatedAt'] != null ? _timestampFromJson(data['updatedAt']) : null,
      likeCount: data['likeCount'] as int? ?? 0,
      commentCount: data['commentCount'] as int? ?? 0,
      type: data['type'] as String? ?? 'post',
    );
  }

  /// JSON에서 PostModel로 변환
  factory PostModel.fromJson(Map<String, dynamic> json) => _$PostModelFromJson(json);

  /// Post 엔티티에서 PostModel로 변환 (기존 코드 호환성)
  factory PostModel.fromEntity(dynamic post) {
    // Post 엔티티의 속성을 PostModel로 변환
    return PostModel(
      postId: post.id ?? '',
      authorUid: post.authorUid ?? '',
      title: post.title ?? '',
      content: post.content ?? '',
      imageURLs: post.imageUrl != null ? [post.imageUrl] : null,
      createdAt: post.createdAt is String 
          ? DateTime.parse(post.createdAt) 
          : (post.createdAt ?? DateTime.now()),
      updatedAt: null,
      likeCount: post.likeCount ?? 0,
      commentCount: post.commentCount ?? 0,
      type: post.type ?? 'post',
    );
  }
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

/// PostModel 확장 메서드
extension PostModelExtension on PostModel {
  /// Firestore 문서 데이터로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'authorUid': authorUid,
      'title': title,
      'content': content,
      'imageURLs': imageURLs,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'type': type,
    };
  }

  /// 이미지가 있는지 확인
  bool get hasImages => imageURLs != null && imageURLs!.isNotEmpty;

  /// 이미지 개수
  int get imageCount => imageURLs?.length ?? 0;

  /// 게시물이 수정되었는지 확인
  bool get isEdited => updatedAt != null;

  /// 게시물 생성 후 경과 시간 (예: "3일 전")
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

  /// 게시물 수정 후 경과 시간 (예: "3일 전")
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

  /// 좋아요가 많은지 확인 (임계값: 10)
  bool get isPopular => likeCount >= 10;

  /// 댓글이 많은지 확인 (임계값: 5)
  bool get hasManyComments => commentCount >= 5;

  /// 게시물 요약 (내용의 처음 100자)
  String get summary {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }

  /// PostModel을 Post 엔티티로 변환 (기존 코드 호환성)
  Post toEntity() {
    // Post 엔티티를 직접 생성하여 반환
    return Post(
      id: postId,
      title: title,
      content: content,
      authorName: '사용자 ${authorUid.substring(0, 8)}...',
      authorUid: authorUid,
      createdAt: createdAt,
      type: PostType.fromString(type),
      imageUrl: imageURLs?.isNotEmpty == true ? imageURLs!.first : null,
      likeCount: likeCount,
      commentCount: commentCount,
    );
  }

  /// id getter (기존 코드 호환성)
  String get id => postId;
}

/// PostModel 생성 헬퍼 클래스
class PostModelBuilder {
  /// 새 게시물 생성
  static PostModel createNew({
    required String postId,
    required String authorUid,
    required String title,
    required String content,
    List<String>? imageURLs,
  }) {
    return PostModel(
      postId: postId,
      authorUid: authorUid,
      title: title,
      content: content,
      imageURLs: imageURLs,
      createdAt: DateTime.now(),
      likeCount: 0,
      commentCount: 0,
    );
  }

  /// 게시물 수정
  static PostModel updatePost({
    required PostModel originalPost,
    String? title,
    String? content,
    List<String>? imageURLs,
  }) {
    return originalPost.copyWith(
      title: title ?? originalPost.title,
      content: content ?? originalPost.content,
      imageURLs: imageURLs,
      updatedAt: DateTime.now(),
    );
  }

  /// 좋아요 수 증가
  static PostModel incrementLike(PostModel post) {
    return post.copyWith(likeCount: post.likeCount + 1);
  }

  /// 좋아요 수 감소
  static PostModel decrementLike(PostModel post) {
    return post.copyWith(likeCount: (post.likeCount - 1).clamp(0, double.infinity).toInt());
  }

  /// 댓글 수 증가
  static PostModel incrementComment(PostModel post) {
    return post.copyWith(commentCount: post.commentCount + 1);
  }

  /// 댓글 수 감소
  static PostModel decrementComment(PostModel post) {
    return post.copyWith(commentCount: (post.commentCount - 1).clamp(0, double.infinity).toInt());
  }
}