import 'package:plant_community_app/core/errors/failures.dart';
import 'package:plant_community_app/data/models/post_model.dart';
import 'package:plant_community_app/domain/entities/post.dart';
import 'package:plant_community_app/domain/repositories/post_repository.dart';

/// Post Repository 구현체
/// 
/// 현재는 하드코딩된 더미 데이터를 사용하며,
/// 추후 Firebase Firestore나 다른 데이터 소스로 교체 예정입니다.
class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl();

  /// 더미 게시물 데이터
  static final List<PostModel> _dummyPosts = [
    PostModel(
      postId: '1',
      authorUid: 'user1',
      title: '몬스테라 잎이 노랗게 변해요 😢',
      content: '몬스테라를 키운 지 3개월 정도 됐는데, 최근에 잎이 노랗게 변하기 시작했어요. 물을 너무 많이 준 걸까요? 아니면 햇빛이 부족한 걸까요? 초보 집사라 어떻게 해야 할지 모르겠어요. 혹시 비슷한 경험 있으신 분 조언 부탁드려요!',
      imageURLs: ['https://images.unsplash.com/photo-1545239351-ef35f43d514b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80'],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likeCount: 15,
      commentCount: 8,
      type: 'question',
    ),
    PostModel(
      postId: '2',
      authorUid: 'user2',
      title: '우리집 스킨답서스 성장일기 🌿',
      content: '작년 겨울에 손바닥만 했던 스킨답서스가 이제 이렇게 무성해졌어요! 매일 조금씩 자라는 모습을 보니 정말 뿌듯하네요. 물꽂이로 시작해서 화분에 옮겨 심은 지 벌써 1년이 지났어요. 앞으로도 건강하게 자라길!',
      imageURLs: ['https://images.unsplash.com/photo-1416879595882-3373a0480b5b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80'],
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      likeCount: 32,
      commentCount: 12,
      type: 'diary',
    ),
    PostModel(
      postId: '3',
      authorUid: 'user3',
      title: '실내에서 키우기 좋은 식물 추천해주세요!',
      content: '새로 이사한 집에 식물을 키우고 싶은데, 어떤 식물이 좋을까요? 조건은 다음과 같아요:\n1. 햇빛이 잘 안 드는 곳\n2. 관리가 쉬운 것\n3. 공기정화 효과가 있으면 좋겠어요\n\n초보자도 쉽게 키울 수 있는 식물 추천 부탁드려요!',
      imageURLs: null,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      likeCount: 28,
      commentCount: 15,
      type: 'question',
    ),
    PostModel(
      postId: '4',
      authorUid: 'user4',
      title: '고무나무 새순이 나왔어요! 🌱',
      content: '겨울 내내 조용했던 고무나무에서 드디어 새순이 나왔어요! 봄이 되니까 식물들도 활기를 찾는 것 같아요. 새로 나온 잎이 정말 귀여워요. 이번 봄에는 분갈이도 해줘야겠네요.',
      imageURLs: ['https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      likeCount: 18,
      commentCount: 6,
      type: 'diary',
    ),
    PostModel(
      postId: '5',
      authorUid: 'user5',
      title: '식물 물주기 타이밍을 어떻게 알 수 있나요?',
      content: '식물을 키우기 시작한 지 얼마 안 됐는데, 언제 물을 줘야 할지 잘 모르겠어요. 흙이 마르면 주라고 하는데, 겉으로는 말라보여도 속은 축축할 수도 있잖아요? 물주기 타이밍 알 수 있는 좋은 방법 있을까요?',
      imageURLs: null,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      likeCount: 42,
      commentCount: 23,
      type: 'question',
    ),
    PostModel(
      postId: '6',
      authorUid: 'user6',
      title: '산세베리아 번식 성공! 💚',
      content: '산세베리아 잎꽂이 번식에 성공했어요! 작년에 잎을 잘라서 물에 꽂아뒀는데, 뿌리가 나오더니 이제 작은 새싹까지 생겼어요. 시간은 오래 걸렸지만 너무 뿌듯해요. 이제 화분에 옮겨 심어야겠어요.',
      imageURLs: null,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      likeCount: 67,
      commentCount: 19,
      type: 'diary',
    ),
    PostModel(
      postId: '7',
      authorUid: 'user7',
      title: '식물 벌레 때문에 고민이에요 😰',
      content: '최근에 식물에 작은 벌레들이 생겼어요. 아마 진딧물인 것 같은데, 어떻게 처리해야 할까요? 화학 살충제는 실내에서 사용하기 부담스러워서요. 천연 방법이나 안전한 처리 방법 아시는 분 계신가요?',
      imageURLs: ['https://images.unsplash.com/photo-1542280756-74b2f55e73ab?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80'],
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      likeCount: 35,
      commentCount: 17,
      type: 'question',
    ),
    PostModel(
      postId: '8',
      authorUid: 'user8',
      title: '드디어 첫 번째 화분정원 완성! 🪴',
      content: '식물 키우기 시작한 지 6개월, 드디어 제 작은 화분정원이 완성됐어요! 몬스테라, 스킨답서스, 산세베리아, 고무나무까지... 이제 우리집이 정글 같아요 ㅎㅎ 매일 식물들 보는 재미에 살고 있어요!',
      imageURLs: ['https://images.unsplash.com/photo-1463320898675-8097a898b32a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80'],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      likeCount: 89,
      commentCount: 31,
      type: 'diary',
    ),
  ];

  @override
  Future<Result<List<Post>>> getPosts() async {
    try {
      // 네트워크 딜레이 시뮬레이션
      await Future.delayed(const Duration(milliseconds: 1000));
      
      final posts = _dummyPosts.map((model) => model.toEntity()).toList();
      return Success(posts);
    } catch (e) {
      return const Error(
        NetworkFailure('게시물을 불러오는 중 네트워크 오류가 발생했습니다.'),
      );
    }
  }

  @override
  Future<Result<Post>> getPostById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final postModel = _dummyPosts.firstWhere(
        (post) => post.id == id,
        orElse: () => throw Exception('Post not found'),
      );
      
      return Success(postModel.toEntity());
    } catch (e) {
      return const Error(
        NotFoundFailure('해당 게시물을 찾을 수 없습니다.'),
      );
    }
  }

  @override
  Future<Result<List<Post>>> getPostsByType(PostType type) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      final filteredPosts = _dummyPosts
          .where((post) => post.type == type.value)
          .map((model) => model.toEntity())
          .toList();
      
      return Success(filteredPosts);
    } catch (e) {
      return const Error(
        NetworkFailure('게시물을 불러오는 중 네트워크 오류가 발생했습니다.'),
      );
    }
  }

  @override
  Future<Result<List<Post>>> searchPosts(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      
      final searchResults = _dummyPosts.where((post) {
        final titleMatch = post.title.toLowerCase().contains(query.toLowerCase());
        final contentMatch = post.content.toLowerCase().contains(query.toLowerCase());
        return titleMatch || contentMatch;
      }).map((model) => model.toEntity()).toList();
      
      return Success(searchResults);
    } catch (e) {
      return const Error(
        NetworkFailure('검색 중 네트워크 오류가 발생했습니다.'),
      );
    }
  }

  @override
  Future<Result<List<Post>>> getPostsPaginated({
    required int page,
    required int limit,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      final startIndex = page * limit;
      
      if (startIndex >= _dummyPosts.length) {
        return const Success([]);
      }
      
      final paginatedPosts = _dummyPosts
          .skip(startIndex)
          .take(limit)
          .map((model) => model.toEntity())
          .toList();
      
      return Success(paginatedPosts);
    } catch (e) {
      return const Error(
        NetworkFailure('게시물을 불러오는 중 네트워크 오류가 발생했습니다.'),
      );
    }
  }

  @override
  Future<Result<Post>> createPost(Post post) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      
      final newPostModel = PostModel.fromEntity(post);
      _dummyPosts.insert(0, newPostModel);
      
      return Success(post);
    } catch (e) {
      return const Error(
        ServerFailure('게시물 작성 중 오류가 발생했습니다.'),
      );
    }
  }

  @override
  Future<Result<Post>> updatePost(Post post) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      final index = _dummyPosts.indexWhere((p) => p.id == post.id);
      if (index == -1) {
        return const Error(
          NotFoundFailure('수정할 게시물을 찾을 수 없습니다.'),
        );
      }
      
      _dummyPosts[index] = PostModel.fromEntity(post);
      return Success(post);
    } catch (e) {
      return const Error(
        ServerFailure('게시물 수정 중 오류가 발생했습니다.'),
      );
    }
  }

  @override
  Future<Result<void>> deletePost(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final index = _dummyPosts.indexWhere((post) => post.id == id);
      if (index == -1) {
        return const Error(
          NotFoundFailure('삭제할 게시물을 찾을 수 없습니다.'),
        );
      }
      
      _dummyPosts.removeAt(index);
      return const Success(null);
    } catch (e) {
      return const Error(
        ServerFailure('게시물 삭제 중 오류가 발생했습니다.'),
      );
    }
  }
}
