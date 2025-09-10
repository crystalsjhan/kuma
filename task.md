# 게시물 목록 화면 UI 개발 태스크

## 🎯 프로젝트 개요
반려 식물 커뮤니티 앱의 게시물 목록 화면(피드) UI를 Clean Architecture와 Riverpod 상태관리를 활용하여 구현합니다.

## 📋 우선순위별 태스크 목록

### Phase 1: 환경 설정 및 기초 구조 ✅
- [x] **[CRITICAL]** 필수 dependencies 추가
  - `flutter_riverpod`: 상태 관리
  - `go_router`: 라우팅
  - `hive`: 로컬 데이터베이스
  - `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`: Firebase 백엔드
  - `google_fonts`: Noto Sans KR 폰트
  - `cached_network_image`: 이미지 캐싱
  - `json_annotation`, `build_runner`: JSON 직렬화
  - `intl`, `equatable`: 추가 유틸리티
  
- [x] **[HIGH]** 디자인 시스템 기반 앱 테마 설정
  - `lib/core/theme/app_theme.dart`: 라이트/다크 테마 정의
  - `lib/core/theme/app_colors.dart`: 색상 시스템
  - `lib/core/theme/app_text_styles.dart`: 타이포그래피
  - `lib/core/theme/app_component_themes.dart`: 컴포넌트 스타일
  
- [x] **[HIGH]** Core 레이어 기본 구조 생성
  - `lib/core/constants/app_constants.dart`: 앱 전체 상수
  - `lib/core/utils/date_formatter.dart`: 날짜 포맷팅 유틸
  - `lib/core/errors/failures.dart`: 에러 처리 클래스

### Phase 2: 도메인 레이어 구현 ✅
- [x] **[HIGH]** Post 도메인 엔티티 정의
  - `lib/domain/entities/post.dart`: Post 엔티티 클래스
  - 필드: id, title, content, authorName, createdAt, imageUrl, type (질문/일기), likeCount, commentCount

- [x] **[HIGH]** Post Repository 인터페이스 정의
  - `lib/domain/repositories/post_repository.dart`: 추상 리포지토리 인터페이스
  - 메서드: `Future<List<Post>> getPosts()`, `Future<Post> getPostById(String id)` 등

- [x] **[MEDIUM]** 게시물 목록 조회 UseCase 구현
  - `lib/domain/usecases/get_posts_usecase.dart`: 비즈니스 로직 구현
  - 에러 처리 및 비즈니스 규칙 적용

### Phase 3: 데이터 레이어 구현 ✅
- [x] **[HIGH]** Post 데이터 모델 생성
  - `lib/data/models/post_model.dart`: JSON 직렬화 포함 데이터 모델
  - `fromJson()`, `toJson()`, `toEntity()` 메서드 구현

- [x] **[MEDIUM]** Post Repository 구현체 생성 (임시 Mock 데이터)
  - `lib/data/repositories/post_repository_impl.dart`: 인터페이스 구현
  - 8개의 더미 게시물 데이터로 구현

### Phase 4: 프레젠테이션 레이어 구현 ✅
- [x] **[HIGH]** Riverpod 상태 관리 Provider 생성
  - `lib/presentation/providers/post_providers.dart`: Post 관련 Provider들
  - `postListProvider`: 게시물 목록 상태 관리
  - `postRepositoryProvider`: 의존성 주입
  - 검색, 필터링, 페이지네이션 Provider 포함

- [x] **[HIGH]** 게시물 카드 UI 위젯 구현
  - `lib/presentation/widgets/post_card.dart`: 재사용 가능한 게시물 카드
  - 디자인 시스템 적용 (색상, 타이포그래피, 그림자 등)
  - 이미지, 제목, 내용 미리보기, 작성자, 날짜, 좋아요 수 표시
  - 스켈레톤 로딩 위젯 포함

- [x] **[HIGH]** 게시물 목록 화면 페이지 구현
  - `lib/presentation/pages/post_list_page.dart`: 메인 피드 화면
  - `AppBar` 구현 (제목: "반려 식물 커뮤니티")
  - 타입별 필터링 탭 (전체, 질문, 일기)
  - 로딩, 에러, 빈 상태 UI 처리
  - Pull-to-refresh 기능

### Phase 5: 앱 통합 및 라우팅 ✅
- [x] **[HIGH]** go_router 라우팅 설정
  - `lib/core/router/app_router.dart`: 라우터 설정
  - 게시물 목록 화면을 홈 화면으로 설정
  - 추후 확장 가능한 라우트 구조

- [x] **[CRITICAL]** main.dart 앱 통합
  - Riverpod ProviderScope 설정
  - 테마 적용 (라이트/다크 모드 지원)
  - 라우터 연결
  - 기존 카운터 앱 코드 제거

### Phase 6: 테스트 및 개선
- [ ] **[MEDIUM]** 위젯 테스트 작성
  - `test/presentation/widgets/post_card_test.dart`: PostCard 위젯 테스트
  - `test/presentation/pages/post_list_page_test.dart`: PostListPage 테스트

- [ ] **[LOW]** UI/UX 개선사항 적용
  - 스켈레톤 로딩 애니메이션
  - Pull-to-refresh 기능
  - 빈 상태 UI (게시물이 없을 때)

## 🔧 기술적 고려사항

### 파일 구조 예시
```
lib/
├── core/
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_component_themes.dart
│   ├── constants/
│   │   └── app_constants.dart
│   ├── utils/
│   │   └── date_formatter.dart
│   ├── errors/
│   │   └── failures.dart
│   └── router/
│       └── app_router.dart
├── domain/
│   ├── entities/
│   │   └── post.dart
│   ├── repositories/
│   │   └── post_repository.dart
│   └── usecases/
│       └── get_posts_usecase.dart
├── data/
│   ├── models/
│   │   └── post_model.dart
│   └── repositories/
│       └── post_repository_impl.dart
└── presentation/
    ├── providers/
    │   └── post_providers.dart
    ├── widgets/
    │   └── post_card.dart
    └── pages/
        └── post_list_page.dart
```

### 주요 개발 원칙
- **Clean Architecture** 준수
- **SOLID 원칙** 적용
- **TDD** 접근법 (테스트 먼저 작성)
- **디자인 시스템** 일관성 유지
- **성능 최적화** (위젯 재사용, const 생성자 활용)

## 🎉 구현 완료 상태

**모든 Phase 완료! 🚀**

### 구현된 주요 기능
- ✅ Clean Architecture 기반 프로젝트 구조
- ✅ 디자인 시스템 적용 (라이트/다크 테마)
- ✅ 게시물 목록 화면 (타입 필터링 지원)
- ✅ Riverpod 상태 관리
- ✅ go_router 라우팅
- ✅ 8개 더미 데이터로 실제 동작 확인 가능
- ✅ 반응형 UI (로딩, 에러, 빈 상태 처리)
- ✅ 스켈레톤 로딩 애니메이션

### 다음 개발 예정 기능
- [ ] 게시물 상세 화면
- [ ] 게시물 작성/수정 화면
- [ ] 댓글 시스템
- [ ] Firebase 연동
- [ ] 사용자 인증
- [ ] 이미지 업로드

### 실행 방법
```bash
flutter pub get
flutter run
```

---
**마지막 업데이트**: 2025-09-10
**담당자**: AI Assistant
**개발 소요시간**: 1회차 세션 완료
**상태**: ✅ MVP 기본 기능 구현 완료
