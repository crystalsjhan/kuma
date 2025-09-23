import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plant_community_app/data/models/comment_model.dart';
import 'package:plant_community_app/presentation/widgets/comment_widget.dart';

/// 댓글 목록 위젯
/// 
/// 특정 게시물의 댓글 목록을 실시간으로 표시하는 위젯입니다.
class CommentListWidget extends StatelessWidget {
  final String postId;

  const CommentListWidget({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          print('댓글 스트림 에러: ${snapshot.error}');
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: colorScheme.error,
                    size: 48.0,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '댓글을 불러오는 중 오류가 발생했습니다.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '다시 시도해주세요.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final comments = snapshot.data?.docs ?? [];

        if (comments.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: colorScheme.onSurface.withOpacity(0.3),
                    size: 48.0,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '아직 댓글이 없습니다.\n첫 번째 댓글을 작성해보세요!',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            try {
              final commentDoc = comments[index];
              if (!commentDoc.exists) {
                return const SizedBox.shrink(); // 존재하지 않는 문서는 건너뛰기
              }
              
              final comment = CommentModel.fromFirestore(commentDoc);
              
              return CommentWidget(
                comment: comment,
                onEdit: () => _handleEditComment(context, comment),
                onDelete: () => _handleDeleteComment(context, comment),
              );
            } catch (e) {
              // 데이터 변환 오류 시 에러 위젯 표시
              return Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: colorScheme.onErrorContainer,
                      size: 20.0,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        '댓글을 불러올 수 없습니다: ${e.toString()}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }

  /// 댓글 수정 처리
  void _handleEditComment(BuildContext context, CommentModel comment) {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    // 작성자 확인
    if (currentUser == null || currentUser.uid != comment.authorUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('본인이 작성한 댓글만 수정할 수 있습니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 댓글 수정 다이얼로그
    final TextEditingController controller = TextEditingController(text: comment.content);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('댓글 수정'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          maxLength: 1000,
          decoration: const InputDecoration(
            hintText: '댓글 내용을 입력해주세요',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final newContent = controller.text.trim();
              if (newContent.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('댓글 내용을 입력해주세요.')),
                );
                return;
              }
              
              if (newContent == comment.content) {
                Navigator.pop(context);
                return;
              }
              
              Navigator.pop(context);
              await _updateComment(context, comment, newContent);
            },
            child: const Text('수정'),
          ),
        ],
      ),
    );
  }

  /// 댓글 삭제 처리
  void _handleDeleteComment(BuildContext context, CommentModel comment) {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    // 작성자 확인
    if (currentUser == null || currentUser.uid != comment.authorUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('본인이 작성한 댓글만 삭제할 수 있습니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 삭제 확인 다이얼로그
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('댓글 삭제'),
        content: const Text('정말로 이 댓글을 삭제하시겠습니까?\n삭제된 댓글은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteComment(context, comment);
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

  /// 댓글 수정 실행
  Future<void> _updateComment(BuildContext context, CommentModel comment, String newContent) async {
    print('댓글 수정 시작: ${comment.commentId}');
    print('새 내용: $newContent');
    print('댓글 작성자 UID: ${comment.authorUid}');
    
    final currentUser = FirebaseAuth.instance.currentUser;
    print('현재 사용자 UID: ${currentUser?.uid}');
    print('작성자 일치 여부: ${currentUser?.uid == comment.authorUid}');
    
    try {
      final commentRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(comment.postId)
          .collection('comments')
          .doc(comment.commentId);

      print('댓글 수정 시도: ${commentRef.path}');
      
      // 댓글 문서 데이터 확인
      final commentDoc = await commentRef.get();
      if (commentDoc.exists) {
        print('댓글 문서 데이터: ${commentDoc.data()}');
      }
      
      await commentRef.update({
        'content': newContent,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('댓글 수정 성공');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('댓글이 수정되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('댓글 수정 에러: $e');
      if (context.mounted) {
        String errorMessage = '댓글 수정에 실패했습니다.';
        
        if (e.toString().contains('permission-denied')) {
          errorMessage = '댓글 수정 권한이 없습니다.';
        } else if (e.toString().contains('not-found')) {
          errorMessage = '댓글을 찾을 수 없습니다.';
        } else if (e.toString().contains('network')) {
          errorMessage = '네트워크 연결을 확인해주세요.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$errorMessage\n에러: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// 댓글 삭제 실행
  Future<void> _deleteComment(BuildContext context, CommentModel comment) async {
    print('댓글 삭제 시작: ${comment.commentId}');
    print('게시물 ID: ${comment.postId}');
    print('댓글 작성자 UID: ${comment.authorUid}');
    
    final currentUser = FirebaseAuth.instance.currentUser;
    print('현재 사용자 UID: ${currentUser?.uid}');
    print('작성자 일치 여부: ${currentUser?.uid == comment.authorUid}');
    
    try {
      // 댓글 삭제 시도
      final commentRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(comment.postId)
          .collection('comments')
          .doc(comment.commentId);

      print('댓글 삭제 시도: ${commentRef.path}');
      
      // 댓글이 존재하는지 먼저 확인
      final commentDoc = await commentRef.get();
      if (!commentDoc.exists) {
        throw Exception('댓글이 이미 삭제되었거나 존재하지 않습니다.');
      }
      
      print('댓글 문서 데이터: ${commentDoc.data()}');
      
      await commentRef.delete();
      print('댓글 삭제 성공');

      // 게시물의 댓글 수 감소 시도
      final postRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(comment.postId);

      print('댓글 수 감소 시도: ${postRef.path}');
      
      // 게시물이 존재하는지 확인
      final postDoc = await postRef.get();
      if (postDoc.exists) {
        await postRef.update({
          'commentCount': FieldValue.increment(-1),
        });
        print('댓글 수 감소 성공');
      } else {
        print('게시물이 존재하지 않음 - 댓글 수 감소 건너뛰기');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('댓글이 삭제되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('댓글 삭제 에러: $e');
      print('에러 타입: ${e.runtimeType}');
      
      if (context.mounted) {
        String errorMessage = '댓글 삭제에 실패했습니다.';
        
        if (e.toString().contains('permission-denied')) {
          errorMessage = '댓글 삭제 권한이 없습니다. Firebase 규칙을 확인해주세요.';
        } else if (e.toString().contains('not-found')) {
          errorMessage = '댓글을 찾을 수 없습니다.';
        } else if (e.toString().contains('network')) {
          errorMessage = '네트워크 연결을 확인해주세요.';
        } else if (e.toString().contains('unavailable')) {
          errorMessage = '서비스를 사용할 수 없습니다. 잠시 후 다시 시도해주세요.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$errorMessage\n\n에러: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: '다시 시도',
              onPressed: () => _deleteComment(context, comment),
            ),
          ),
        );
      }
    }
  }
}
