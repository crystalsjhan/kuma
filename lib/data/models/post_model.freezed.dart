// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PostModel _$PostModelFromJson(Map<String, dynamic> json) {
  return _PostModel.fromJson(json);
}

/// @nodoc
mixin _$PostModel {
  /// 게시물 고유 식별자
  String get postId => throw _privateConstructorUsedError;

  /// 작성자 사용자 ID
  String get authorUid => throw _privateConstructorUsedError;

  /// 게시물 제목
  String get title => throw _privateConstructorUsedError;

  /// 게시물 내용
  String get content => throw _privateConstructorUsedError;

  /// 첨부 이미지 URL 목록 (선택사항)
  List<String>? get imageURLs => throw _privateConstructorUsedError;

  /// 게시물 생성 시간 (DateTime)
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// 게시물 수정 시간 (선택사항)
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// 좋아요 수 (기본값: 0)
  int get likeCount => throw _privateConstructorUsedError;

  /// 댓글 수 (기본값: 0)
  int get commentCount => throw _privateConstructorUsedError;

  /// 게시물 타입 (기본값: 'post')
  String get type => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PostModelCopyWith<PostModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostModelCopyWith<$Res> {
  factory $PostModelCopyWith(PostModel value, $Res Function(PostModel) then) =
      _$PostModelCopyWithImpl<$Res, PostModel>;
  @useResult
  $Res call(
      {String postId,
      String authorUid,
      String title,
      String content,
      List<String>? imageURLs,
      DateTime createdAt,
      DateTime? updatedAt,
      int likeCount,
      int commentCount,
      String type});
}

/// @nodoc
class _$PostModelCopyWithImpl<$Res, $Val extends PostModel>
    implements $PostModelCopyWith<$Res> {
  _$PostModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postId = null,
    Object? authorUid = null,
    Object? title = null,
    Object? content = null,
    Object? imageURLs = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? likeCount = null,
    Object? commentCount = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      postId: null == postId
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String,
      authorUid: null == authorUid
          ? _value.authorUid
          : authorUid // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      imageURLs: freezed == imageURLs
          ? _value.imageURLs
          : imageURLs // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PostModelImplCopyWith<$Res>
    implements $PostModelCopyWith<$Res> {
  factory _$$PostModelImplCopyWith(
          _$PostModelImpl value, $Res Function(_$PostModelImpl) then) =
      __$$PostModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String postId,
      String authorUid,
      String title,
      String content,
      List<String>? imageURLs,
      DateTime createdAt,
      DateTime? updatedAt,
      int likeCount,
      int commentCount,
      String type});
}

/// @nodoc
class __$$PostModelImplCopyWithImpl<$Res>
    extends _$PostModelCopyWithImpl<$Res, _$PostModelImpl>
    implements _$$PostModelImplCopyWith<$Res> {
  __$$PostModelImplCopyWithImpl(
      _$PostModelImpl _value, $Res Function(_$PostModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postId = null,
    Object? authorUid = null,
    Object? title = null,
    Object? content = null,
    Object? imageURLs = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? likeCount = null,
    Object? commentCount = null,
    Object? type = null,
  }) {
    return _then(_$PostModelImpl(
      postId: null == postId
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String,
      authorUid: null == authorUid
          ? _value.authorUid
          : authorUid // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      imageURLs: freezed == imageURLs
          ? _value._imageURLs
          : imageURLs // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostModelImpl implements _PostModel {
  const _$PostModelImpl(
      {required this.postId,
      required this.authorUid,
      required this.title,
      required this.content,
      final List<String>? imageURLs,
      required this.createdAt,
      this.updatedAt,
      this.likeCount = 0,
      this.commentCount = 0,
      this.type = 'post'})
      : _imageURLs = imageURLs;

  factory _$PostModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostModelImplFromJson(json);

  /// 게시물 고유 식별자
  @override
  final String postId;

  /// 작성자 사용자 ID
  @override
  final String authorUid;

  /// 게시물 제목
  @override
  final String title;

  /// 게시물 내용
  @override
  final String content;

  /// 첨부 이미지 URL 목록 (선택사항)
  final List<String>? _imageURLs;

  /// 첨부 이미지 URL 목록 (선택사항)
  @override
  List<String>? get imageURLs {
    final value = _imageURLs;
    if (value == null) return null;
    if (_imageURLs is EqualUnmodifiableListView) return _imageURLs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// 게시물 생성 시간 (DateTime)
  @override
  final DateTime createdAt;

  /// 게시물 수정 시간 (선택사항)
  @override
  final DateTime? updatedAt;

  /// 좋아요 수 (기본값: 0)
  @override
  @JsonKey()
  final int likeCount;

  /// 댓글 수 (기본값: 0)
  @override
  @JsonKey()
  final int commentCount;

  /// 게시물 타입 (기본값: 'post')
  @override
  @JsonKey()
  final String type;

  @override
  String toString() {
    return 'PostModel(postId: $postId, authorUid: $authorUid, title: $title, content: $content, imageURLs: $imageURLs, createdAt: $createdAt, updatedAt: $updatedAt, likeCount: $likeCount, commentCount: $commentCount, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostModelImpl &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.authorUid, authorUid) ||
                other.authorUid == authorUid) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality()
                .equals(other._imageURLs, _imageURLs) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      postId,
      authorUid,
      title,
      content,
      const DeepCollectionEquality().hash(_imageURLs),
      createdAt,
      updatedAt,
      likeCount,
      commentCount,
      type);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PostModelImplCopyWith<_$PostModelImpl> get copyWith =>
      __$$PostModelImplCopyWithImpl<_$PostModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostModelImplToJson(
      this,
    );
  }
}

abstract class _PostModel implements PostModel {
  const factory _PostModel(
      {required final String postId,
      required final String authorUid,
      required final String title,
      required final String content,
      final List<String>? imageURLs,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final int likeCount,
      final int commentCount,
      final String type}) = _$PostModelImpl;

  factory _PostModel.fromJson(Map<String, dynamic> json) =
      _$PostModelImpl.fromJson;

  @override

  /// 게시물 고유 식별자
  String get postId;
  @override

  /// 작성자 사용자 ID
  String get authorUid;
  @override

  /// 게시물 제목
  String get title;
  @override

  /// 게시물 내용
  String get content;
  @override

  /// 첨부 이미지 URL 목록 (선택사항)
  List<String>? get imageURLs;
  @override

  /// 게시물 생성 시간 (DateTime)
  DateTime get createdAt;
  @override

  /// 게시물 수정 시간 (선택사항)
  DateTime? get updatedAt;
  @override

  /// 좋아요 수 (기본값: 0)
  int get likeCount;
  @override

  /// 댓글 수 (기본값: 0)
  int get commentCount;
  @override

  /// 게시물 타입 (기본값: 'post')
  String get type;
  @override
  @JsonKey(ignore: true)
  _$$PostModelImplCopyWith<_$PostModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
