import 'package:json_annotation/json_annotation.dart';
import 'package:plant_community_app/domain/entities/post.dart';

part 'post_model.g.dart';

/// Post 데이터 모델
/// 
/// JSON 직렬화/역직렬화를 지원하며, 도메인 엔티티와 변환 기능을 제공합니다.
/// 서버나 로컬 데이터베이스와의 데이터 교환에 사용됩니다.
@JsonSerializable()
class PostModel {
  const PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.createdAt,
    required this.type,
    this.imageUrl,
    this.likeCount = 0,
    this.commentCount = 0,
  });

  /// JSON으로부터 PostModel 생성
  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  /// 도메인 엔티티로부터 PostModel 생성
  factory PostModel.fromEntity(Post post) {
    return PostModel(
      id: post.id,
      title: post.title,
      content: post.content,
      authorName: post.authorName,
      createdAt: post.createdAt.toIso8601String(),
      type: post.type.value,
      imageUrl: post.imageUrl,
      likeCount: post.likeCount,
      commentCount: post.commentCount,
    );
  }

  /// 게시물 고유 ID
  final String id;

  /// 게시물 제목
  final String title;

  /// 게시물 내용
  final String content;

  /// 작성자 이름
  @JsonKey(name: 'author_name')
  final String authorName;

  /// 작성일시 (ISO 8601 문자열)
  @JsonKey(name: 'created_at')
  final String createdAt;

  /// 게시물 타입 ('question' 또는 'diary')
  final String type;

  /// 첨부 이미지 URL (선택사항)
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  /// 좋아요 수
  @JsonKey(name: 'like_count')
  final int likeCount;

  /// 댓글 수
  @JsonKey(name: 'comment_count')
  final int commentCount;

  /// PostModel을 JSON으로 변환
  Map<String, dynamic> toJson() => _$PostModelToJson(this);

  /// PostModel을 도메인 엔티티로 변환
  Post toEntity() {
    return Post(
      id: id,
      title: title,
      content: content,
      authorName: authorName,
      createdAt: DateTime.parse(createdAt),
      type: PostType.fromString(type),
      imageUrl: imageUrl,
      likeCount: likeCount,
      commentCount: commentCount,
    );
  }

  /// copyWith 메서드
  PostModel copyWith({
    String? id,
    String? title,
    String? content,
    String? authorName,
    String? createdAt,
    String? type,
    String? imageUrl,
    int? likeCount,
    int? commentCount,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
    );
  }

  @override
  String toString() {
    return 'PostModel(id: $id, title: $title, type: $type, authorName: $authorName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostModel &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.authorName == authorName &&
        other.createdAt == createdAt &&
        other.type == type &&
        other.imageUrl == imageUrl &&
        other.likeCount == likeCount &&
        other.commentCount == commentCount;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      content,
      authorName,
      createdAt,
      type,
      imageUrl,
      likeCount,
      commentCount,
    );
  }
}

