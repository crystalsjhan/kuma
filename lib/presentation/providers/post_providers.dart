import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_community_app/core/errors/failures.dart';
import 'package:plant_community_app/data/repositories/post_repository_impl.dart';
import 'package:plant_community_app/domain/entities/post.dart';
import 'package:plant_community_app/domain/repositories/post_repository.dart';
import 'package:plant_community_app/domain/usecases/get_posts_usecase.dart';

// Repository Provider
/// Post Repository 의존성 주입
/// 추후 Firebase나 다른 데이터 소스로 교체할 때 이 부분만 수정하면 됩니다.
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl();
});

// UseCase Providers
/// 게시물 목록 조회 UseCase Provider
final getPostsUseCaseProvider = Provider<GetPostsUseCase>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return GetPostsUseCase(repository);
});

/// 게시물 타입별 조회 UseCase Provider
final getPostsByTypeUseCaseProvider = Provider<GetPostsByTypeUseCase>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return GetPostsByTypeUseCase(repository);
});

/// 게시물 검색 UseCase Provider
final searchPostsUseCaseProvider = Provider<SearchPostsUseCase>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return SearchPostsUseCase(repository);
});

/// 페이지네이션 게시물 조회 UseCase Provider
final getPostsPaginatedUseCaseProvider = Provider<GetPostsPaginatedUseCase>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return GetPostsPaginatedUseCase(repository);
});

// State Providers
/// 전체 게시물 목록 상태 관리
/// AsyncValue를 사용하여 로딩, 에러, 성공 상태를 모두 처리합니다.
final postListProvider = FutureProvider<List<Post>>((ref) async {
  final useCase = ref.watch(getPostsUseCaseProvider);
  final result = await useCase();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (posts) => posts,
  );
});

/// 게시물 타입별 필터링 상태 관리
/// 현재 선택된 필터 타입을 추적합니다.
final selectedPostTypeProvider = StateProvider<PostType?>((ref) => null);

/// 필터링된 게시물 목록 Provider
/// selectedPostTypeProvider의 변경을 감지하여 자동으로 업데이트됩니다.
final filteredPostListProvider = FutureProvider<List<Post>>((ref) async {
  final selectedType = ref.watch(selectedPostTypeProvider);
  
  if (selectedType == null) {
    // 필터가 없으면 전체 게시물 반환
    final useCase = ref.watch(getPostsUseCaseProvider);
    final result = await useCase();
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (posts) => posts,
    );
  } else {
    // 선택된 타입의 게시물만 반환
    final useCase = ref.watch(getPostsByTypeUseCaseProvider);
    final result = await useCase(selectedType);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (posts) => posts,
    );
  }
});

/// 검색 키워드 상태 관리
final searchQueryProvider = StateProvider<String>((ref) => '');

/// 검색 결과 Provider
/// 검색 키워드가 변경될 때마다 자동으로 검색을 수행합니다.
final searchResultsProvider = FutureProvider<List<Post>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  
  if (query.trim().isEmpty) {
    return [];
  }
  
  final useCase = ref.watch(searchPostsUseCaseProvider);
  final result = await useCase(query);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (posts) => posts,
  );
});

/// 특정 게시물 상세 정보 Provider
/// 게시물 ID를 매개변수로 받아 해당 게시물 정보를 가져옵니다.
final postDetailProvider = FutureProvider.family<Post, String>((ref, postId) async {
  final repository = ref.watch(postRepositoryProvider);
  final result = await repository.getPostById(postId);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (post) => post,
  );
});

/// 페이지네이션 관련 상태 관리
/// 현재 페이지 번호를 추적합니다.
final currentPageProvider = StateProvider<int>((ref) => 0);

/// 페이지당 게시물 수 설정
final postsPerPageProvider = StateProvider<int>((ref) => 10);

/// 페이지네이션된 게시물 목록 Provider
final paginatedPostListProvider = FutureProvider<List<Post>>((ref) async {
  final page = ref.watch(currentPageProvider);
  final limit = ref.watch(postsPerPageProvider);
  final useCase = ref.watch(getPostsPaginatedUseCaseProvider);
  
  final result = await useCase(page: page, limit: limit);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (posts) => posts,
  );
});

/// 게시물 새로고침 Provider
/// 수동으로 게시물 목록을 새로고침할 때 사용합니다.
final postRefreshProvider = StateProvider<int>((ref) => 0);

/// 새로고침된 게시물 목록 Provider
/// postRefreshProvider의 값이 변경될 때마다 게시물 목록을 새로 가져옵니다.
final refreshedPostListProvider = FutureProvider<List<Post>>((ref) async {
  // refreshProvider의 변경을 감지하여 자동 새로고침
  ref.watch(postRefreshProvider);
  
  final useCase = ref.watch(getPostsUseCaseProvider);
  final result = await useCase();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (posts) => posts,
  );
});

/// 게시물 통계 Provider
/// 전체 게시물 수, 타입별 게시물 수 등의 통계 정보를 제공합니다.
final postStatsProvider = FutureProvider<PostStats>((ref) async {
  final useCase = ref.watch(getPostsUseCaseProvider);
  final result = await useCase();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (posts) {
      final questionCount = posts.where((p) => p.type == PostType.question).length;
      final diaryCount = posts.where((p) => p.type == PostType.diary).length;
      
      return PostStats(
        totalCount: posts.length,
        questionCount: questionCount,
        diaryCount: diaryCount,
      );
    },
  );
});

/// 게시물 통계 데이터 클래스
class PostStats {
  const PostStats({
    required this.totalCount,
    required this.questionCount,
    required this.diaryCount,
  });

  final int totalCount;
  final int questionCount;
  final int diaryCount;

  @override
  String toString() {
    return 'PostStats(total: $totalCount, questions: $questionCount, diaries: $diaryCount)';
  }
}
