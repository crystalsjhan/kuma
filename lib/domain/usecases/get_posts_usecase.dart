import 'package:plant_community_app/core/errors/failures.dart';
import 'package:plant_community_app/domain/entities/post.dart';
import 'package:plant_community_app/domain/repositories/post_repository.dart';

/// 게시물 목록 조회 UseCase
/// 
/// Clean Architecture에서 UseCase는 특정 비즈니스 로직을 수행하는 클래스입니다.
/// 이 클래스는 게시물 목록을 조회하는 비즈니스 로직을 담당합니다.
class GetPostsUseCase {
  const GetPostsUseCase(this._repository);

  final PostRepository _repository;

  /// 모든 게시물 목록을 조회합니다.
  /// 
  /// 비즈니스 규칙:
  /// - 게시물은 최신순으로 정렬됩니다.
  /// - 삭제되지 않은 게시물만 조회됩니다.
  /// 
  /// Returns:
  /// - Success<List<Post>>: 성공 시 게시물 목록
  /// - Error<List<Post>>: 실패 시 에러 정보
  Future<Result<List<Post>>> call() async {
    try {
      final result = await _repository.getPosts();
      
      return result.fold(
        (failure) => Error<List<Post>>(failure),
        (posts) {
          // 비즈니스 로직: 최신순 정렬
          final sortedPosts = _sortPostsByCreatedDate(posts);
          return Success<List<Post>>(sortedPosts);
        },
      );
    } catch (e) {
      return const Error<List<Post>>(
        UnknownFailure('게시물을 불러오는 중 알 수 없는 오류가 발생했습니다.'),
      );
    }
  }

  /// 게시물을 생성일 기준 내림차순으로 정렬합니다.
  List<Post> _sortPostsByCreatedDate(List<Post> posts) {
    final sortedPosts = List<Post>.from(posts);
    sortedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedPosts;
  }
}

/// 게시물 타입별 조회 UseCase
class GetPostsByTypeUseCase {
  const GetPostsByTypeUseCase(this._repository);

  final PostRepository _repository;

  /// 특정 타입의 게시물 목록을 조회합니다.
  /// 
  /// Parameters:
  /// - [type]: 조회할 게시물 타입
  /// 
  /// Returns:
  /// - Success<List<Post>>: 성공 시 필터링된 게시물 목록
  /// - Error<List<Post>>: 실패 시 에러 정보
  Future<Result<List<Post>>> call(PostType type) async {
    try {
      final result = await _repository.getPostsByType(type);
      
      return result.fold(
        (failure) => Error<List<Post>>(failure),
        (posts) {
          final sortedPosts = _sortPostsByCreatedDate(posts);
          return Success<List<Post>>(sortedPosts);
        },
      );
    } catch (e) {
      return Error<List<Post>>(
        UnknownFailure('${type.displayName} 게시물을 불러오는 중 오류가 발생했습니다.'),
      );
    }
  }

  List<Post> _sortPostsByCreatedDate(List<Post> posts) {
    final sortedPosts = List<Post>.from(posts);
    sortedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedPosts;
  }
}

/// 게시물 검색 UseCase
class SearchPostsUseCase {
  const SearchPostsUseCase(this._repository);

  final PostRepository _repository;

  /// 키워드로 게시물을 검색합니다.
  /// 
  /// 비즈니스 규칙:
  /// - 검색어는 최소 2자 이상이어야 합니다.
  /// - 제목과 내용에서 키워드를 검색합니다.
  /// - 검색 결과는 관련도 순으로 정렬됩니다.
  /// 
  /// Parameters:
  /// - [query]: 검색할 키워드
  /// 
  /// Returns:
  /// - Success<List<Post>>: 성공 시 검색된 게시물 목록
  /// - Error<List<Post>>: 실패 시 에러 정보
  Future<Result<List<Post>>> call(String query) async {
    // 비즈니스 규칙 검증
    if (query.trim().length < 2) {
      return const Error<List<Post>>(
        ValidationFailure('검색어는 최소 2자 이상 입력해주세요.'),
      );
    }

    try {
      final result = await _repository.searchPosts(query.trim());
      
      return result.fold(
        (failure) => Error<List<Post>>(failure),
        (posts) {
          // 비즈니스 로직: 관련도 및 최신순 정렬
          final sortedPosts = _sortPostsByRelevanceAndDate(posts, query);
          return Success<List<Post>>(sortedPosts);
        },
      );
    } catch (e) {
      return const Error<List<Post>>(
        UnknownFailure('검색 중 알 수 없는 오류가 발생했습니다.'),
      );
    }
  }

  /// 검색 관련도와 날짜를 기준으로 게시물을 정렬합니다.
  List<Post> _sortPostsByRelevanceAndDate(List<Post> posts, String query) {
    final sortedPosts = List<Post>.from(posts);
    
    sortedPosts.sort((a, b) {
      // 제목에 검색어가 포함된 게시물을 우선 정렬
      final aHasInTitle = a.title.toLowerCase().contains(query.toLowerCase());
      final bHasInTitle = b.title.toLowerCase().contains(query.toLowerCase());
      
      if (aHasInTitle && !bHasInTitle) return -1;
      if (!aHasInTitle && bHasInTitle) return 1;
      
      // 같은 관련도라면 최신순으로 정렬
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return sortedPosts;
  }
}

/// 페이지네이션 게시물 조회 UseCase
class GetPostsPaginatedUseCase {
  const GetPostsPaginatedUseCase(this._repository);

  final PostRepository _repository;

  /// 페이지네이션을 통해 게시물을 조회합니다.
  /// 
  /// 비즈니스 규칙:
  /// - 페이지는 0부터 시작합니다.
  /// - 페이지당 최대 50개의 게시물만 조회할 수 있습니다.
  /// 
  /// Parameters:
  /// - [page]: 페이지 번호 (0부터 시작)
  /// - [limit]: 페이지당 게시물 수 (최대 50)
  /// 
  /// Returns:
  /// - Success<List<Post>>: 성공 시 페이지별 게시물 목록
  /// - Error<List<Post>>: 실패 시 에러 정보
  Future<Result<List<Post>>> call({
    required int page,
    required int limit,
  }) async {
    // 비즈니스 규칙 검증
    if (page < 0) {
      return const Error<List<Post>>(
        ValidationFailure('페이지 번호는 0 이상이어야 합니다.'),
      );
    }

    if (limit <= 0 || limit > 50) {
      return const Error<List<Post>>(
        ValidationFailure('페이지당 게시물 수는 1개 이상 50개 이하여야 합니다.'),
      );
    }

    try {
      final result = await _repository.getPostsPaginated(
        page: page,
        limit: limit,
      );
      
      return result.fold(
        (failure) => Error<List<Post>>(failure),
        (posts) => Success<List<Post>>(posts),
      );
    } catch (e) {
      return const Error<List<Post>>(
        UnknownFailure('게시물을 불러오는 중 알 수 없는 오류가 발생했습니다.'),
      );
    }
  }
}

