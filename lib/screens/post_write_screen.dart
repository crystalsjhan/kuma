import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:plant_community_app/data/models/post_model.dart';

/// 게시물 작성 화면
/// 
/// 사용자가 새로운 게시물을 작성할 수 있는 화면입니다.
/// 제목, 내용을 입력받아 Firestore에 저장합니다.
class PostWriteScreen extends StatefulWidget {
  const PostWriteScreen({super.key});

  @override
  State<PostWriteScreen> createState() => _PostWriteScreenState();
}

class _PostWriteScreenState extends State<PostWriteScreen> {
  // TextEditingController 선언
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  // 폼 키
  final _formKey = GlobalKey<FormState>();
  
  // 로딩 상태
  bool _isLoading = false;
  
  // 이미지 관련
  final ImagePicker _imagePicker = ImagePicker();
  List<File> _selectedImages = [];
  bool _isUploadingImages = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 이미지 선택 (갤러리에서)
  Future<void> _pickImages() async {
    try {
      // 최대 5개 이미지 제한
      final maxImages = 5;
      final remainingSlots = maxImages - _selectedImages.length;
      
      if (remainingSlots <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('최대 5개의 이미지만 선택할 수 있습니다.'),
          ),
        );
        return;
      }

      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (images.isNotEmpty) {
        // 남은 슬롯만큼만 추가
        final imagesToAdd = images.take(remainingSlots).toList();
        
        setState(() {
          _selectedImages.addAll(imagesToAdd.map((image) => File(image.path)));
        });
        
        // 제한을 초과한 경우 알림
        if (images.length > remainingSlots) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${remainingSlots}개의 이미지만 추가되었습니다. (최대 5개)'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 선택 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// 이미지 업로드
  Future<List<String>> _uploadImages() async {
    if (_selectedImages.isEmpty) return [];

    setState(() {
      _isUploadingImages = true;
    });

    try {
      final List<String> uploadedURLs = [];
      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // Firebase Storage 인스턴스 가져오기
      final storage = FirebaseStorage.instance;
      
      for (int i = 0; i < _selectedImages.length; i++) {
        final file = _selectedImages[i];
        
        // 파일 존재 여부 확인
        if (!await file.exists()) {
          print('파일이 존재하지 않습니다: ${file.path}');
          continue;
        }
        
        // 고유한 파일명 생성
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = '${currentUser.uid}_${timestamp}_$i.jpg';
        
        // Storage 참조 생성
        final ref = storage.ref().child('post_images').child(fileName);
        
        // 메타데이터 설정
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': currentUser.uid,
            'uploadedAt': timestamp.toString(),
          },
        );
        
        // 파일 업로드 (재시도 로직 포함)
        UploadTask uploadTask;
        try {
          uploadTask = ref.putFile(file, metadata);
          
          // 업로드 완료 대기 (타임아웃 30초)
          final snapshot = await uploadTask.timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('업로드 시간 초과');
            },
          );
          
          // 다운로드 URL 가져오기
          final downloadURL = await snapshot.ref.getDownloadURL();
          uploadedURLs.add(downloadURL);
          
          print('이미지 업로드 성공: $downloadURL');
          
        } catch (uploadError) {
          print('개별 이미지 업로드 실패: $uploadError');
          // 개별 이미지 업로드 실패는 계속 진행
          continue;
        }
      }

      if (uploadedURLs.isEmpty && _selectedImages.isNotEmpty) {
        throw Exception('모든 이미지 업로드에 실패했습니다.');
      }

      return uploadedURLs;
    } catch (e) {
      print('이미지 업로드 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 업로드 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return [];
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImages = false;
        });
      }
    }
  }

  /// 선택된 이미지 제거
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  /// 게시물 작성 완료 처리
  Future<void> _handleSubmit() async {
    // 폼 유효성 검사
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 제목과 내용 가져오기
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    
    // 유효성 검사
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('제목과 내용을 모두 입력해주세요.'),
        ),
      );
      return;
    }

    // 현재 로그인한 사용자 UID 가져오기
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인이 필요합니다.'),
        ),
      );
      return;
    }

    // 로딩 상태 설정
    setState(() {
      _isLoading = true;
    });

    try {
      // 이미지 업로드 (임시로 비활성화 - Firebase Storage 규칙 문제 해결 후 활성화)
      List<String> imageURLs = [];
      
      // 임시로 이미지 업로드 기능을 비활성화
      if (_selectedImages.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('현재 이미지 업로드 기능이 일시적으로 비활성화되어 있습니다. 텍스트만으로 게시물을 작성해주세요.'),
            backgroundColor: Colors.orange,
          ),
        );
        // 이미지 없이 계속 진행
      }

      // PostModel 객체 생성 (임시 postId 사용)
      final postModel = PostModel(
        postId: '', // Firestore에서 자동 생성될 예정
        authorUid: currentUser.uid,
        title: title,
        content: content,
        imageURLs: imageURLs.isNotEmpty ? imageURLs : null,
        createdAt: DateTime.now(), // 임시로 현재 시간 사용
        likeCount: 0,
        commentCount: 0,
      );

      // Firestore에 저장할 Map 데이터 생성
      final postDataMap = postModel.toJson();
      
      // authorUid를 Map에 명시적으로 포함 (toJson에서 누락될 수 있음)
      postDataMap['authorUid'] = currentUser.uid;
      
      // Firestore에 저장 (createdAt은 serverTimestamp로 덮어쓰기)
      await FirebaseFirestore.instance
          .collection('posts')
          .add({
        ...postDataMap,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': null,
      });

      if (mounted) {
        // 성공 시 SnackBar 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('게시글이 성공적으로 등록되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // 이전 화면으로 돌아가기
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        // 에러 시 SnackBar 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시글 등록에 실패했습니다: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      // 로딩 상태 해제
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물 작성'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0.0,
        actions: [
          // 작성 완료 버튼
          TextButton(
            onPressed: _isLoading ? null : _handleSubmit,
            child: _isLoading
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
                : Text(
                    '작성 완료',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 제목 입력 필드
                _buildTitleField(theme),
                
                const SizedBox(height: 16.0),
                
                // 내용 입력 필드
                _buildContentField(theme),
                
                const SizedBox(height: 16.0),
                
                // 이미지 선택 섹션
                _buildImageSection(theme),
                
                const SizedBox(height: 24.0),
                
                // 작성 완료 버튼 (하단)
                _buildSubmitButton(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 제목 입력 필드
  Widget _buildTitleField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '제목',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: '제목을 입력해주세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2.0,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '제목을 입력해주세요';
            }
            if (value.trim().length < 2) {
              return '제목은 2자 이상 입력해주세요';
            }
            if (value.trim().length > 100) {
              return '제목은 100자 이하로 입력해주세요';
            }
            return null;
          },
          maxLength: 100,
        ),
      ],
    );
  }

  /// 내용 입력 필드
  Widget _buildContentField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '내용',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: _contentController,
          maxLines: 10,
          decoration: InputDecoration(
            hintText: '내용을 입력해주세요',
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2.0,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '내용을 입력해주세요';
            }
            if (value.trim().length < 10) {
              return '내용은 10자 이상 입력해주세요';
            }
            if (value.trim().length > 2000) {
              return '내용은 2000자 이하로 입력해주세요';
            }
            return null;
          },
          maxLength: 2000,
        ),
      ],
    );
  }

  /// 이미지 선택 섹션
  Widget _buildImageSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '이미지 (선택사항)',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 8.0),
        
        // 이미지 선택 버튼
        _buildImagePickerButton(theme),
        
        const SizedBox(height: 12.0),
        
        // 선택된 이미지 미리보기
        if (_selectedImages.isNotEmpty) _buildImagePreview(theme),
        
        // 이미지 업로드 중 표시
        if (_isUploadingImages) _buildUploadingIndicator(theme),
      ],
    );
  }

  /// 이미지 선택 버튼
  Widget _buildImagePickerButton(ThemeData theme) {
    return SizedBox(
      height: 48.0,
      child: OutlinedButton.icon(
        onPressed: _isLoading || _isUploadingImages ? null : _pickImages,
        icon: const Icon(Icons.add_photo_alternate),
        label: Text(
          _selectedImages.isEmpty ? '이미지 추가' : '이미지 추가 (${_selectedImages.length}/5)',
          style: theme.textTheme.labelMedium,
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }

  /// 이미지 미리보기
  Widget _buildImagePreview(ThemeData theme) {
    return Container(
      height: 120.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Container(
            width: 120.0,
            margin: const EdgeInsets.only(right: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: theme.colorScheme.outline,
                width: 1.0,
              ),
            ),
            child: Stack(
              children: [
                // 이미지
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    _selectedImages[index],
                    width: 120.0,
                    height: 120.0,
                    fit: BoxFit.cover,
                  ),
                ),
                
                // 삭제 버튼
                Positioned(
                  top: 4.0,
                  right: 4.0,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      width: 24.0,
                      height: 24.0,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 이미지 업로드 중 인디케이터
  Widget _buildUploadingIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Text(
            '이미지 업로드 중...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 작성 완료 버튼
  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      height: 56.0,
      child: ElevatedButton.icon(
        onPressed: (_isLoading || _isUploadingImages) ? null : _handleSubmit,
        icon: _isLoading
            ? SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : const Icon(Icons.check),
        label: Text(
          _isLoading 
              ? (_isUploadingImages ? '이미지 업로드 중...' : '등록 중...') 
              : '작성 완료',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }
}
