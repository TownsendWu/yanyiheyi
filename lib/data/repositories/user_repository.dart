import '../models/user_profile.dart';
import '../services/api/api_service_interface.dart';
import '../../core/network/network_result.dart';

/// 用户仓储
/// 负责处理用户相关的数据操作
class UserRepository {
  final ApiService _apiService;

  UserRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  /// 获取用户信息
  Future<NetworkResult<UserProfile>> getUserProfile(String userId) async {
    try {
      return await _apiService.getUserProfile(userId);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  /// 更新用户信息
  Future<NetworkResult<UserProfile>> updateUserProfile(UserProfile profile) async {
    try {
      return await _apiService.updateUserProfile(profile);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  /// 上传用户头像
  Future<NetworkResult<String>> uploadUserAvatar(String userId, String filePath) async {
    try {
      return await _apiService.uploadUserAvatar(userId, filePath);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }
}
