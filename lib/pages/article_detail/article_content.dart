import 'package:flutter/material.dart';

/// 文章内容组件
class ArticleContent extends StatelessWidget {
  final String? content;

  const ArticleContent({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      content ?? '暂无内容',
      style: TextStyle(
        fontSize: 16,
        height: 1.8,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
        letterSpacing: 0.3,
      ),
    );
  }
}
