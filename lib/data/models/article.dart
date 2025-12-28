import 'package:intl/intl.dart';

/// 文章数据模型
class Article {
  final String id;
  final String title;
  final DateTime date;
  final String? content;

  Article({
    required this.id,
    required this.title,
    required this.date,
    this.content,
  });

  /// 格式化日期字符串
  String get formattedDate => DateFormat('yyyy/MM/dd').format(date);

  /// 从 JSON 创建
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      content: json['content'] as String?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'content': content,
    };
  }
}
