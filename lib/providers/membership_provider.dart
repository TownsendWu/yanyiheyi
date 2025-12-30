import 'package:flutter/foundation.dart';
import '../core/services/local_storage_service.dart';
import '../core/constants/storage_keys.dart';
import '../core/network/network_result.dart';
import '../data/models/membership.dart';
import '../data/services/api/api_service_interface.dart';

/// 会员状态管理 Provider
/// 负责管理用户的会员状态和订阅信息
class MembershipProvider extends ChangeNotifier {
  final LocalStorageService _storage;
  final ApiService _apiService;

  Membership? _membership;
  bool _isLoading = false;
  AppError? _error;

  MembershipProvider({
    required LocalStorageService storage,
    required ApiService apiService,
  })  : _storage = storage,
        _apiService = apiService;

  // ==================== 公共状态 ====================

  /// 会员信息
  Membership? get membership => _membership;

  /// 是否为有效会员
  bool get isValidMember => _membership?.isValid ?? false;

  /// 是否为付费会员
  bool get isPaidMember => _membership?.isPaidMember ?? false;

  /// 会员等级
  MembershipLevel get level => _membership?.level ?? MembershipLevel.free;

  /// 剩余天数
  int get remainingDays => _membership?.remainingDays ?? 0;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 错误信息
  AppError? get error => _error;

  // ==================== 加载数据 ====================

  /// 加载会员状态
  Future<void> loadMembership(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.getMembershipStatus(userId);

      if (result.isSuccess) {
        _membership = result.getData;
        await _saveMembership();
      } else {
        _error = result.getError;
        // 加载失败时设置为免费用户
        _membership = Membership.free(userId);
      }
    } catch (e) {
      _error = AppErrorFactory.fromException(e);
      _membership = Membership.free(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== 订阅管理 ====================

  /// 创建订阅
  Future<bool> createSubscription({
    required MembershipLevel level,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.createSubscription(
        level: level,
        paymentMethod: paymentMethod,
      );

      if (result.isSuccess) {
        _membership = result.getData;
        await _saveMembership();
        return true;
      } else {
        _error = result.getError;
        return false;
      }
    } catch (e) {
      _error = AppErrorFactory.fromException(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 取消订阅
  Future<bool> cancelSubscription() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_membership?.userId == null) {
        _error = const ValidationError(message: '用户未登录');
        return false;
      }

      final result = await _apiService.cancelSubscription(_membership!.userId);

      if (result.isSuccess) {
        // 取消订阅后，保留会员状态直到到期
        if (_membership != null) {
          _membership = _membership!.copyWith(isActive: false);
          await _saveMembership();
        }
        return true;
      } else {
        _error = result.getError;
        return false;
      }
    } catch (e) {
      _error = AppErrorFactory.fromException(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 续费会员
  Future<bool> renewMembership({
    required String userId,
    required MembershipLevel level,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.renewMembership(
        userId: userId,
        level: level,
      );

      if (result.isSuccess) {
        _membership = result.getData;
        await _saveMembership();
        return true;
      } else {
        _error = result.getError;
        return false;
      }
    } catch (e) {
      _error = AppErrorFactory.fromException(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== 权限检查 ====================

  /// 检查是否有某项权限
  bool checkPermission(Permission permission) {
    if (_membership == null) return false;
    return _membership!.level.hasPermission(permission);
  }

  /// 检查是否有某项权限（如果没有，返回错误信息）
  String? validatePermission(Permission permission) {
    if (_membership == null) {
      return '请先登录';
    }

    if (!_membership!.isValid) {
      return '会员已过期，请续费';
    }

    if (!_membership!.level.hasPermission(permission)) {
      return '此功能需要 ${_displayNameForLevel(_membership!.level)} 权限';
    }

    return null;
  }

  // ==================== 私有辅助方法 ====================

  /// 保存会员信息到本地
  Future<void> _saveMembership() async {
    if (_membership == null) return;
    await _storage.setJson(StorageKeys.membershipStatus, _membership!.toJson());
  }

  /// 从本地加载会员信息
  Future<void> _loadMembershipFromStorage() async {
    final json = await _storage.getJson(
      StorageKeys.membershipStatus,
      (json) => Membership.fromJson(json),
    );
    if (json != null) {
      _membership = json;
      notifyListeners();
    }
  }

  /// 获取等级显示名称
  String _displayNameForLevel(MembershipLevel level) {
    return level.displayName;
  }
}
