/// 앱에서 발생할 수 있는 에러를 추상화한 기본 클래스
abstract class Failure {
  const Failure(this.message);
  
  final String message;

  @override
  String toString() => message;
}

/// 서버 관련 에러
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// 네트워크 연결 에러
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// 캐시 관련 에러
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// 유효하지 않은 입력 에러
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// 권한 관련 에러
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// 데이터를 찾을 수 없는 에러
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// 알 수 없는 에러
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

/// 결과를 나타내는 클래스 (Success 또는 Failure)
sealed class Result<T> {
  const Result();
}

/// 성공 결과
class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

/// 실패 결과
class Error<T> extends Result<T> {
  const Error(this.failure);
  final Failure failure;
}

/// Result 확장 메서드
extension ResultExtensions<T> on Result<T> {
  /// 성공 여부 확인
  bool get isSuccess => this is Success<T>;
  
  /// 실패 여부 확인
  bool get isError => this is Error<T>;
  
  /// 성공 데이터 가져오기 (null 안전)
  T? get data => isSuccess ? (this as Success<T>).data : null;
  
  /// 실패 정보 가져오기 (null 안전)
  Failure? get failure => isError ? (this as Error<T>).failure : null;
  
  /// fold 패턴으로 결과 처리
  R fold<R>(
    R Function(Failure failure) onError,
    R Function(T data) onSuccess,
  ) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      Error<T>(:final failure) => onError(failure),
    };
  }
}
