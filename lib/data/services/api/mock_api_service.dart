import '../../models/article.dart';
import '../../models/user_profile.dart';
import '../../models/activity_data.dart';
import '../../models/auth_user.dart';
import '../../models/membership.dart';
import '../mock_data_service.dart';
import '../../../core/network/network_result.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/logger/app_logger.dart';
import 'api_service_interface.dart';

/// Mock API 服务实现
/// 用于开发和测试，模拟真实的 API 调用
/// 注意：此服务不操作本地存储，只记录日志
class MockApiService implements ApiService {

  /// 模拟网络延迟
  Future<void> _delay() async {
    final delay = ApiConstants.mockDelayMin +
        (DateTime.now().millisecond % (ApiConstants.mockDelayMax - ApiConstants.mockDelayMin));
    await Future.delayed(Duration(milliseconds: delay));
  }

  // ==================== 认证相关 ====================

  @override
  Future<NetworkResult<LoginResult>> loginWithWechat(String code) async {
    await _delay();

    try {
      // 模拟微信登录成功
      final user = AuthUser.authenticated(
        userId: 'wechat_user_${DateTime.now().millisecondsSinceEpoch}',
        accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token',
        tokenExpiresAt: DateTime.now().add(const Duration(days: 30)),
        loginType: LoginType.wechat,
      );

      return Success(LoginResult.success(user));
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  @override
  Future<NetworkResult<LoginResult>> loginWithDouyin(String code) async {
    await _delay();

    try {
      // 模拟抖音登录成功
      final user = AuthUser.authenticated(
        userId: 'douyin_user_${DateTime.now().millisecondsSinceEpoch}',
        accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token',
        tokenExpiresAt: DateTime.now().add(const Duration(days: 30)),
        loginType: LoginType.douyin,
      );

      return Success(LoginResult.success(user));
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  @override
  Future<NetworkResult<LoginResult>> loginWithPhone(String phone, String code) async {
    await _delay();

    try {
      // 模拟手机号登录成功
      final user = AuthUser.authenticated(
        userId: 'phone_user_${DateTime.now().millisecondsSinceEpoch}',
        accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token',
        tokenExpiresAt: DateTime.now().add(const Duration(days: 30)),
        loginType: LoginType.phone,
      );

      return Success(LoginResult.success(user));
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  @override
  Future<NetworkResult<void>> sendVerificationCode(String phone) async {
    await _delay();

    try {
      // 模拟发送验证码成功
      appLogger.logRequest('POST', '/api/auth/sms/send', body: {
        'phone': phone,
      });

      appLogger.logResponse('/api/auth/sms/send', 200, data: {
        'message': '验证码已发送',
      });

      return const Success(null);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  @override
  Future<NetworkResult<AuthUser>> refreshToken(String refreshToken) async {
    await _delay();

    try {
      final user = AuthUser.authenticated(
        userId: 'refreshed_user',
        accessToken: 'new_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: refreshToken,
        tokenExpiresAt: DateTime.now().add(const Duration(days: 30)),
        loginType: LoginType.wechat,
      );

      return Success(user);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  @override
  Future<NetworkResult<void>> logout(String userId) async {
    await _delay();
    return const Success(null);
  }

  // ==================== 用户相关 ====================

  @override
  Future<NetworkResult<UserProfile>> getUserProfile(String userId) async {
    await _delay();

    try {
      final profile = UserProfile(
        nickname: '测试用户',
        email: 'test@example.com',
        bio: '这是测试用户简介',
      );

      return Success(profile);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  @override
  Future<NetworkResult<UserProfile>> updateUserProfile(UserProfile profile) async {
    await _delay();
    return Success(profile);
  }

  @override
  Future<NetworkResult<String>> uploadUserAvatar(String userId, String filePath) async {
    await _delay();
    return Success('https://example.com/avatar/$userId.jpg');
  }

  // ==================== 文章相关 ====================

  @override
  Future<NetworkResult<List<Article>>> getArticles({
    required int page,
    required int pageSize,
    List<String>? tags,
  }) async {
    await _delay();

    try {
      // 模拟从服务器获取文章列表
      appLogger.logRequest('GET', '/api/articles', body: {
        'page': page,
        'pageSize': pageSize,
        'tags': tags,
      });

      // ✅ 返回测试数据（用于测试同步逻辑）
      final mockArticles = await MockDataService.generateArticleData();

      appLogger.logResponse('/api/articles', 200, data: {
        'count': mockArticles.length,
        'page': page,
        'pageSize': pageSize,
      });

      return Success(mockArticles);
    } catch (e) {
      appLogger.logNetworkError('/api/articles', e.toString());
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  @override
  Future<NetworkResult<Article>> getArticleDetail(String articleId) async {
    await _delay();

    try {
      // 模拟从服务器获取文章详情
      appLogger.logRequest('GET', '/api/articles/$articleId');

      // 返回空文章（本地已经有数据）
      final mockArticle = Article(
        id: articleId,
        title: '',
        date: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      appLogger.logResponse('/api/articles/$articleId', 200);

      return Success(mockArticle);
    } catch (e) {
      appLogger.logNetworkError('/api/articles/$articleId', e.toString());
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  @override
  Future<NetworkResult<Article>> createArticle(Article article) async {
    await _delay();
    try {
      // 模拟向服务器创建文章
      appLogger.logRequest('POST', '/api/articles', body: {
        'id': article.id,
        'title': article.title,
        'date': article.date.toIso8601String(),
      });

      appLogger.logResponse('/api/articles', 201, data: {
        'id': article.id,
      });

      return Success(article);
    } catch (e) {
      appLogger.logNetworkError('/api/articles', e.toString());
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  @override
  Future<NetworkResult<Article>> updateArticle(Article article) async {
    await _delay();
    try {
      // 模拟向服务器更新文章
      appLogger.logRequest('PUT', '/api/articles/${article.id}', body: {
        'id': article.id,
        'title': article.title,
        'updatedAt': article.updatedAt?.toIso8601String(),
      });

      appLogger.logResponse('/api/articles/${article.id}', 200);

      return Success(article);
    } catch (e) {
      appLogger.logNetworkError('/api/articles/${article.id}', e.toString());
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  @override
  Future<NetworkResult<void>> deleteArticle(String articleId) async {
    await _delay();
    try {
      // 模拟向服务器删除文章
      appLogger.logRequest('DELETE', '/api/articles/$articleId');

      appLogger.logResponse('/api/articles/$articleId', 204);

      return const Success(null);
    } catch (e) {
      appLogger.logNetworkError('/api/articles/$articleId', e.toString());
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  @override
  Future<NetworkResult<void>> toggleArticlePin(String articleId, bool isPinned) async {
    await _delay();
    try {
      // 模拟向服务器切换文章置顶状态
      appLogger.logRequest('PATCH', '/api/articles/$articleId/pin', body: {
        'isPinned': isPinned,
      });

      appLogger.logResponse('/api/articles/$articleId/pin', 200);

      return const Success(null);
    } catch (e) {
      appLogger.logNetworkError('/api/articles/$articleId/pin', e.toString());
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  // ==================== 活动数据相关 ====================

  @override
  Future<NetworkResult<List<ActivityData>>> getActivityData({int days = 365}) async {
    await _delay();

    try {
      final activities = MockDataService.generateActivityData();
      return Success(activities);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> getStatistics() async {
    await _delay();

    try {
      final stats = {
        'totalArticles': 42,
        'totalWords': 125000,
        'continuousDays': 15,
        'longestStreak': 30,
      };

      return Success(stats);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  // ==================== 会员相关 ====================

  @override
  Future<NetworkResult<Membership>> getMembershipStatus(String userId) async {
    await _delay();

    try {
      // 返回免费会员
      final membership = Membership.free(userId);
      return Success(membership);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  @override
  Future<NetworkResult<Membership>> createSubscription({
    required MembershipLevel level,
    required String paymentMethod,
  }) async {
    await _delay();

    try {
      final membership = Membership.paid(
        userId: 'test_user',
        level: level,
        startDate: DateTime.now(),
        expiryDate: DateTime.now().add(
          level == MembershipLevel.yearly
              ? const Duration(days: 365)
              : const Duration(days: 30),
        ),
      );

      return Success(membership);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  @override
  Future<NetworkResult<void>> cancelSubscription(String userId) async {
    await _delay();
    return const Success(null);
  }

  @override
  Future<NetworkResult<Membership>> renewMembership({
    required String userId,
    required MembershipLevel level,
  }) async {
    await _delay();

    try {
      final membership = Membership.paid(
        userId: userId,
        level: level,
        startDate: DateTime.now(),
        expiryDate: DateTime.now().add(
          level == MembershipLevel.yearly
              ? const Duration(days: 365)
              : const Duration(days: 30),
        ),
      );

      return Success(membership);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }
}
