import 'package:intl/intl.dart';
import 'package:plant_community_app/core/constants/app_constants.dart';

/// 날짜 포맷팅 관련 유틸리티 클래스
class DateFormatter {
  DateFormatter._();

  /// DateTime을 'yyyy.MM.dd' 형식으로 포맷
  static String formatDate(DateTime dateTime) {
    return DateFormat(AppConstants.dateFormat).format(dateTime);
  }

  /// DateTime을 'yyyy.MM.dd HH:mm' 형식으로 포맷
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(AppConstants.dateTimeFormat).format(dateTime);
  }

  /// 상대적 시간 표시 (예: 방금 전, 1분 전, 1시간 전, 1일 전)
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return formatDate(dateTime);
    }
  }

  /// ISO 8601 문자열을 DateTime으로 파싱
  static DateTime? parseIsoString(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    try {
      return DateTime.parse(isoString);
    } catch (e) {
      return null;
    }
  }

  /// DateTime을 ISO 8601 문자열로 변환
  static String toIsoString(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
}
