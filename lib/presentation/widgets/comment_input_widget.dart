import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 댓글 입력 위젯
/// 
/// 댓글을 작성할 수 있는 입력 필드와 전송 버튼을 제공합니다.
class CommentInputWidget extends StatefulWidget {
  final String postId;
  final VoidCallback? onCommentAdded;

  const CommentInputWidget({
    super.key,
    required this.postId,
    this.onCommentAdded,
  });

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        // 텍스트 변경 시 UI 업데이트
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 댓글 작성
  Future<void> _submitComment() async {
    final content = _controller.text.trim();
    
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글 내용을 입력해주세요.')),
      );
      return;
    }

    if (content.length > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글은 1000자 이하로 작성해주세요.')),
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 먼저 댓글을 추가
      final commentRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc();

      final commentData = {
        'postId': widget.postId,
        'authorUid': currentUser.uid,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await commentRef.set(commentData);

      // 그 다음 게시물의 댓글 수 증가
      final postRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId);

      await postRef.update({
        'commentCount': FieldValue.increment(1),
      });

      // 성공 시 입력 필드 초기화
      _controller.clear();
      _focusNode.unfocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('댓글이 작성되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // 콜백 호출
        widget.onCommentAdded?.call();
      }
    } catch (e) {
      print('댓글 작성 에러: $e');
      if (mounted) {
        String errorMessage = '댓글 작성에 실패했습니다.';
        
        if (e.toString().contains('permission-denied')) {
          errorMessage = '댓글 작성 권한이 없습니다.';
        } else if (e.toString().contains('not-found')) {
          errorMessage = '게시물을 찾을 수 없습니다.';
        } else if (e.toString().contains('network')) {
          errorMessage = '네트워크 연결을 확인해주세요.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          // 댓글 입력 필드
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              maxLength: 1000,
              decoration: InputDecoration(
                hintText: '댓글을 작성해보세요...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2.0,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                counterText: '', // 글자 수 표시 숨김
              ),
              onSubmitted: (_) => _submitComment(),
            ),
          ),
          
          const SizedBox(width: 8.0),
          
          // 전송 버튼
          Container(
            decoration: BoxDecoration(
              color: _controller.text.trim().isNotEmpty && !_isSubmitting
                  ? colorScheme.primary
                  : colorScheme.primary.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _controller.text.trim().isNotEmpty && !_isSubmitting
                  ? _submitComment
                  : null,
              icon: _isSubmitting
                  ? SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.send,
                      color: colorScheme.onPrimary,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
