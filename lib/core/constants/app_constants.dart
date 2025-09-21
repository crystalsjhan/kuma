/// 앱 전체에서 사용되는 상수값들을 정의하는 클래스
class AppConstants {
  AppConstants._();

  // 앱 정보
  static const String appName = '반려 식물 커뮤니티';
  static const String appVersion = '1.0.0';

  // API 관련 상수 (추후 Firebase 연동 시 사용)
  static const String baseUrl = 'https://api.plantcommunity.com';
  static const int apiTimeoutSeconds = 30;

  // 페이지네이션 관련
  static const int postsPerPage = 10;
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB

  // 게시물 관련
  static const int maxTitleLength = 100;
  static const int maxContentLength = 2000;
  static const int contentPreviewLength = 150;

  // 캐시 관련
  static const Duration cacheExpiry = Duration(minutes: 15);
  static const String postsCacheKey = 'cached_posts';

  // 이미지 관련
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];
  static const double imageQuality = 0.8;

  // 날짜 포맷
  static const String dateFormat = 'yyyy.MM.dd';
  static const String dateTimeFormat = 'yyyy.MM.dd HH:mm';

  // 에러 메시지
  static const String networkErrorMessage = '네트워크 연결을 확인해주세요.';
  static const String unknownErrorMessage = '알 수 없는 오류가 발생했습니다.';
  static const String noDataMessage = '데이터가 없습니다.';

  // 게시물 타입
  static const String postTypeQuestion = 'question';
  static const String postTypeDiary = 'diary';
}

