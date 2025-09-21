import 'package:plant_community_app/core/errors/failures.dart';
import 'package:plant_community_app/domain/entities/post.dart';

/// Post 리포지토리 인터페이스
/// 데이터 레이어와의 계약을 정의합니다.
/// Clean Architecture에서 도메인 레이어는 데이터 레이어에 의존하지 않고
/// 추상화된 인터페이스를 통해 데이터에 접근합니다.
abstract class PostRepository {
  /// 모든 게시물 목록 조회
  /// 
  /// Returns:
  /// - Success<List<Post>>: 성공 시 게시물 목록
  /// - Error<List<Post>>: 실패 시 Failure 정보
  Future<Result<List<Post>>> getPosts();

  /// 특정 게시물 조회
  /// 
  /// Parameters:
  /// - [id]: 조회할 게시물의 고유 ID
  /// 
  /// Returns:
  /// - Success<Post>: 성공 시 게시물 정보
  /// - Error<Post>: 실패 시 Failure 정보
  Future<Result<Post>> getPostById(String id);

  /// 게시물 타입별 필터링 조회
  /// 
  /// Parameters:
  /// - [type]: 조회할 게시물 타입 (question, diary)
  /// 
  /// Returns:
  /// - Success<List<Post>>: 성공 시 필터링된 게시물 목록
  /// - Error<List<Post>>: 실패 시 Failure 정보
  Future<Result<List<Post>>> getPostsByType(PostType type);

  /// 게시물 검색
  /// 
  /// Parameters:
  /// - [query]: 검색할 키워드
  /// 
  /// Returns:
  /// - Success<List<Post>>: 성공 시 검색된 게시물 목록
  /// - Error<List<Post>>: 실패 시 Failure 정보
  Future<Result<List<Post>>> searchPosts(String query);

  /// 페이지네이션을 통한 게시물 조회
  /// 
  /// Parameters:
  /// - [page]: 페이지 번호 (0부터 시작)
  /// - [limit]: 페이지당 게시물 수
  /// 
  /// Returns:
  /// - Success<List<Post>>: 성공 시 페이지별 게시물 목록
  /// - Error<List<Post>>: 실패 시 Failure 정보
  Future<Result<List<Post>>> getPostsPaginated({
    required int page,
    required int limit,
  });

  /// 게시물 생성 (추후 구현 예정)
  /// 
  /// Parameters:
  /// - [post]: 생성할 게시물 정보
  /// 
  /// Returns:
  /// - Success<Post>: 성공 시 생성된 게시물 정보
  /// - Error<Post>: 실패 시 Failure 정보
  Future<Result<Post>> createPost(Post post);

  /// 게시물 업데이트 (추후 구현 예정)
  /// 
  /// Parameters:
  /// - [post]: 업데이트할 게시물 정보
  /// 
  /// Returns:
  /// - Success<Post>: 성공 시 업데이트된 게시물 정보
  /// - Error<Post>: 실패 시 Failure 정보
  Future<Result<Post>> updatePost(Post post);

  /// 게시물 삭제 (추후 구현 예정)
  /// 
  /// Parameters:
  /// - [id]: 삭제할 게시물의 고유 ID
  /// 
  /// Returns:
  /// - Success<void>: 성공 시
  /// - Error<void>: 실패 시 Failure 정보
  Future<Result<void>> deletePost(String id);
}

