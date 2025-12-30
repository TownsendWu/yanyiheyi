import '../models/activity_data.dart';
import '../services/api/api_service_interface.dart';
import '../../core/network/network_result.dart';

/// 活动数据仓储
/// 负责处理活动数据相关的操作
class ActivityRepository {
  final ApiService _apiService;

  ActivityRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  /// 获取活动数据
  Future<NetworkResult<List<ActivityData>>> getActivityData({int days = 365}) async {
    try {
      return await _apiService.getActivityData(days: days);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  /// 获取统计数据
  Future<NetworkResult<Map<String, dynamic>>> getStatistics() async {
    try {
      return await _apiService.getStatistics();
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }
}
