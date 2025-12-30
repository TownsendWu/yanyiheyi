import '../models/auth_user.dart';
import '../services/api/api_service_interface.dart';
import '../../core/network/network_result.dart';

/// 认证仓储
/// 负责处理认证相关的数据操作
class AuthRepository {
  final ApiService _apiService;

  AuthRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  /// 微信登录
  Future<NetworkResult<LoginResult>> loginWithWechat(String code) async {
    try {
      return await _apiService.loginWithWechat(code);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  /// 抖音登录
  Future<NetworkResult<LoginResult>> loginWithDouyin(String code) async {
    try {
      return await _apiService.loginWithDouyin(code);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  /// 刷新 Token
  Future<NetworkResult<AuthUser>> refreshToken(String refreshToken) async {
    try {
      return await _apiService.refreshToken(refreshToken);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  /// 登出
  Future<NetworkResult<void>> logout(String userId) async {
    try {
      return await _apiService.logout(userId);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }
}
