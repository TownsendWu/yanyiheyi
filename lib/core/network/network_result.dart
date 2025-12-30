/// 网络请求结果封装
/// 用于统一处理成功、失败和加载状态
sealed class NetworkResult<T> {
  const NetworkResult();

  /// 是否成功
  bool get isSuccess => this is Success<T>;

  /// 是否失败
  bool get isFailure => this is Failure<T>;

  /// 是否加载中
  bool get isLoading => this is Loading<T>;

  /// 获取数据（仅在成功时有效）
  T? get getData {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    }
    return null;
  }

  /// 获取错误（仅在失败时有效）
  AppError? get getError {
    if (this is Failure<T>) {
      return (this as Failure<T>).error;
    }
    return null;
  }
}

/// 请求成功
class Success<T> extends NetworkResult<T> {
  final T data;
  const Success(this.data);
}

/// 请求失败
class Failure<T> extends NetworkResult<T> {
  final AppError error;
  const Failure(this.error);
}

/// 请求加载中
class Loading<T> extends NetworkResult<T> {
  const Loading();
}

/// 应用错误模型
/// 统一的错误类型定义
sealed class AppError {
  final String message;
  final int? code;
  final dynamic originalError;

  const AppError({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppError: $message${code != null ? ' (code: $code)' : ''}';
}

/// 网络错误
class NetworkError extends AppError {
  const NetworkError({
    required super.message,
    super.code,
    super.originalError,
  });

  factory NetworkError.timeout([dynamic originalError]) {
    return NetworkError(
      message: '网络请求超时，请检查网络连接',
      code: -1,
      originalError: originalError,
    );
  }

  factory NetworkError.noConnection([dynamic originalError]) {
    return NetworkError(
      message: '网络连接失败，请检查网络设置',
      code: -2,
      originalError: originalError,
    );
  }

  factory NetworkError.serverError([dynamic originalError]) {
    return NetworkError(
      message: '服务器错误，请稍后重试',
      code: -3,
      originalError: originalError,
    );
  }
}

/// 认证错误
class AuthError extends AppError {
  const AuthError({
    required super.message,
    super.code,
    super.originalError,
  });

  factory AuthError.tokenExpired([dynamic originalError]) {
    return AuthError(
      message: '登录已过期，请重新登录',
      code: 401,
      originalError: originalError,
    );
  }

  factory AuthError.unauthorized([dynamic originalError]) {
    return AuthError(
      message: '未登录或登录失效',
      code: 401,
      originalError: originalError,
    );
  }

  factory AuthError.loginFailed([dynamic originalError]) {
    return AuthError(
      message: '登录失败，请稍后重试',
      code: 402,
      originalError: originalError,
    );
  }
}

/// 验证错误
class ValidationError extends AppError {
  final String? field;

  const ValidationError({
    required super.message,
    this.field,
    super.code,
    super.originalError,
  });

  factory ValidationError.required(String field) {
    return ValidationError(
      message: '$field 不能为空',
      field: field,
    );
  }

  factory ValidationError.invalid(String field, [String? detail]) {
    return ValidationError(
      message: detail ?? '$field 格式不正确',
      field: field,
    );
  }
}

/// 未找到错误
class NotFoundError extends AppError {
  const NotFoundError({
    required super.message,
    super.code,
    super.originalError,
  });

  factory NotFoundError.resource(String resource) {
    return NotFoundError(
      message: '未找到 $resource',
    );
  }
}

/// 会员权限错误
class MembershipError extends AppError {
  const MembershipError({
    required super.message,
    super.code,
    super.originalError,
  });

  factory MembershipError.notMember() {
    return const MembershipError(
      message: '此功能需要会员权限',
      code: 403,
    );
  }

  factory MembershipError.expired() {
    return const MembershipError(
      message: '会员已过期，请续费',
      code: 403,
    );
  }
}

/// 未知错误
class UnknownError extends AppError {
  const UnknownError({
    super.message = '未知错误，请稍后重试',
    super.code,
    super.originalError,
  });

  factory UnknownError.fromException(dynamic exception) {
    return UnknownError(
      message: '发生错误: ${exception.toString()}',
      originalError: exception,
    );
  }
}

/// 错误工厂
/// 用于将异常转换为 AppError
class AppErrorFactory {
  static AppError fromException(dynamic exception) {
    if (exception is AppError) {
      return exception;
    }

    if (exception is Exception) {
      final message = exception.toString();
      if (message.contains('timeout') || message.contains('TimeoutException')) {
        return NetworkError.timeout(exception);
      }
      if (message.contains('connection') || message.contains('SocketException')) {
        return NetworkError.noConnection(exception);
      }
    }

    return UnknownError.fromException(exception);
  }
}
