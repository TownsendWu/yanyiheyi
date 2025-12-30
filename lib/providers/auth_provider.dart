import 'package:flutter/foundation.dart';
import '../core/services/local_storage_service.dart';
import '../core/constants/storage_keys.dart';
import '../core/network/network_result.dart';
import '../data/models/auth_user.dart';
import '../data/models/membership.dart';
import '../data/services/api/api_service_interface.dart';

/// 认证状态管理 Provider
/// 负责管理用户的登录/登出状态、Token 管理和权限检查
class AuthProvider extends ChangeNotifier {
  final LocalStorageService _storage;
  final ApiService _apiService;

  AuthUser? _currentUser;
  bool _isLoading = false;
  AppError? _error;

  AuthProvider({
    required LocalStorageService storage,
    required ApiService apiService,
  })  : _storage = storage,
        _apiService = apiService {
    _initializeAuth();
  }

  // ==================== 公共状态 ====================

  /// 当前用户
  AuthUser? get currentUser => _currentUser;

  /// 是否已登录
  bool get isAuthenticated => _currentUser?.isAuthenticated ?? false;

  /// 是否为游客模式
  bool get isGuest => _currentUser?.loginType == LoginType.guest;

  /// 用户ID
  String? get userId => _currentUser?.userId;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 错误信息
  AppError? get error => _error;

  // ==================== 初始化 ====================

  /// 初始化认证状态
  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 从本地存储加载用户信息
      final userJson = _storage.getStringSync(StorageKeys.authUser);
      if (userJson != null) {
        // TODO: 解析 JSON 并创建 AuthUser
        // _currentUser = AuthUser.fromJson(jsonDecode(userJson));
      }

      // 如果没有用户信息，创建游客用户
      if (_currentUser == null) {
        _currentUser = AuthUser.guest();
        await _saveAuthUser();
      }

      // 检查 Token 是否需要刷新
      if (_currentUser?.needsTokenRefresh ?? false) {
        await _refreshToken();
      }
    } catch (e) {
      _error = AppErrorFactory.fromException(e);
      _currentUser = AuthUser.guest();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== 登录方法 ====================

  /// 微信登录
  Future<bool> loginWithWechat() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: 调用微信 SDK 获取 code
      const code = 'mock_wechat_code';

      final result = await _apiService.loginWithWechat(code);

      if (result.isSuccess) {
        _currentUser = result.getData?.user;
        await _saveAuthUser();
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

  /// 抖音登录
  Future<bool> loginWithDouyin() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: 调用抖音 SDK 获取 code
      const code = 'mock_douyin_code';

      final result = await _apiService.loginWithDouyin(code);

      if (result.isSuccess) {
        _currentUser = result.getData?.user;
        await _saveAuthUser();
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

  /// 继续以游客身份使用
  Future<void> continueAsGuest() async {
    _currentUser = AuthUser.guest();
    await _saveAuthUser();
    notifyListeners();
  }

  // ==================== 登出方法 ====================

  /// 登出
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 调用登出 API
      if (_currentUser?.isAuthenticated ?? false) {
        await _apiService.logout(_currentUser!.userId);
      }

      // 清除本地数据
      await _storage.remove(StorageKeys.authUser);
      await _storage.remove(StorageKeys.accessToken);
      await _storage.remove(StorageKeys.refreshToken);
      await _storage.remove(StorageKeys.tokenExpiresAt);

      // 重置为游客用户
      _currentUser = AuthUser.guest();
    } catch (e) {
      _error = AppErrorFactory.fromException(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== Token 管理 ====================

  /// 刷新 Token
  Future<void> _refreshToken() async {
    if (_currentUser?.refreshToken == null) return;

    try {
      final result = await _apiService.refreshToken(_currentUser!.refreshToken!);
      if (result.isSuccess) {
        _currentUser = result.getData;
        await _saveAuthUser();
      } else {
        // Token 刷新失败，需要重新登录
        await logout();
      }
    } catch (e) {
      _error = AppErrorFactory.fromException(e);
      await logout();
    }
  }

  /// 确保Token有效（在需要认证的操作前调用）
  Future<bool> ensureAuth() async {
    if (_currentUser == null || !_currentUser!.isAuthenticated) {
      return false;
    }

    if (_currentUser!.needsTokenRefresh) {
      await _refreshToken();
    }

    return _currentUser!.isTokenValid;
  }

  // ==================== 权限检查 ====================

  /// 检查是否已登录
  bool requireAuth() {
    return isAuthenticated;
  }

  /// 检查是否有某项权限
  bool checkPermission(Permission permission, Membership? membership) {
    // 游客只能使用免费功能
    if (isGuest) {
      return permission.isFree;
    }

    // 已登录用户，根据会员等级判断
    if (membership != null && membership.isValid) {
      return membership.level.hasPermission(permission);
    }

    // 没有会员信息，只能使用免费功能
    return permission.isFree;
  }

  // ==================== 私有辅助方法 ====================

  /// 保存用户信息到本地
  Future<void> _saveAuthUser() async {
    if (_currentUser == null) return;

    // 保存用户信息 JSON
    // await _storage.setJson(StorageKeys.authUser, _currentUser!.toJson());

    // 保存 Token 相关信息
    await _storage.setAccessToken(_currentUser!.accessToken);
    await _storage.setRefreshToken(_currentUser!.refreshToken);
    await _storage.setTokenExpiresAt(_currentUser!.tokenExpiresAt);
  }
}
