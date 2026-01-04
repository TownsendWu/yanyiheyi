import 'package:talker_flutter/talker_flutter.dart';

/// 应用日志管理类
/// 封装了 talker，提供统一的日志接口
class AppLogger {
  // 私有构造函数，确保单例
  AppLogger._internal();

  static final AppLogger _instance = AppLogger._internal();

  factory AppLogger() => _instance;

  // Talker 实例
  late final Talker _talker;

  /// 初始化日志系统
  void init() {
    _talker = TalkerFlutter.init();
  }

  /// 获取 Talker 实例（用于访问 TalkerScreen）
  Talker get talker => _talker;

  /// Info 级别日志
  /// 用于记录一般信息
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _talker.info(message, error, stackTrace);
  }

  /// Debug 级别日志
  /// 用于记录调试信息
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _talker.debug(message, error, stackTrace);
  }

  /// Warning 级别日志
  /// 用于记录警告信息
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _talker.warning(message, error, stackTrace);
  }

  /// Error 级别日志
  /// 用于记录错误信息
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _talker.error(message, error, stackTrace);
  }

  /// Verbose 级别日志
  /// 用于记录详细的调试信息
  void verbose(String message, [Object? error, StackTrace? stackTrace]) {
    _talker.verbose(message, error, stackTrace);
  }

  /// Exception 级别日志
  /// 用于记录异常
  void exception(String message, Object exception, [StackTrace? stackTrace]) {
    _talker.handle(
      exception,
      stackTrace,
      message,
    );
  }

  /// 添加面包屑（用户行为轨迹）
  void breadcrumb(String message) {
    _talker.info('📍 $message');
  }

  /// 记录关键操作
  void logAction(String action, Map<String, dynamic>? data) {
    final dataStr = data != null ? ' | $data' : '';
    _talker.info('⚡ $action$dataStr');
  }

  /// 记录网络请求
  void logRequest(String method, String url, {Map<String, dynamic>? body}) {
    final bodyStr = body != null ? '\nBody: $body' : '';
    _talker.info('🌐 $method $url$bodyStr');
  }

  /// 记录网络响应
  void logResponse(String url, int statusCode, {dynamic data}) {
    final dataStr = data != null ? '\nData: $data' : '';
    _talker.info('✅ Response $statusCode - $url$dataStr');
  }

  /// 记录网络错误
  void logNetworkError(String url, String error) {
    _talker.error('❌ Network Error - $url\n$error');
  }

  /// 记录用户操作
  void logUserAction(String action) {
    _talker.info('👤 User: $action');
  }

  /// 记录性能指标
  void logPerformance(String operation, Duration duration) {
    _talker.info('⏱️ $operation took ${duration.inMilliseconds}ms');
  }
}

/// 全局日志实例
final appLogger = AppLogger();

