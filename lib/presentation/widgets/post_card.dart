import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:plant_community_app/core/constants/app_constants.dart';
import 'package:plant_community_app/core/utils/date_formatter.dart';
import 'package:plant_community_app/domain/entities/post.dart';

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
  });

  /// 표시할 게시물 엔티티
  final Post post;

  /// 카드 탭 콜백
  final VoidCallback? onTap;

  /// 이미지 표시 여부
  final bool showImage;

  /// 내용 미리보기 최대 라인 수
  final int maxLines;

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
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isQuestion ? colorScheme.primary : colorScheme.secondary,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        post.type.displayName,
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
        
        // 더보기 버튼
        IconButton(
          onPressed: onTap,
          icon: Icon(
            Icons.arrow_forward_ios,
            size: 16.0,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
          constraints: const BoxConstraints(
            minWidth: 32.0,
            minHeight: 32.0,
          ),
          padding: EdgeInsets.zero,
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
