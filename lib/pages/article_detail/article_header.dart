import 'package:flutter/material.dart';
import '../../data/models/article.dart';
import '../../utils/string_utils.dart';

/// 文章头部信息组件（标题、日期、标签）
class ArticleHeader extends StatelessWidget {
  final Article article;
  final TextEditingController titleController;
  final FocusNode titleFocusNode;

  const ArticleHeader({
    super.key,
    required this.article,
    required this.titleController,
    required this.titleFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 有封面图时留更多空间
        SizedBox(height: StringUtils.isNotBlank(article.coverImage) ? 20 : 0),

        // 标题输入框
        TextField(
          controller: titleController,
          focusNode: titleFocusNode,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            height: 1.3,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: '无标题',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          maxLines: null,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            titleFocusNode.unfocus();
          },
        ),

        // 元信息行: 日期 / 阅读时间
        Row(
          children: [
            Text(
              article.formattedDate,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '/',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${article.estimatedReadingTime} 分钟阅读',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // 标签
        if (article.tags.isNotEmpty) ...[
          _TagsSection(tags: article.tags),
          const SizedBox(height: 30),
        ],

        // 文章内容
        Text(
          article.content ?? '暂无内容',
          style: TextStyle(
            fontSize: 16,
            height: 1.8,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
            letterSpacing: 0.3,
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }
}

/// 标签部分
class _TagsSection extends StatelessWidget {
  final List<String> tags;

  const _TagsSection({required this.tags});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: tags.asMap().entries.map((entry) {
        final index = entry.key;
        final tag = entry.value;
        final isLast = index == tags.length - 1;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 可点击的标签
            InkWell(
              onTap: () {
                // TODO: 处理标签点击事件
                print('点击标签: $tag');
              },
              borderRadius: BorderRadius.circular(4),
              child: Text(
                '#$tag',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  decoration: TextDecoration.underline,
                  decorationColor: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ),
            // 逗号分隔符（最后一个标签不加）
            if (!isLast)
              Text(
                '，',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}
