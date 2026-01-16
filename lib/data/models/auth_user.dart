/// 认证用户模型
class AuthUser {
  final String userId;
  final String? accessToken;
  final String? refreshToken;
  final DateTime? tokenExpiresAt;
  final LoginType loginType;
  final bool isAuthenticated;

  const AuthUser({
    required this.userId,
    this.accessToken,
    this.refreshToken,
    this.tokenExpiresAt,
    required this.loginType,
    required this.isAuthenticated,
  });

  /// 判断 Token 是否有效
  bool get isTokenValid {
    if (tokenExpiresAt == null) return false;
    return DateTime.now().isBefore(tokenExpiresAt!);
  }

  /// 是否需要刷新 Token（提前5分钟）
  bool get needsTokenRefresh {
    if (tokenExpiresAt == null) return true;
    final threshold = tokenExpiresAt!.subtract(const Duration(minutes: 5));
    return DateTime.now().isAfter(threshold);
  }

  /// 创建游客用户
  factory AuthUser.guest() {
    return AuthUser(
      userId: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      loginType: LoginType.guest,
      isAuthenticated: false,
    );
  }

  /// 创建已认证用户
  factory AuthUser.authenticated({
    required String userId,
    required String accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
    required LoginType loginType,
  }) {
    return AuthUser(
      userId: userId,
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenExpiresAt: tokenExpiresAt,
      loginType: loginType,
      isAuthenticated: true,
    );
  }

  /// 复制并更新部分字段
  AuthUser copyWith({
    String? userId,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
    LoginType? loginType,
    bool? isAuthenticated,
  }) {
    return AuthUser(
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
      loginType: loginType ?? this.loginType,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenExpiresAt': tokenExpiresAt?.toIso8601String(),
      'loginType': loginType.name,
      'isAuthenticated': isAuthenticated,
    };
  }

  /// 从 JSON 创建
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json['userId'] as String,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      tokenExpiresAt: json['tokenExpiresAt'] != null
          ? DateTime.parse(json['tokenExpiresAt'] as String)
          : null,
      loginType: LoginType.values.firstWhere(
        (type) => type.name == json['loginType'],
        orElse: () => LoginType.guest,
      ),
      isAuthenticated: json['isAuthenticated'] as bool? ?? false,
    );
  }
}

/// 登录类型枚举
enum LoginType {
  /// 微信登录
  wechat,

  /// 抖音登录
  douyin,

  /// 手机号登录
  phone,

  /// 游客模式
  guest,
}

/// 登录结果
class LoginResult {
  final AuthUser user;
  final String? message;

  const LoginResult({
    required this.user,
    this.message,
  });

  factory LoginResult.success(AuthUser user) {
    return LoginResult(user: user);
  }

  factory LoginResult.failed(String message) {
    return LoginResult(
      user: AuthUser.guest(),
      message: message,
    );
  }
}
