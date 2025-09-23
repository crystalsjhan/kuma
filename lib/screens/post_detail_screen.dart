import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:plant_community_app/data/models/post_model.dart';
import 'package:plant_community_app/core/utils/date_formatter.dart';
import 'package:plant_community_app/presentation/widgets/comment_list_widget.dart';
import 'package:plant_community_app/presentation/widgets/comment_input_widget.dart';

/// 게시물 상세 화면
/// 
/// 게시물의 전체 내용을 표시하는 화면입니다.
/// 제목, 내용, 이미지, 작성자 정보, 좋아요/댓글 수 등을 표시합니다.
class PostDetailScreen extends StatefulWidget {
  final PostModel post;
  
  const PostDetailScreen({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likeCount;
  }

  /// 좋아요 토글
  Future<void> _toggleLike() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    try {
      // Firestore에서 좋아요 수 업데이트
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.postId)
          .update({
        'likeCount': _likeCount,
      });
    } catch (e) {
      // 실패 시 원래 상태로 되돌리기
      setState(() {
        _isLiked = !_isLiked;
        _likeCount += _isLiked ? 1 : -1;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('좋아요 처리 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// 댓글 추가 완료 콜백
  void _onCommentAdded() {
    // 댓글 수 업데이트를 위해 화면 새로고침
    setState(() {
      // 댓글 수는 StreamBuilder에서 자동으로 업데이트됩니다
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0.0,
        actions: [
          // 공유 버튼
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('공유 기능은 준비 중입니다.')),
              );
            },
            icon: const Icon(Icons.share),
            tooltip: '공유',
          ),
        ],
      ),
      body: Column(
        children: [
          // 게시물 내용 (스크롤 가능)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 게시물 내용
                  _buildPostContent(theme),
                  
                  // 액션 버튼들
                  _buildActionButtons(theme),
                  
                  // 댓글 목록
                  _buildCommentSection(theme),
                ],
              ),
            ),
          ),
          
          // 댓글 입력
          CommentInputWidget(
            postId: widget.post.postId,
            onCommentAdded: _onCommentAdded,
          ),
        ],
      ),
    );
  }

  /// 게시물 내용
  Widget _buildPostContent(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (타입 배지, 작성자, 작성일)
          _buildHeader(theme),
          
          const SizedBox(height: 16.0),
          
          // 제목
          Text(
            widget.post.title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          
          const SizedBox(height: 12.0),
          
          // 내용
          Text(
            widget.post.content,
            style: textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
          ),
          
          const SizedBox(height: 16.0),
          
          // 이미지들
          if (widget.post.imageURLs != null && widget.post.imageURLs!.isNotEmpty)
            _buildImages(theme),
          
          const SizedBox(height: 16.0),
          
          // 메타 정보
          _buildMetaInfo(theme),
        ],
      ),
    );
  }

  /// 헤더 (타입 배지, 작성자, 작성일)
  Widget _buildHeader(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        // 게시물 타입 배지
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            widget.post.type == 'question' ? '질문' : '일기',
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(width: 12.0),
        
        // 작성자 이름
        Expanded(
          child: Text(
            '사용자 ${widget.post.authorUid.substring(0, 8)}...',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        
        // 작성일
        Text(
          DateFormatter.formatRelativeTime(widget.post.createdAt),
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  /// 이미지들
  Widget _buildImages(ThemeData theme) {
    final images = widget.post.imageURLs!;
    
    if (images.length == 1) {
      // 이미지가 1개인 경우
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: CachedNetworkImage(
            imageUrl: images.first,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: theme.colorScheme.surface,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: theme.colorScheme.surface,
              child: Icon(
                Icons.image_not_supported,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
                size: 48.0,
              ),
            ),
          ),
        ),
      );
    } else {
      // 이미지가 여러 개인 경우
      return Column(
        children: images.map((imageUrl) => Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: theme.colorScheme.surface,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: theme.colorScheme.surface,
                  child: Icon(
                    Icons.image_not_supported,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                    size: 48.0,
                  ),
                ),
              ),
            ),
          ),
        )).toList(),
      );
    }
  }

  /// 메타 정보 (수정일 등)
  Widget _buildMetaInfo(ThemeData theme) {
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.post.updatedAt != null) ...[
          Text(
            '수정됨 • ${DateFormatter.formatRelativeTime(widget.post.updatedAt!)}',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8.0),
        ],
        
        // 통계 정보
        Row(
          children: [
            Icon(
              Icons.favorite,
              size: 16.0,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 4.0),
            Text(
              _likeCount.toString(),
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 16.0),
            Icon(
              Icons.chat_bubble_outline,
              size: 16.0,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 4.0),
            Text(
              widget.post.commentCount.toString(),
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 액션 버튼들
  Widget _buildActionButtons(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // 좋아요 버튼
          Expanded(
            child: InkWell(
              onTap: _toggleLike,
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : colorScheme.onSurface.withOpacity(0.6),
                      size: 20.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      _isLiked ? '좋아요 취소' : '좋아요',
                      style: TextStyle(
                        color: _isLiked ? Colors.red : colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 8.0),
          
          // 댓글 버튼 (스크롤을 댓글 섹션으로 이동)
          Expanded(
            child: InkWell(
              onTap: () {
                // 댓글 섹션으로 스크롤
                Scrollable.ensureVisible(
                  context,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: colorScheme.onSurface.withOpacity(0.6),
                      size: 20.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      '댓글',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 댓글 섹션
  Widget _buildCommentSection(ThemeData theme) {
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 댓글 헤더
          Text(
            '댓글',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12.0),
          
          // 댓글 목록
          CommentListWidget(postId: widget.post.postId),
        ],
      ),
    );
  }
}
