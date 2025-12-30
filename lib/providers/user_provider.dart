import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_profile.dart';

/// 用户状态管理 Provider
class UserProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  UserProfile? _userProfile;

  UserProvider({required this.prefs}) {
    _loadUserProfile();
  }

  UserProfile get userProfile => _userProfile ?? _getDefaultProfile();

  /// 获取默认用户信息
  static UserProfile _getDefaultProfile() {
    return const UserProfile(
      nickname: '扭动的妖怪蝙蝠',
      email: 'user@example.com',
      bio: '记录生活，分享思考',
    );
  }

  /// 从本地存储加载用户信息
  void _loadUserProfile() {
    final userProfileJson = prefs.getString('user_profile');
    if (userProfileJson != null) {
      try {
        _userProfile = UserProfile.fromJsonString(userProfileJson);
        notifyListeners();
      } catch (e) {
        _userProfile = _getDefaultProfile();
      }
    } else {
      _userProfile = _getDefaultProfile();
    }
  }

  /// 更新用户信息
  Future<void> updateUserProfile(UserProfile newProfile) async {
    _userProfile = newProfile;
    notifyListeners();
    await prefs.setString('user_profile', newProfile.toJsonString());
  }

  /// 清除用户信息（登出时使用）
  Future<void> clearUserProfile() async {
    _userProfile = _getDefaultProfile();
    notifyListeners();
    await prefs.remove('user_profile');
  }
}
