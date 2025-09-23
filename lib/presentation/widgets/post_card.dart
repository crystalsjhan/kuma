import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plant_community_app/core/utils/date_formatter.dart';
import 'package:plant_community_app/domain/entities/post.dart';
import 'package:plant_community_app/data/models/post_model.dart';

/// 게시물 카드 위젯
/// 
/// 게시물 목록에서 사용되는 재사용 가능한 카드 컴포넌트입니다.
/// 디자인 시스템에 따라 스타일링되었으며, 다음 요소들을 포함합니다:
/// - 게시물 타입 배지
/// - 제목 및 내용 미리보기
/// - 첨부 이미지 (있는 경우)
/// - 작성자 정보 및 작성일
/// - 좋아요 및 댓글 수
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.showImage = true,
    this.maxLines = 3,
    this.onEdit,
    this.onDelete,
  });

  /// 표시할 게시물 엔티티
  final Post post;

  /// 카드 탭 콜백
  final VoidCallback? onTap;

  /// 이미지 표시 여부
  final bool showImage;

  /// 내용 미리보기 최대 라인 수
  final int maxLines;

  /// 수정 콜백
  final VoidCallback? onEdit;

  /// 삭제 콜백
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 게시물 타입 배지와 메타 정보
              _buildHeader(context, colorScheme, textTheme),
              const SizedBox(height: 12.0),
              
              // 게시물 제목
              _buildTitle(textTheme),
              const SizedBox(height: 8.0),
              
              // 게시물 내용 미리보기
              _buildContentPreview(textTheme),
              
              // 첨부 이미지 (있는 경우)
              if (showImage && post.hasImage) ...[
                const SizedBox(height: 12.0),
                _buildImage(context),
              ],
              
              const SizedBox(height: 12.0),
              
              // 하단 정보 (좋아요, 댓글 수)
              _buildFooter(colorScheme, textTheme),
            ],
          ),
        ),
      ),
    );
  }

  /// 헤더 영역 (타입 배지, 작성자, 작성일)
  Widget _buildHeader(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      children: [
        // 게시물 타입 배지
        _buildTypeBadge(colorScheme, textTheme),
        const SizedBox(width: 8.0),
        
        // 작성자 이름
        Expanded(
          child: Text(
            post.authorName,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // 작성일
        Text(
          DateFormatter.formatRelativeTime(post.createdAt),
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  /// 게시물 타입 배지
  Widget _buildTypeBadge(ColorScheme colorScheme, TextTheme textTheme) {
    final isQuestion = post.type == PostType.question;
    final typeText = post.type.displayName;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isQuestion ? colorScheme.primary : colorScheme.secondary,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        typeText,
        style: textTheme.labelMedium?.copyWith(
          color: isQuestion ? colorScheme.onPrimary : colorScheme.onSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 게시물 제목
  Widget _buildTitle(TextTheme textTheme) {
    return Text(
      post.title,
      style: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 게시물 내용 미리보기
  Widget _buildContentPreview(TextTheme textTheme) {
    return Text(
      post.contentPreview,
      style: textTheme.bodyMedium?.copyWith(
        height: 1.4,
        color: textTheme.bodyMedium?.color?.withOpacity(0.8),
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 첨부 이미지
  Widget _buildImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedNetworkImage(
          imageUrl: post.imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Theme.of(context).colorScheme.surface,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Theme.of(context).colorScheme.surface,
            child: Icon(
              Icons.image_not_supported,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              size: 48.0,
            ),
          ),
        ),
      ),
    );
  }

  /// 하단 정보 (좋아요, 댓글 수, 액션 버튼)
  Widget _buildFooter(ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      children: [
        // 좋아요 수
        _buildStatItem(
          icon: Icons.favorite_border,
          count: post.likeCount,
          colorScheme: colorScheme,
          textTheme: textTheme,
        ),
        const SizedBox(width: 16.0),
        
        // 댓글 수
        _buildStatItem(
          icon: Icons.chat_bubble_outline,
          count: post.commentCount,
          colorScheme: colorScheme,
          textTheme: textTheme,
        ),
        
        const Spacer(),
        
        // 더보기 버튼 (길게 누르면 메뉴 표시)
        Builder(
          builder: (context) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 수정/삭제 버튼 (본인 게시물인 경우에만 표시)
              if (_canEditOrDelete()) ...[
                IconButton(
                  onPressed: () => _showActionMenu(context),
                  icon: Icon(
                    Icons.more_vert,
                    size: 20.0,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 32.0,
                    minHeight: 32.0,
                  ),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 8.0),
              ],
              
              // 상세보기 버튼
              GestureDetector(
                onTap: onTap,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16.0,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 통계 항목 (좋아요, 댓글 수)
  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18.0,
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4.0),
        Text(
          count.toString(),
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 수정/삭제 가능 여부 확인
  bool _canEditOrDelete() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('DEBUG: 현재 사용자가 로그인되지 않음');
      return false;
    }
    
    print('DEBUG: 현재 사용자 UID: ${currentUser.uid}');
    print('DEBUG: 게시물 작성자 UID: ${post.authorUid}');
    print('DEBUG: 작성자 일치 여부: ${post.authorUid == currentUser.uid}');
    
    // Post 엔티티의 authorUid와 현재 사용자 UID 비교
    return post.authorUid == currentUser.uid;
  }

  /// 액션 메뉴 표시
  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 수정 버튼
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('수정'),
              onTap: () {
                Navigator.pop(context);
                onEdit?.call();
              },
            ),
            
            // 삭제 버튼
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('삭제', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmDialog(context);
              },
            ),
            
            // 취소 버튼
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('취소'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 삭제 확인 다이얼로그
  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시물 삭제'),
        content: const Text('정말로 이 게시물을 삭제하시겠습니까?\n삭제된 게시물은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

/// 게시물 카드 스켈레톤 로더
/// 로딩 상태에서 표시되는 스켈레톤 UI입니다.
class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shimmerColor = colorScheme.onSurface.withOpacity(0.1);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 스켈레톤
            Row(
              children: [
                Container(
                  width: 60.0,
                  height: 24.0,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Container(
                    height: 16.0,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  width: 50.0,
                  height: 14.0,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            
            // 제목 스켈레톤
            Container(
              width: double.infinity,
              height: 20.0,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            const SizedBox(height: 8.0),
            
            // 내용 스켈레톤
            ...List.generate(2, (index) => Padding(
              padding: EdgeInsets.only(bottom: index == 1 ? 0 : 4.0),
              child: Container(
                width: index == 1 ? 200.0 : double.infinity,
                height: 16.0,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            )),
            const SizedBox(height: 12.0),
            
            // 이미지 스켈레톤
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            
            // 하단 정보 스켈레톤
            Row(
              children: [
                ...List.generate(2, (index) => Padding(
                  padding: EdgeInsets.only(right: index == 0 ? 16.0 : 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 18.0,
                        height: 18.0,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Container(
                        width: 20.0,
                        height: 14.0,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
