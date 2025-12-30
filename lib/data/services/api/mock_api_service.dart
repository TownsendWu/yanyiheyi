import '../../models/article.dart';
import '../../models/user_profile.dart';
import '../../models/activity_data.dart';
import '../../models/auth_user.dart';
import '../../models/membership.dart';
import '../mock_data_service.dart';
import '../../../core/network/network_result.dart';
import '../../../core/constants/api_constants.dart';
import 'api_service_interface.dart';

/// Mock API 服务实现
/// 用于开发和测试，模拟真实的 API 调用
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
      // 使用现有的 Mock 数据服务
      final allArticles = MockDataService.generateArticleData();

      // 分页
      final start = (page - 1) * pageSize;
      final end = start + pageSize;

      if (start >= allArticles.length) {
        return Success(<Article>[]);
      }

      final articles = allArticles.sublist(
        start,
        end > allArticles.length ? allArticles.length : end,
      );

      return Success(articles);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  @override
  Future<NetworkResult<Article>> getArticleDetail(String articleId) async {
    await _delay();

    try {
      final articles = MockDataService.generateArticleData();
      final article = articles.firstWhere(
        (a) => a.id == articleId,
        orElse: () => throw NotFoundError.resource('文章'),
      );

      return Success(article);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  @override
  Future<NetworkResult<Article>> createArticle(Article article) async {
    await _delay();
    return Success(article);
  }

  @override
  Future<NetworkResult<Article>> updateArticle(Article article) async {
    await _delay();
    return Success(article);
  }

  @override
  Future<NetworkResult<void>> deleteArticle(String articleId) async {
    await _delay();
    return const Success(null);
  }

  @override
  Future<NetworkResult<void>> toggleArticlePin(String articleId, bool isPinned) async {
    await _delay();
    return const Success(null);
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
