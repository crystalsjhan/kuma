import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_community_app/core/constants/app_constants.dart';
import 'package:plant_community_app/core/router/app_router.dart';
import 'package:plant_community_app/domain/entities/post.dart';
import 'package:plant_community_app/presentation/providers/post_providers.dart';
import 'package:plant_community_app/presentation/widgets/post_card.dart';

/// 게시물 목록 화면
/// 
/// 반려 식물 커뮤니티의 메인 피드 화면입니다.
/// - 게시물 목록 표시
/// - 타입별 필터링 (전체, 질문, 일기)
/// - Pull-to-refresh 기능
/// - 로딩 및 에러 상태 처리
class PostListPage extends ConsumerWidget {
  const PostListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: _buildAppBar(context, ref),
      body: Column(
        children: [
          // 필터 탭
          _buildFilterTabs(context, ref),
          // 게시물 목록
          Expanded(
            child: _buildPostList(context, ref),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  /// AppBar 구성
  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text(AppConstants.appName),
      centerTitle: true,
      actions: [
        // 로그인 버튼
        IconButton(
          onPressed: () => AppRouter.goToLogin(context),
          icon: const Icon(Icons.login),
          tooltip: '로그인',
        ),
        // 검색 버튼
        IconButton(
          onPressed: () => _showSearchDialog(context, ref),
          icon: const Icon(Icons.search),
          tooltip: '검색',
        ),
        // 새로고침 버튼
        IconButton(
          onPressed: () => _refreshPosts(ref),
          icon: const Icon(Icons.refresh),
          tooltip: '새로고침',
        ),
      ],
    );
  }

  /// 필터 탭 구성
  Widget _buildFilterTabs(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedPostTypeProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // 전체 탭
          _buildFilterChip(
            context: context,
            ref: ref,
            label: '전체',
            isSelected: selectedType == null,
            onTap: () => ref.read(selectedPostTypeProvider.notifier).state = null,
          ),
          const SizedBox(width: 8.0),
          
          // 질문 탭
          _buildFilterChip(
            context: context,
            ref: ref,
            label: '질문',
            isSelected: selectedType == PostType.question,
            onTap: () => ref.read(selectedPostTypeProvider.notifier).state = PostType.question,
          ),
          const SizedBox(width: 8.0),
          
          // 일기 탭
          _buildFilterChip(
            context: context,
            ref: ref,
            label: '일기',
            isSelected: selectedType == PostType.diary,
            onTap: () => ref.read(selectedPostTypeProvider.notifier).state = PostType.diary,
          ),
          
          const Spacer(),
          
          // 통계 정보
          _buildStatsInfo(context, ref),
        ],
      ),
    );
  }

  /// 필터 칩 위젯
  Widget _buildFilterChip({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// 통계 정보 표시
  Widget _buildStatsInfo(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(postStatsProvider);
    
    return statsAsync.when(
      data: (stats) => Text(
        '총 ${stats.totalCount}개',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// 게시물 목록 구성
  Widget _buildPostList(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(filteredPostListProvider);
    
    return RefreshIndicator(
      onRefresh: () => _refreshPosts(ref),
      child: postsAsync.when(
        data: (posts) => _buildPostListView(context, ref, posts),
        loading: () => _buildLoadingState(),
        error: (error, stackTrace) => _buildErrorState(context, ref, error.toString()),
      ),
    );
  }

  /// 게시물 리스트뷰
  Widget _buildPostListView(BuildContext context, WidgetRef ref, List<Post> posts) {
    if (posts.isEmpty) {
      return _buildEmptyState(context);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100.0), // FAB 공간 확보
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostCard(
          post: post,
          onTap: () => _navigateToPostDetail(context, post.id),
        );
      },
    );
  }

  /// 로딩 상태 UI
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100.0),
      itemCount: 5, // 스켈레톤 로더 개수
      itemBuilder: (context, index) => const PostCardSkeleton(),
    );
  }

  /// 에러 상태 UI
  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.0,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16.0),
            Text(
              '게시물을 불러올 수 없습니다',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton.icon(
              onPressed: () => _refreshPosts(ref),
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 상태 UI
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco_outlined,
              size: 64.0,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16.0),
            Text(
              '반려 식물 커뮤니티에 오신 것을 환영합니다!',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Text(
              '로그인하여 다른 식물 애호가들과 소통해보세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => AppRouter.goToLogin(context),
                  icon: const Icon(Icons.login),
                  label: const Text('로그인'),
                ),
                const SizedBox(width: 12.0),
                OutlinedButton.icon(
                  onPressed: () => AppRouter.goToSignup(context),
                  icon: const Icon(Icons.person_add),
                  label: const Text('회원가입'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 플로팅 액션 버튼
  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToCreatePost(context),
      icon: const Icon(Icons.add),
      label: const Text('글쓰기'),
      tooltip: '새 게시물 작성',
    );
  }

  /// 검색 다이얼로그 표시
  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _SearchDialog(ref: ref),
    );
  }

  /// 게시물 새로고침
  Future<void> _refreshPosts(WidgetRef ref) async {
    // 새로고침 트리거
    ref.read(postRefreshProvider.notifier).state++;
    
    // 필터된 목록도 새로고침
    ref.invalidate(filteredPostListProvider);
  }

  /// 게시물 상세 화면으로 이동
  void _navigateToPostDetail(BuildContext context, String postId) {
    // TODO: 게시물 상세 화면 구현 후 라우팅 추가
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('게시물 상세: $postId')),
    );
  }

  /// 게시물 작성 화면으로 이동
  void _navigateToCreatePost(BuildContext context) {
    // TODO: 게시물 작성 화면 구현 후 라우팅 추가
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('게시물 작성 화면 (준비 중)')),
    );
  }
}

/// 검색 다이얼로그
class _SearchDialog extends StatefulWidget {
  const _SearchDialog({required this.ref});
  
  final WidgetRef ref;

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  final _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('게시물 검색'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: '검색어를 입력하세요',
              prefixIcon: Icon(Icons.search),
            ),
            autofocus: true,
            onSubmitted: (query) => _performSearch(context, query),
          ),
          const SizedBox(height: 16.0),
          const Text(
            '제목과 내용에서 검색됩니다.',
            style: TextStyle(fontSize: 12.0),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () => _performSearch(context, _searchController.text),
          child: const Text('검색'),
        ),
      ],
    );
  }

  void _performSearch(BuildContext context, String query) {
    if (query.trim().isNotEmpty) {
      widget.ref.read(searchQueryProvider.notifier).state = query.trim();
      Navigator.of(context).pop();
      
      // TODO: 검색 결과 화면으로 이동
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('검색: "$query"')),
      );
    }
  }
}
