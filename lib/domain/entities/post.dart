import 'package:equatable/equatable.dart';

/// 게시물 도메인 엔티티
/// 비즈니스 로직의 핵심이 되는 Post 엔티티를 정의합니다.
class Post extends Equatable {
  const Post({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.authorUid,
    required this.createdAt,
    required this.type,
    this.imageUrl,
    this.likeCount = 0,
    this.commentCount = 0,
  });

  /// 게시물 고유 ID
  final String id;

  /// 게시물 제목
  final String title;

  /// 게시물 내용
  final String content;

  /// 작성자 이름
  final String authorName;

  /// 작성자 UID
  final String authorUid;

  /// 작성일시
  final DateTime createdAt;

  /// 게시물 타입 (question: 질문, diary: 일기)
  final PostType type;

  /// 첨부 이미지 URL (선택사항)
  final String? imageUrl;

  /// 좋아요 수
  final int likeCount;

  /// 댓글 수
  final int commentCount;

  /// 게시물 내용 미리보기 생성 (150자 제한)
  String get contentPreview {
    const maxLength = 150;
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }

  /// 이미지가 있는지 확인
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  /// copyWith 메서드로 불변 객체 업데이트
  Post copyWith({
    String? id,
    String? title,
    String? content,
    String? authorName,
    String? authorUid,
    DateTime? createdAt,
    PostType? type,
    String? imageUrl,
    int? likeCount,
    int? commentCount,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      authorUid: authorUid ?? this.authorUid,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        authorName,
        authorUid,
        createdAt,
        type,
        imageUrl,
        likeCount,
        commentCount,
      ];

  @override
  String toString() {
    return 'Post(id: $id, title: $title, type: $type, authorName: $authorName)';
  }
}

/// 게시물 타입 열거형
enum PostType {
  /// 질문 게시물
  question('question', '질문'),
  
  /// 일기 게시물
  diary('diary', '일기');

  const PostType(this.value, this.displayName);

  /// 서버/DB에 저장되는 값
  final String value;
  
  /// UI에 표시되는 이름
  final String displayName;

  /// 문자열로부터 PostType 생성
  static PostType fromString(String value) {
    return PostType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PostType.diary,
    );
  }

  @override
  String toString() => value;
}

