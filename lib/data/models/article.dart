import 'package:intl/intl.dart';

/// 文章数据模型
class Article {
  final String id;
  final String title;
  final DateTime date; // 创建日期
  final DateTime? updatedAt; // 更新日期
  final dynamic content; // 可以是 String 或 List（Quill Delta 格式）
  final String? coverImage; // 封面图片 URL
  final List<String> tags; // 标签列表
  final bool isPinned; // 是否置顶
  final DateTime? pinnedAt; // 置顶时间

  // 字体信息
  final String? fontFamily; // 字体 family
  final double? fontSize; // 字体大小
  final int? fontWeight; // 字体粗细 (0-9, 对应 Flutter 的 FontWeight.w100 - w900)
  final double? lineHeight; // 行高
  final double? letterSpacing; // 字间距

  Article({
    required this.id,
    required this.title,
    required this.date,
    this.updatedAt,
    this.content,
    this.coverImage,
    List<String>? tags,
    this.isPinned = false,
    this.pinnedAt,
    this.fontFamily,
    this.fontSize,
    this.fontWeight,
    this.lineHeight,
    this.letterSpacing,
  }) : tags = tags ?? [];

  /// 格式化日期字符串 (到分钟)
  String get formattedDate => DateFormat('yyyy/MM/dd HH:mm').format(date);

  /// 格式化更新日期字符串 (优先显示 updatedAt，否则显示 date)
  String get formattedUpdateDate =>
      DateFormat('yyyy/MM/dd HH:mm').format(updatedAt ?? date);

  /// 格式化短日期字符串 (只有日期) - 优先显示 updatedAt
  String get formattedShortDate =>
      DateFormat('yyyy/MM/dd').format(updatedAt ?? date);

  /// 预估阅读时间 (分钟)
  int get estimatedReadingTime {
    if (content == null) return 0;

    // 处理不同类型的 content
    String textContent;
    if (content is String) {
      textContent = content!;
    } else if (content is List) {
      // 从 Quill Delta 格式提取文本
      final buffer = StringBuffer();
      for (final item in content as List) {
        if (item is Map && item.containsKey('insert')) {
          final insert = item['insert'];
          if (insert is String) {
            buffer.write(insert);
          }
        }
      }
      textContent = buffer.toString();
    } else {
      return 0;
    }

    if (textContent.isEmpty) return 0;

    // 假设每分钟阅读 300 字
    final wordCount = textContent.length;
    return (wordCount / 300).ceil();
  }

  /// 从 JSON 创建
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      content: json['content'], // 保留原始类型（String 或 List）
      coverImage: json['coverImage'] as String?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isPinned: json['isPinned'] as bool? ?? false,
      pinnedAt: json['pinnedAt'] != null
          ? DateTime.parse(json['pinnedAt'] as String)
          : null,
      fontFamily: json['fontFamily'] as String?,
      fontSize: json['fontSize'] as double?,
      fontWeight: json['fontWeight'] as int?,
      lineHeight: json['lineHeight'] as double?,
      letterSpacing: json['letterSpacing'] as double?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'content': content,
      'coverImage': coverImage,
      'tags': tags,
      'isPinned': isPinned,
      'pinnedAt': pinnedAt?.toIso8601String(),
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'fontWeight': fontWeight,
      'lineHeight': lineHeight,
      'letterSpacing': letterSpacing,
    };
  }

  /// 复制并更新部分字段
  /// 对于可空类型，使用 ValueNotifier 包装以区分"不更新"和"设置为 null"
  Article copyWith({
    String? id,
    String? title,
    DateTime? date,
    DateTime? updatedAt,
    dynamic content, // 改为 dynamic 以支持 String 和 List
    String? coverImage,
    List<String>? tags,
    bool? isPinned,
    DateTime? pinnedAt,
    String? fontFamily,
    double? fontSize,
    int? fontWeight,
    double? lineHeight,
    double? letterSpacing,
    bool clearCoverImage = false, // 新增：专门用于清除 coverImage
    bool clearContent = false, // 新增：专门用于清除 content
    bool clearFontFamily = false, // 新增：专门用于清除 fontFamily
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      updatedAt: updatedAt ?? this.updatedAt,
      content: clearContent ? null : (content ?? this.content),
      coverImage: clearCoverImage ? null : (coverImage ?? this.coverImage),
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      pinnedAt: pinnedAt ?? this.pinnedAt,
      fontFamily: clearFontFamily ? null : (fontFamily ?? this.fontFamily),
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
    );
  }
}
