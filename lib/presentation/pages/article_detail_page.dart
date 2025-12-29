import 'package:flutter/material.dart';
import '../../data/models/article.dart';

/// 文章详情页 (Notion 风格)
class ArticleDetailPage extends StatefulWidget {
  final Article article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  late TextEditingController _titleController;
  late final Article _article;
  final FocusNode _titleFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _article = widget.article;
    _titleController = TextEditingController(text: _article.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        // 点击空白区域时取消焦点
        _titleFocusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            // App Bar with back button and more options
            SliverAppBar(
              expandedHeight: _article.coverImage != null ? 100 : 0,
              pinned: true,
              floating: false,
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
                padding: const EdgeInsets.only(left: 16),
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 24,
                  ),
                  onPressed: () {
                    // TODO: 显示更多选项菜单
                  },
                  padding: const EdgeInsets.only(right: 16),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ],
              flexibleSpace: _article.coverImage != null
                  ? FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            _article.coverImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                          // 渐变遮罩
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  theme.colorScheme.surface.withValues(
                                    alpha: 0.7,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
            // 内容区域
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // 标题输入框
                    TextField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
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
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        // 提交后取消焦点
                        _titleFocusNode.unfocus();
                      },
                    ),

                    // const SizedBox(height: 24),

                    // 元信息行: 日期 / 阅读时间
                    Row(
                      children: [
                        Text(
                          _article.formattedDate,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '/',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_article.estimatedReadingTime} 分钟阅读',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // 标签
                    if (_article.tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: _article.tags.asMap().entries.map((entry) {
                          final index = entry.key;
                          final tag = entry.value;
                          final isLast = index == _article.tags.length - 1;

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
                                    color: theme.colorScheme.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                                    decoration: TextDecoration.underline,
                                    decorationColor:
                                        theme.colorScheme.onSurface.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                              // 逗号分隔符（最后一个标签不加）
                              if (!isLast)
                                Text(
                                  '，',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 30),
                    ],

                    // 文章内容
                    Text(
                      _article.content ?? '暂无内容',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.9,
                        ),
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
