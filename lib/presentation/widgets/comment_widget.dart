import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plant_community_app/data/models/comment_model.dart';

/// 댓글 위젯
/// 
/// 개별 댓글을 표시하는 위젯입니다.
/// 댓글 내용, 작성자, 작성 시간, 수정/삭제 버튼을 포함합니다.
class CommentWidget extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CommentWidget({
    super.key,
    required this.comment,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final currentUser = FirebaseAuth.instance.currentUser;
    final isAuthor = currentUser?.uid == comment.authorUid;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (작성자, 시간, 액션 버튼)
          Row(
            children: [
              // 작성자 정보
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12.0,
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      child: Text(
                        comment.authorUid.substring(0, 1).toUpperCase(),
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      '사용자 ${comment.authorUid.substring(0, 8)}...',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 시간 정보
              Text(
                comment.timeSinceCreated,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              
              // 액션 버튼 (작성자만)
              if (isAuthor) ...[
                const SizedBox(width: 8.0),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 16.0,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16.0),
                          SizedBox(width: 8.0),
                          Text('수정'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16.0, color: Colors.red),
                          SizedBox(width: 8.0),
                          Text('삭제', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 8.0),
          
          // 댓글 내용
          Text(
            comment.content,
            style: textTheme.bodyMedium?.copyWith(
              height: 1.4,
            ),
          ),
          
          // 수정 표시
          if (comment.isEdited) ...[
            const SizedBox(height: 4.0),
            Text(
              comment.timeSinceUpdated,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
