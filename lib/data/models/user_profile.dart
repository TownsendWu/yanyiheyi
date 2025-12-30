import 'dart:convert';

/// 用户信息模型
class UserProfile {
  final String nickname; // 昵称
  final String email; // 邮箱
  final String? avatar; // 头像URL（可选）
  final String? bio; // 个人简介（可选）

  const UserProfile({
    required this.nickname,
    required this.email,
    this.avatar,
    this.bio,
  });

  // 复制并修改部分字段
  UserProfile copyWith({
    String? nickname,
    String? email,
    String? avatar,
    String? bio,
  }) {
    return UserProfile(
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
    );
  }

  // 序列化为JSON
  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'email': email,
      'avatar': avatar,
      'bio': bio,
    };
  }

  // 从JSON反序列化
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nickname: json['nickname'] as String? ?? '用户',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
    );
  }

  // 序列化为字符串
  String toJsonString() => jsonEncode(toJson());

  // 从字符串反序列化
  static UserProfile fromJsonString(String jsonString) {
    return UserProfile.fromJson(jsonDecode(jsonString));
  }
}
