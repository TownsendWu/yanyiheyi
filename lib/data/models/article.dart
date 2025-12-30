import 'package:intl/intl.dart';

/// 文章数据模型
class Article {
  final String id;
  final String title;
  final DateTime date;
  final String? content;
  final String? coverImage; // 封面图片 URL
  final List<String> tags; // 标签列表
  final bool isPinned; // 是否置顶
  final DateTime? pinnedAt; // 置顶时间

  Article({
    required this.id,
    required this.title,
    required this.date,
    this.content,
    this.coverImage,
    List<String>? tags,
    this.isPinned = false,
    this.pinnedAt,
  }) : tags = tags ?? [];

  /// 格式化日期字符串 (到分钟)
  String get formattedDate => DateFormat('yyyy/MM/dd HH:mm').format(date);

  /// 格式化短日期字符串 (只有日期)
  String get formattedShortDate => DateFormat('yyyy/MM/dd').format(date);

  /// 预估阅读时间 (分钟)
  int get estimatedReadingTime {
    if (content == null || content!.isEmpty) return 0;
    // 假设每分钟阅读 300 字
    final wordCount = content!.length;
    return (wordCount / 300).ceil();
  }

  /// 从 JSON 创建
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      content: json['content'] as String?,
      coverImage: json['coverImage'] as String?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isPinned: json['isPinned'] as bool? ?? false,
      pinnedAt: json['pinnedAt'] != null
          ? DateTime.parse(json['pinnedAt'] as String)
          : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'content': content,
      'coverImage': coverImage,
      'tags': tags,
      'isPinned': isPinned,
      'pinnedAt': pinnedAt?.toIso8601String(),
    };
  }

  /// 复制并更新部分字段
  Article copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? content,
    String? coverImage,
    List<String>? tags,
    bool? isPinned,
    DateTime? pinnedAt,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      content: content ?? this.content,
      coverImage: coverImage ?? this.coverImage,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      pinnedAt: pinnedAt ?? this.pinnedAt,
    );
  }
}
