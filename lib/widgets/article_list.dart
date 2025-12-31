import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/article.dart';
import '../core/theme/app_colors.dart';
import '../pages/article_detail_page.dart';
import 'article_action_handler.dart';

/// 文章列表组件
class ArticleList extends StatefulWidget {
  final List<Article> articles;
  final Function(List<Article>)? onArticlesUpdated; // 文章更新回调
  final Function(List<String>)? onArticlesDeleted; // 文章删除回调
  final Function(bool, int, VoidCallback, VoidCallback, VoidCallback, VoidCallback)?
  onSelectionModeChanged; // 多选模式状态变化回调 (添加了全选回调)
  // final int pageSize; // 每页显示的文章数量 (已移除分页功能)

  const ArticleList({
    super.key,
    required this.articles,
    this.onArticlesUpdated,
    this.onArticlesDeleted,
    this.onSelectionModeChanged,
  });

  @override
  State<ArticleList> createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  bool _isNewestFirst = true;
  bool _isCardView = false; // 视图模式: false=列表视图, true=卡片视图
  final Set<String> _visitedArticleIds = <String>{}; // 记录已访问的文章ID
  // int _currentPage = 1; // (已移除分页功能)

  // 多选模式相关状态
  bool _isSelectionMode = false;
  final Set<String> _selectedArticleIds = <String>{};

  // 暴露给外部访问的getter
  bool get isSelectionMode => _isSelectionMode;
  int get selectedCount => _selectedArticleIds.length;
  List<String> get selectedArticleIds => _selectedArticleIds.toList();

  static const String _isCardViewKey = 'isCardView';

  @override
  void initState() {
    super.initState();
    _loadViewMode();
  }

  /// 从 SharedPreferences 加载视图模式
  Future<void> _loadViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isCardView = prefs.getBool(_isCardViewKey) ?? false;
    });
  }

  /// 保存视图模式到 SharedPreferences
  Future<void> _saveViewMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isCardViewKey, value);
  }

  List<Article> get _sortedArticles {
    final sorted = List<Article>.from(widget.articles);
    sorted.sort((a, b) {
      // 先按置顶状态排序（置顶的在前）
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;

      // 如果都置顶，按置顶时间倒序（后置顶的在前）
      if (a.isPinned && b.isPinned) {
        final aPinnedAt = a.pinnedAt;
        final bPinnedAt = b.pinnedAt;
        if (aPinnedAt != null && bPinnedAt != null) {
          return bPinnedAt.compareTo(aPinnedAt);
        }
        if (aPinnedAt != null) return -1;
        if (bPinnedAt != null) return 1;
      }

      // 都未置顶或置顶时间相同，按更新时间排序
      // 优先使用 updatedAt，如果为空则使用 date
      final aTime = a.updatedAt ?? a.date;
      final bTime = b.updatedAt ?? b.date;

      return _isNewestFirst ? bTime.compareTo(aTime) : aTime.compareTo(bTime);
    });
    return sorted;
  }

  void _toggleSort() {
    setState(() {
      _isNewestFirst = !_isNewestFirst;
      // _currentPage = 1; // 重置到第一页 (已移除分页功能)
    });
  }

  void _toggleView() {
    setState(() {
      _isCardView = !_isCardView;
    });
    _saveViewMode(_isCardView);
  }

  /// 进入多选模式
  void _enterSelectionMode(String articleId) {
    setState(() {
      _isSelectionMode = true;
      _selectedArticleIds.clear();
      _selectedArticleIds.add(articleId);
    });
    widget.onSelectionModeChanged?.call(
      true,
      _selectedArticleIds.length,
      handlePinSelection,
      handleDeleteSelection,
      _exitSelectionMode,
      handleSelectAll,
    );
  }

  /// 退出多选模式
  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedArticleIds.clear();
    });
    widget.onSelectionModeChanged?.call(false, 0, () {}, () {}, () {}, () {});
  }

  /// 切换文章选中状态
  void _toggleArticleSelection(String articleId) {
    setState(() {
      if (_selectedArticleIds.contains(articleId)) {
        _selectedArticleIds.remove(articleId);
        if (_selectedArticleIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedArticleIds.add(articleId);
      }
    });

    // 通知HomePage更新选中数量和回调
    if (_isSelectionMode) {
      widget.onSelectionModeChanged?.call(
        true,
        _selectedArticleIds.length,
        handlePinSelection,
        handleDeleteSelection,
        _exitSelectionMode,
        handleSelectAll,
      );
    } else {
      widget.onSelectionModeChanged?.call(false, 0, () {}, () {}, () {}, () {});
    }
  }

  /// 处理置顶操作
  void handlePinSelection() {
    final handler = ArticleActionHandler(
      context: context,
      articles: widget.articles,
    );

    handler.handlePin(selectedArticleIds, (updatedArticle) {
      widget.onArticlesUpdated?.call([updatedArticle]);
    });

    _exitSelectionMode();
  }

  /// 处理删除操作
  void handleDeleteSelection() {
    final handler = ArticleActionHandler(
      context: context,
      articles: widget.articles,
    );

    // 保存要删除的文章 ID 列表
    final idsToDelete = List<String>.from(selectedArticleIds);

    handler.handleDelete(selectedArticleIds, (articleId) {
      // 从选中列表中移除
      _selectedArticleIds.remove(articleId);
    }).then((_) {
      // 通知 HomePage 删除文章（传递要删除的 ID 列表）
      widget.onArticlesDeleted?.call(idsToDelete);
      _exitSelectionMode();
    });
  }

  /// 处理全选操作
  void handleSelectAll() {
    setState(() {
      if (_selectedArticleIds.length == widget.articles.length) {
        // 如果已经全选,则取消全选
        _selectedArticleIds.clear();
      } else {
        // 否则全选
        _selectedArticleIds.clear();
        for (final article in widget.articles) {
          _selectedArticleIds.add(article.id);
        }
      }
    });

    // 通知HomePage更新选中数量
    if (_isSelectionMode) {
      widget.onSelectionModeChanged?.call(
        true,
        _selectedArticleIds.length,
        handlePinSelection,
        handleDeleteSelection,
        _exitSelectionMode,
        handleSelectAll,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayArticles = _sortedArticles; // 直接显示所有文章（不分页）

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Posts 标题和按钮组
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '文章',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? AppColors.primaryDark
                        : AppColors.articleListTitleLight,
                  ),
                ),
                // 按钮组: 视图切换 + 排序
                Row(
                  children: [
                    // 视图切换按钮
                    _ViewToggleButton(
                      isCardView: _isCardView,
                      onTap: _toggleView,
                      enabled: !_isSelectionMode,
                    ),
                    const SizedBox(width: 8),
                    // 排序按钮
                    _SortToggleButton(
                      isNewestFirst: _isNewestFirst,
                      onTap: _toggleSort,
                      enabled: !_isSelectionMode,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 根据视图模式显示不同布局
            if (_isCardView) ...[
              // 卡片视图
              MasonryGridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemCount: displayArticles.length,
                itemBuilder: (context, index) {
                  final article = displayArticles[index];
                  // 根据索引决定卡片高度(固定交替)
                  final isTall = index % 2 == 0;
                  return _ArticleCard(
                    article: article,
                    isTall: isTall,
                    isVisited: _visitedArticleIds.contains(article.id),
                    isSelected: _selectedArticleIds.contains(article.id),
                    isSelectionMode: _isSelectionMode,
                    onVisit: () {
                      setState(() {
                        _visitedArticleIds.add(article.id);
                      });
                    },
                    onLongPress: () => _enterSelectionMode(article.id),
                    onTap: () {
                      if (_isSelectionMode) {
                        _toggleArticleSelection(article.id);
                      }
                    },
                  );
                },
              ),
            ] else ...[
              // 列表视图
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayArticles.length,
                itemBuilder: (context, index) {
                  final article = displayArticles[index];
                  return _ArticleListItem(
                    article: article,
                    isVisited: _visitedArticleIds.contains(article.id),
                    isSelected: _selectedArticleIds.contains(article.id),
                    isSelectionMode: _isSelectionMode,
                    onVisit: () {
                      setState(() {
                        _visitedArticleIds.add(article.id);
                      });
                    },
                    onLongPress: () => _enterSelectionMode(article.id),
                    onTap: () {
                      if (_isSelectionMode) {
                        _toggleArticleSelection(article.id);
                      }
                    },
                  );
                },
              ),
            ],
            // 分页控制组件 (已移除分页功能)
            // if (_totalPages > 1) ...[
            //   const SizedBox(height: 16),
            //   _PaginationControls(
            //     currentPage: _currentPage,
            //     totalPages: _totalPages,
            //     onPageChanged: _goToPage,
            //     onPrevious: _previousPage,
            //     onNext: _nextPage,
            //   ),
            // ],
          ],
        ),
      ],
    );
  }
}

/// 文章列表项组件
class _ArticleListItem extends StatelessWidget {
  final Article article;
  final bool isVisited;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onVisit;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  const _ArticleListItem({
    super.key, // 记得加上 super.key
    required this.article,
    required this.isVisited,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onVisit,
    required this.onLongPress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Hero(
      tag: 'article_${article.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isSelectionMode) {
              onTap();
            } else {
              onVisit();
              // ... 原有的跳转逻辑 ...
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ArticleDetailPage(article: article),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 0.05);
                        const end = Offset.zero;
                        const curve = Curves.easeOut;
                        var tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));
                        var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
                            .animate(
                              CurvedAnimation(parent: animation, curve: curve),
                            );
                        return FadeTransition(
                          opacity: fadeAnimation,
                          child: SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          ),
                        );
                      },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            }
          },
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(4),
          child: AnimatedContainer(
            // 使用 AnimatedContainer 让背景色切换更丝滑
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 2.0),
            decoration: isSelectionMode && isSelected
                ? BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  )
                : const BoxDecoration(
                    color: Colors.transparent, // 保持默认状态也有 BoxDecoration，避免结构变化
                  ),
            child: Padding(
              // 【核心修改1】：固定 Padding，不再根据模式变化
              // 之前是 vertical: 4 vs 5，现在统一为 5，消除垂直跳动
              padding: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 5.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 日期
                  SizedBox(
                    width: 100,
                    child: Text(
                      article.formattedShortDate,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 文章标题
                  Expanded(
                    child: Row(
                      children: [
                        if (article.isPinned) ...[
                          Icon(
                            Icons.push_pin,
                            size: 16,
                            color: theme.brightness == Brightness.dark
                                ? AppColors.primaryDark
                                : AppColors.articleListTitleLight,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            article.title,
                            style: TextStyle(
                              fontSize: 15,
                              color: isVisited
                                  ? theme.colorScheme.onSurface.withValues(
                                      alpha: 0.5,
                                    )
                                  : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.8,
                                    ),
                              decoration: TextDecoration.underline,
                              decorationColor: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 多选框（放在列表后面）
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment: Alignment.centerLeft,
                    child: isSelectionMode
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              width: 15,
                              height: 15,
                              child: Checkbox(
                                value: isSelected,
                                onChanged: (_) => onTap(),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                fillColor: WidgetStateProperty.resolveWith((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.selected)) {
                                    return theme.colorScheme.primary;
                                  }
                                  return theme.colorScheme.onSurface.withValues(
                                    alpha: 0.1,
                                  );
                                }),
                                side: BorderSide.none,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



/// 文章卡片组件
class _ArticleCard extends StatelessWidget {
  final Article article;
  final bool isTall;
  final bool isVisited;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onVisit;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  const _ArticleCard({
    super.key,
    required this.article,
    required this.isTall,
    required this.isVisited,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onVisit,
    required this.onLongPress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final excerpt = isTall
        ? _getLongExcerpt(article.content ?? '')
        : _getShortExcerpt(article.content ?? '');

    // 计算边框宽度和 Padding
    final bool showThickBorder = isSelectionMode && isSelected;
    final double borderWidth = showThickBorder ? 2.0 : 1.0;
    // 【核心修改3】：Padding 补偿机制
    // 正常 Padding 是 12。
    // 如果边框从 1 变 2，由于 border 画在内部，内容会被挤压。
    // 为了不让文字动，我们需要减少 padding： 12 - (2 - 1) = 11
    final double paddingValue = showThickBorder ? 11.0 : 12.0;

    return Hero(
      tag: 'article_${article.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isSelectionMode) {
              onTap();
            } else {
              onVisit();
              // ... 原有的跳转逻辑 ...
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ArticleDetailPage(article: article),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 0.05);
                        const end = Offset.zero;
                        const curve = Curves.easeOut;
                        var tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));
                        var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
                            .animate(
                              CurvedAnimation(parent: animation, curve: curve),
                            );
                        return FadeTransition(
                          opacity: fadeAnimation,
                          child: SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          ),
                        );
                      },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            }
          },
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // 使用 AnimatedContainer 处理边框和 Padding 的变化
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                padding: EdgeInsets.all(paddingValue), // 动态调整 Padding
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border.all(
                    color: showThickBorder
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    width: borderWidth, // 动态调整边框
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题行
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            article.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isVisited
                                  ? theme.colorScheme.onSurface.withValues(
                                      alpha: 0.5,
                                    )
                                  : theme.colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (article.isPinned)
                          Icon(
                            Icons.push_pin,
                            size: 14,
                            color: theme.brightness == Brightness.dark
                                ? AppColors.primaryDark
                                : AppColors.articleListTitleLight,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 日期
                    Text(
                      article.formattedShortDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 摘要
                    Text(
                      excerpt,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                        height: 1.5,
                      ),
                      maxLines: isTall ? 4 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // 多选框 (Positioned 绝对定位，不会影响布局)
              if (isSelectionMode)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: SizedBox(
                    width: 15,
                    height: 15,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => onTap(),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      fillColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return theme.colorScheme.primary;
                        }
                        return theme.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        );
                      }),
                      side: BorderSide.none,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLongExcerpt(String content) {
    final cleanContent = content.replaceAll('\n', ' ').trim();
    if (cleanContent.length <= 100) return cleanContent;
    return '${cleanContent.substring(0, 100)}...';
  }

  String _getShortExcerpt(String content) {
    final cleanContent = content.replaceAll('\n', ' ').trim();
    if (cleanContent.length <= 50) return cleanContent;
    return '${cleanContent.substring(0, 50)}...';
  }
}



/// 视图切换按钮组件
class _ViewToggleButton extends StatelessWidget {
  final bool isCardView;
  final VoidCallback onTap;
  final bool enabled;

  const _ViewToggleButton({
    required this.isCardView,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isCardView ? Icons.view_list : Icons.grid_view, size: 16),
              const SizedBox(width: 4),
              Text(
                isCardView ? '列表' : '卡片',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 排序切换按钮组件
class _SortToggleButton extends StatelessWidget {
  final bool isNewestFirst;
  final VoidCallback onTap;
  final bool enabled;

  const _SortToggleButton({
    required this.isNewestFirst,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isNewestFirst ? '最新' : '最旧',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 4),
              Icon(
                isNewestFirst ? Icons.arrow_downward : Icons.arrow_upward,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
