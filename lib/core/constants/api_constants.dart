/// API 相关常量
class ApiConstants {
  ApiConstants._();

  // 基础配置
  static const String baseUrl = 'https://api.yanyiheyi.com';
  static const int connectTimeout = 15000; // 15秒
  static const int receiveTimeout = 15000; // 15秒

  // API 版本
  static const String apiVersion = '/v1';

  // 端点路径
  static const String authPath = '/auth';
  static const String userPath = '/user';
  static const String articlePath = '/articles';
  static const String activityPath = '/activity';
  static const String membershipPath = '/membership';

  // Token 相关
  static const String tokenHeaderKey = 'Authorization';
  static const String tokenPrefix = 'Bearer ';
  static const int tokenRefreshThreshold = 300; // 提前5分钟刷新token

  // 分页
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Mock 延迟（毫秒）
  static const int mockDelayMin = 300;
  static const int mockDelayMax = 800;
}
