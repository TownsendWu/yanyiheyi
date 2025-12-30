import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';

/// 统一的本地存储服务
/// 封装 SharedPreferences，提供类型安全的存储方法
class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService._(this._prefs);

  /// 单例实例
  static LocalStorageService? _instance;

  /// 初始化
  static Future<LocalStorageService> getInstance() async {
    _instance ??= LocalStorageService._(await SharedPreferences.getInstance());
    return _instance!;
  }

  /// 获取实例（必须在初始化后调用）
  static LocalStorageService get instance {
    if (_instance == null) {
      throw StateError('LocalStorageService must be initialized first. Call getInstance() before using instance.');
    }
    return _instance!;
  }

  // ==================== 字符串存储 ====================

  /// 保存字符串
  Future<void> setString(String key, String? value) async {
    if (value == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setString(key, value);
    }
  }

  /// 获取字符串
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  /// 同步获取字符串
  String? getStringSync(String key) {
    return _prefs.getString(key);
  }

  // ==================== 整数存储 ====================

  /// 保存整数
  Future<void> setInt(String key, int? value) async {
    if (value == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setInt(key, value);
    }
  }

  /// 获取整数
  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  /// 同步获取整数
  int? getIntSync(String key) {
    return _prefs.getInt(key);
  }

  // ==================== 布尔存储 ====================

  /// 保存布尔值
  Future<void> setBool(String key, bool? value) async {
    if (value == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setBool(key, value);
    }
  }

  /// 获取布尔值
  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  /// 同步获取布尔值
  bool? getBoolSync(String key) {
    return _prefs.getBool(key);
  }

  // ==================== 双精度存储 ====================

  /// 保存双精度浮点数（以字符串形式存储）
  Future<void> setDouble(String key, double? value) async {
    if (value == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setDouble(key, value);
    }
  }

  /// 获取双精度浮点数
  Future<double?> getDouble(String key) async {
    return _prefs.getDouble(key);
  }

  /// 同步获取双精度浮点数
  double? getDoubleSync(String key) {
    return _prefs.getDouble(key);
  }

  // ==================== 字符串列表存储 ====================

  /// 保存字符串列表
  Future<void> setStringList(String key, List<String>? value) async {
    if (value == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setStringList(key, value);
    }
  }

  /// 获取字符串列表
  Future<List<String>?> getStringList(String key) async {
    return _prefs.getStringList(key);
  }

  /// 同步获取字符串列表
  List<String>? getStringListSync(String key) {
    return _prefs.getStringList(key);
  }

  // ==================== JSON 对象存储 ====================

  /// 保存 JSON 对象
  /// 对象需要实现 toJson() 方法
  Future<void> setJson<T>(String key, T? item) async {
    if (item == null) {
      await _prefs.remove(key);
    } else {
      final json = _encodeJson(item);
      await _prefs.setString(key, json);
    }
  }

  /// 获取 JSON 对象
  /// 泛型 `T` 需要提供 fromJson(Map<String, dynamic>) 构造函数
  Future<T?> getJson<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(json);
    } catch (e) {
      // 解析失败，删除损坏的数据
      await remove(key);
      return null;
    }
  }

  /// 同步获取 JSON 对象
  T? getJsonSync<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// 保存 JSON 对象列表
  Future<void> setJsonList<T>(String key, List<T>? items) async {
    if (items == null || items.isEmpty) {
      await _prefs.remove(key);
    } else {
      final jsonList = items.map((item) => _encodeJson(item)).toList();
      await _prefs.setStringList(key, jsonList);
    }
  }

  /// 获取 JSON 对象列表
  Future<List<T>> getJsonList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final jsonStringList = _prefs.getStringList(key);
    if (jsonStringList == null || jsonStringList.isEmpty) {
      return [];
    }

    final result = <T>[];
    for (final jsonString in jsonStringList) {
      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        result.add(fromJson(json));
      } catch (e) {
        // 跳过解析失败的项目
        continue;
      }
    }
    return result;
  }

  // ==================== 通用操作 ====================

  /// 检查键是否存在
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  /// 删除指定键
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  /// 清空所有数据
  Future<void> clear() async {
    await _prefs.clear();
  }

  /// 获取所有键
  Set<String> getKeys() {
    return _prefs.getKeys();
  }

  // ==================== 私有辅助方法 ====================

  /// 编码对象为 JSON 字符串
  String _encodeJson<T>(T item) {
    if (item is Map<String, dynamic>) {
      return jsonEncode(item);
    }
    // 假设对象有 toJson 方法
    final method = (item as dynamic).toJson;
    if (method is Function) {
      return jsonEncode(method());
    }
    throw ArgumentError('Object must implement toJson() method or be a Map');
  }

  // ==================== 便捷方法（使用预定义键）====================

  /// 认证相关快捷方法
  Future<void> setAccessToken(String? token) => setString(StorageKeys.accessToken, token);
  Future<String?> getAccessToken() => getString(StorageKeys.accessToken);
  String? getAccessTokenSync() => getStringSync(StorageKeys.accessToken);

  Future<void> setRefreshToken(String? token) => setString(StorageKeys.refreshToken, token);
  Future<String?> getRefreshToken() => getString(StorageKeys.refreshToken);

  Future<void> setTokenExpiresAt(DateTime? dateTime) =>
      setString(StorageKeys.tokenExpiresAt, dateTime?.toIso8601String());
  Future<DateTime?> getTokenExpiresAt() async {
    final str = await getString(StorageKeys.tokenExpiresAt);
    return str != null ? DateTime.tryParse(str) : null;
  }

  /// 主题相关快捷方法
  Future<void> setThemeMode(String? mode) => setString(StorageKeys.themeMode, mode);
  Future<String?> getThemeMode() => getString(StorageKeys.themeMode);
  String? getThemeModeSync() => getStringSync(StorageKeys.themeMode);

  /// 用户相关快捷方法
  Future<void> setUserProfileJson(String? json) => setString(StorageKeys.userProfile, json);
  Future<String?> getUserProfileJson() => getString(StorageKeys.userProfile);

  /// 文章相关快捷方法
  Future<void> setPinnedArticles(List<String>? articles) =>
      setStringList(StorageKeys.pinnedArticles, articles);
  Future<List<String>?> getPinnedArticles() => getStringList(StorageKeys.pinnedArticles);
}
