import '../models/membership.dart';
import '../services/api/api_service_interface.dart';
import '../../core/network/network_result.dart';

/// 会员仓储
/// 负责处理会员相关的数据操作
class MembershipRepository {
  final ApiService _apiService;

  MembershipRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  /// 获取会员状态
  Future<NetworkResult<Membership>> getMembershipStatus(String userId) async {
    try {
      return await _apiService.getMembershipStatus(userId);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  /// 创建订阅
  Future<NetworkResult<Membership>> createSubscription({
    required MembershipLevel level,
    required String paymentMethod,
  }) async {
    try {
      return await _apiService.createSubscription(
        level: level,
        paymentMethod: paymentMethod,
      );
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  /// 取消订阅
  Future<NetworkResult<void>> cancelSubscription(String userId) async {
    try {
      return await _apiService.cancelSubscription(userId);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  /// 续费会员
  Future<NetworkResult<Membership>> renewMembership({
    required String userId,
    required MembershipLevel level,
  }) async {
    try {
      return await _apiService.renewMembership(
        userId: userId,
        level: level,
      );
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }
}
