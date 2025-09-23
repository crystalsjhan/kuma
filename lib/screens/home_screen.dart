import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plant_community_app/data/models/post_model.dart';
import 'package:plant_community_app/presentation/widgets/post_card.dart';
import 'package:plant_community_app/screens/post_write_screen.dart';
import 'package:plant_community_app/screens/post_edit_screen.dart';
import 'package:plant_community_app/screens/post_detail_screen.dart';

/// 홈 화면
/// 
/// Firestore의 posts 컬렉션에서 게시물 데이터를 실시간으로 표시하는 화면입니다.
/// StreamBuilder를 사용하여 실시간 데이터 업데이트를 지원합니다.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('식물 커뮤니티'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0.0,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: 검색 기능 구현
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('검색 기능은 준비 중입니다')),
              );
            },
            icon: const Icon(Icons.search),
            tooltip: '검색',
          ),
        ],
      ),
      body: _buildBody(context, colorScheme),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PostWriteScreen(),
            ),
          );
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 메인 바디 위젯
  Widget _buildBody(BuildContext context, ColorScheme colorScheme) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // 연결 상태 확인
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(colorScheme);
        }

        // 에러 상태 확인
        if (snapshot.hasError) {
          return _buildErrorState(context, snapshot.error.toString(), colorScheme);
        }

        // 데이터 확인
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(context, colorScheme);
        }

        // 게시물 목록 표시
        return _buildPostList(context, snapshot.data!.docs, colorScheme);
      },
    );
  }

  /// 로딩 상태 위젯
  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          const SizedBox(height: 16.0),
          Text(
            '게시물을 불러오는 중...',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }

  /// 에러 상태 위젯
  Widget _buildErrorState(BuildContext context, String error, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.0,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16.0),
            Text(
              '오류가 발생했습니다',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              error,
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton.icon(
              onPressed: () {
                // StreamBuilder가 자동으로 다시 시도함
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('다시 시도 중...')),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco_outlined,
              size: 64.0,
              color: colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16.0),
            Text(
              '아직 게시물이 없습니다',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '첫 번째 게시물을 작성해보세요!',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PostWriteScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('게시물 작성'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 게시물 목록 위젯
  Widget _buildPostList(BuildContext context, List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        
        try {
          // PostModel로 변환
          final postModel = PostModel.fromFirestore(doc);
          
          // PostCard 위젯 사용 (PostModel을 Post 엔티티로 변환)
          return PostCard(
            post: postModel.toEntity(),
            onTap: () => _handleViewPost(context, postModel),
            onEdit: () => _handleEditPost(context, postModel),
            onDelete: () => _handleDeletePost(context, postModel),
          );
        } catch (e) {
          // 데이터 변환 오류 시 에러 타일 표시
          return _buildErrorTile(context, e.toString(), colorScheme);
        }
      },
    );
  }


  /// 에러 타일 위젯
  Widget _buildErrorTile(BuildContext context, String error, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                '데이터 로드 오류: $error',
                style: TextStyle(
                  color: colorScheme.onErrorContainer,
                  fontSize: 14.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 게시물 상세 보기 처리
  void _handleViewPost(BuildContext context, PostModel postModel) {
    // 상세 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(post: postModel),
      ),
    );
  }

  /// 게시물 수정 처리
  void _handleEditPost(BuildContext context, PostModel postModel) {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    // 작성자 확인
    if (currentUser == null || currentUser.uid != postModel.authorUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('본인이 작성한 게시물만 수정할 수 있습니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 수정 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostEditScreen(post: postModel),
      ),
    ).then((result) {
      // 수정 완료 시 새로고침 알림
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('게시물이 수정되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  /// 게시물 삭제 처리
  void _handleDeletePost(BuildContext context, PostModel postModel) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    // 작성자 확인
    if (currentUser == null || currentUser.uid != postModel.authorUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('본인이 작성한 게시물만 삭제할 수 있습니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Firestore에서 게시물 삭제
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postModel.postId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('게시물이 삭제되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시물 삭제에 실패했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
