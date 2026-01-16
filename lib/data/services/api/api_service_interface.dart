import '../../models/article.dart';
import '../../models/user_profile.dart';
import '../../models/activity_data.dart';
import '../../models/auth_user.dart';
import '../../models/membership.dart';
import '../../../core/network/network_result.dart';
import 'mock_api_service.dart';

/// API 服务接口
/// 定义所有 API 调用的抽象接口
abstract class ApiService {
  // ==================== 认证相关 ====================

  /// 微信登录
  Future<NetworkResult<LoginResult>> loginWithWechat(String code);

  /// 抖音登录
  Future<NetworkResult<LoginResult>> loginWithDouyin(String code);

  /// 手机号登录
  Future<NetworkResult<LoginResult>> loginWithPhone(String phone, String code);

  /// 发送验证码
  Future<NetworkResult<void>> sendVerificationCode(String phone);

  /// 刷新 Token
  Future<NetworkResult<AuthUser>> refreshToken(String refreshToken);

  /// 登出
  Future<NetworkResult<void>> logout(String userId);

  // ==================== 用户相关 ====================

  /// 获取用户信息
  Future<NetworkResult<UserProfile>> getUserProfile(String userId);

  /// 更新用户信息
  Future<NetworkResult<UserProfile>> updateUserProfile(UserProfile profile);

  /// 上传用户头像
  Future<NetworkResult<String>> uploadUserAvatar(String userId, String filePath);

  // ==================== 文章相关 ====================

  /// 获取文章列表
  /// [page] 页码（从1开始）
  /// [pageSize] 每页数量
  /// [tags] 标签过滤（可选）
  Future<NetworkResult<List<Article>>> getArticles({
    required int page,
    required int pageSize,
    List<String>? tags,
  });

  /// 获取文章详情
  Future<NetworkResult<Article>> getArticleDetail(String articleId);

  /// 创建文章
  Future<NetworkResult<Article>> createArticle(Article article);

  /// 更新文章
  Future<NetworkResult<Article>> updateArticle(Article article);

  /// 删除文章
  Future<NetworkResult<void>> deleteArticle(String articleId);

  /// 置顶/取消置顶文章
  Future<NetworkResult<void>> toggleArticlePin(String articleId, bool isPinned);

  // ==================== 活动数据相关 ====================

  /// 获取活动数据
  /// [days] 获取最近多少天的数据
  Future<NetworkResult<List<ActivityData>>> getActivityData({int days = 365});

  /// 获取统计数据
  Future<NetworkResult<Map<String, dynamic>>> getStatistics();

  // ==================== 会员相关 ====================

  /// 获取会员状态
  Future<NetworkResult<Membership>> getMembershipStatus(String userId);

  /// 创建订阅
  /// [level] 会员等级
  /// [paymentMethod] 支付方式
  Future<NetworkResult<Membership>> createSubscription({
    required MembershipLevel level,
    required String paymentMethod,
  });

  /// 取消订阅
  Future<NetworkResult<void>> cancelSubscription(String userId);

  /// 续费会员
  Future<NetworkResult<Membership>> renewMembership({
    required String userId,
    required MembershipLevel level,
  });
}

/// API 服务工厂
/// 用于创建不同实现的 API 服务
class ApiServiceFactory {
  static ApiService? _instance;

  /// 获取 API 服务实例
  static ApiService getInstance() {
    _instance ??= _createMockService();
    return _instance!;
  }

  /// 设置自定义 API 服务
  static void setService(ApiService service) {
    _instance = service;
  }

  /// 创建 Mock 服务
  static ApiService _createMockService() {
    return MockApiService();
  }

  /// 重置服务
  static void reset() {
    _instance = null;
  }
}
