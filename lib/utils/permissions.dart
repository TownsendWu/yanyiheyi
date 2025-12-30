import '../data/models/membership.dart';
import '../data/models/auth_user.dart';

/// 权限检查工具
/// 提供静态方法检查用户是否有某项权限
class PermissionChecker {
  PermissionChecker._();

  /// 检查权限
  /// [user] 用户信息
  /// [membership] 会员信息（可选）
  /// [permission] 要检查的权限
  static bool check(
    AuthUser? user,
    Membership? membership,
    Permission permission,
  ) {
    // 游客只能使用免费功能
    if (user == null || !user.isAuthenticated || user.loginType == LoginType.guest) {
      return permission.isFree;
    }

    // 已登录用户，检查会员状态
    if (membership != null && membership.isValid) {
      return membership.level.hasPermission(permission);
    }

    // 没有会员信息，只能使用免费功能
    return permission.isFree;
  }

  /// 检查是否需要登录
  static bool requireLogin(AuthUser? user) {
    return user != null && user.isAuthenticated;
  }

  /// 检查是否需要会员
  static bool requireMembership(Membership? membership) {
    return membership != null && membership.isValid;
  }

  /// 检查是否为指定等级或更高
  static bool requireLevel(Membership? membership, MembershipLevel requiredLevel) {
    if (membership == null) return false;

    final levels = [
      MembershipLevel.free,
      MembershipLevel.monthly,
      MembershipLevel.yearly,
      MembershipLevel.lifetime,
    ];

    final currentLevelIndex = levels.indexOf(membership.level);
    final requiredLevelIndex = levels.indexOf(requiredLevel);

    return currentLevelIndex >= requiredLevelIndex;
  }

  /// 获取权限检查的错误消息
  static String? getErrorMessage(
    AuthUser? user,
    Membership? membership,
    Permission permission,
  ) {
    // 未登录
    if (user == null || !user.isAuthenticated) {
      return '请先登录';
    }

    // 游客模式
    if (user.loginType == LoginType.guest) {
      return '游客无法使用此功能，请先登录';
    }

    // 会员已过期
    if (membership != null && !membership.isValid) {
      return '会员已过期，请续费';
    }

    // 权限不足
    if (membership != null && !membership.level.hasPermission(permission)) {
      return '此功能需要 ${_getRequiredLevel(permission)} 权限';
    }

    return null;
  }

  /// 获取权限所需的最低等级
  static MembershipLevel _getRequiredLevel(Permission permission) {
    // 所有会员专属功能都至少需要月度会员
    return MembershipLevel.monthly;
  }
}

/// 权限常量
class PermissionConstants {
  PermissionConstants._();

  /// 免费功能列表
  static const List<Permission> freeFeatures = [
    Permission.viewArticle,
    Permission.createArticle,
    Permission.editProfile,
  ];

  /// 会员功能列表
  static const List<Permission> paidFeatures = [
    Permission.cloudStorage,
    Permission.aiWritingAssistant,
    Permission.advancedStatistics,
    Permission.customTheme,
    Permission.unlimitedArticles,
    Permission.prioritySupport,
    Permission.exportArticles,
    Permission.removeAds,
  ];

  /// 所有功能列表
  static const List<Permission> allFeatures = [...freeFeatures, ...paidFeatures];
}
