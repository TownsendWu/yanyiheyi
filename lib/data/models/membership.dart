/// 会员状态模型
class Membership {
  final String userId;
  final MembershipLevel level;
  final DateTime? startDate;
  final DateTime? expiryDate;
  final bool isActive;

  const Membership({
    required this.userId,
    required this.level,
    this.startDate,
    this.expiryDate,
    required this.isActive,
  });

  /// 判断会员是否有效
  bool get isValid {
    if (!isActive) return false;
    if (expiryDate == null) return false;
    return DateTime.now().isBefore(expiryDate!);
  }

  /// 判断是否为付费会员
  bool get isPaidMember => level != MembershipLevel.free;

  /// 获取剩余天数
  int get remainingDays {
    if (expiryDate == null) return 0;
    final diff = expiryDate!.difference(DateTime.now());
    return diff.inDays > 0 ? diff.inDays : 0;
  }

  /// 创建免费会员
  factory Membership.free(String userId) {
    return Membership(
      userId: userId,
      level: MembershipLevel.free,
      isActive: false,
    );
  }

  /// 创建付费会员
  factory Membership.paid({
    required String userId,
    required MembershipLevel level,
    required DateTime startDate,
    required DateTime expiryDate,
  }) {
    return Membership(
      userId: userId,
      level: level,
      startDate: startDate,
      expiryDate: expiryDate,
      isActive: true,
    );
  }

  /// 复制并更新部分字段
  Membership copyWith({
    String? userId,
    MembershipLevel? level,
    DateTime? startDate,
    DateTime? expiryDate,
    bool? isActive,
  }) {
    return Membership(
      userId: userId ?? this.userId,
      level: level ?? this.level,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'level': level.name,
      'startDate': startDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// 从 JSON 创建
  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      userId: json['userId'] as String,
      level: MembershipLevel.values.firstWhere(
        (level) => level.name == json['level'],
        orElse: () => MembershipLevel.free,
      ),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}

/// 会员等级枚举
enum MembershipLevel {
  /// 免费用户
  free,

  /// 月度会员
  monthly,

  /// 年度会员
  yearly,

  /// 终身会员
  lifetime,
}

/// 会员等级扩展方法
extension MembershipLevelExtension on MembershipLevel {
  /// 获取等级名称
  String get displayName {
    switch (this) {
      case MembershipLevel.free:
        return '免费用户';
      case MembershipLevel.monthly:
        return '月度会员';
      case MembershipLevel.yearly:
        return '年度会员';
      case MembershipLevel.lifetime:
        return '终身会员';
    }
  }

  /// 获取等级描述
  String get description {
    switch (this) {
      case MembershipLevel.free:
        return '基础功能免费使用';
      case MembershipLevel.monthly:
        return '月度会员，解锁全部高级功能';
      case MembershipLevel.yearly:
        return '年度会员，更超值的选择';
      case MembershipLevel.lifetime:
        return '终身会员，一次购买永久享受';
    }
  }

  /// 获取价格（分）
  int get price {
    switch (this) {
      case MembershipLevel.free:
        return 0;
      case MembershipLevel.monthly:
        return 1800; // 18元/月
      case MembershipLevel.yearly:
        return 18800; // 188元/年
      case MembershipLevel.lifetime:
        return 49800; // 498元终身
    }
  }

  /// 判断是否有某项权限
  bool hasPermission(Permission permission) {
    switch (this) {
      case MembershipLevel.free:
        return permission.isFree;
      case MembershipLevel.monthly:
      case MembershipLevel.yearly:
      case MembershipLevel.lifetime:
        return true;
    }
  }
}

/// 权限枚举
enum Permission {
  // 免费权限
  viewArticle,
  createArticle,
  editProfile,

  // 会员权限
  cloudStorage,
  aiWritingAssistant,
  advancedStatistics,
  customTheme,
  unlimitedArticles,
  prioritySupport,
  exportArticles,
  removeAds,
}

/// 权限扩展方法
extension PermissionExtension on Permission {
  /// 是否为免费权限
  bool get isFree {
    switch (this) {
      case Permission.viewArticle:
      case Permission.createArticle:
      case Permission.editProfile:
        return true;
      case Permission.cloudStorage:
      case Permission.aiWritingAssistant:
      case Permission.advancedStatistics:
      case Permission.customTheme:
      case Permission.unlimitedArticles:
      case Permission.prioritySupport:
      case Permission.exportArticles:
      case Permission.removeAds:
        return false;
    }
  }

  /// 获取权限名称
  String get displayName {
    switch (this) {
      case Permission.viewArticle:
        return '浏览文章';
      case Permission.createArticle:
        return '创建文章';
      case Permission.editProfile:
        return '编辑资料';
      case Permission.cloudStorage:
        return '云端存储';
      case Permission.aiWritingAssistant:
        return 'AI 写作助手';
      case Permission.advancedStatistics:
        return '高级统计';
      case Permission.customTheme:
        return '自定义主题';
      case Permission.unlimitedArticles:
        return '无限文章';
      case Permission.prioritySupport:
        return '优先客服';
      case Permission.exportArticles:
        return '导出文章';
      case Permission.removeAds:
        return '去除广告';
    }
  }

  /// 获取权限描述
  String get description {
    switch (this) {
      case Permission.viewArticle:
        return '浏览所有文章内容';
      case Permission.createArticle:
        return '创建和发布文章';
      case Permission.editProfile:
        return '编辑个人信息';
      case Permission.cloudStorage:
        return '数据云端同步，多设备访问';
      case Permission.aiWritingAssistant:
        return '智能写作建议和内容生成';
      case Permission.advancedStatistics:
        return '详细的写作数据分析';
      case Permission.customTheme:
        return '自定义应用主题和字体';
      case Permission.unlimitedArticles:
        return '不限制文章数量';
      case Permission.prioritySupport:
        return '专属客服，优先响应';
      case Permission.exportArticles:
        return '导出文章为 PDF 或 Markdown';
      case Permission.removeAds:
        return '去除所有广告';
    }
  }
}
