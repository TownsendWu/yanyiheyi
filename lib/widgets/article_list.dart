import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../data/models/article.dart';
import '../core/theme/app_colors.dart';

/// 文章列表组件
class ArticleList extends StatefulWidget {
  final List<Article> articles;
  // final int pageSize; // 每页显示的文章数量 (已移除分页功能)

  const ArticleList({
    super.key,
    required this.articles,
    // this.pageSize = 10, // 默认每页 10 篇 (已移除分页功能)
  });

  @override
  State<ArticleList> createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  bool _isNewestFirst = true;
  bool _isCardView = false; // 视图模式: false=列表视图, true=卡片视图
  // int _currentPage = 1; // (已移除分页功能)

  List<Article> get _sortedArticles {
    final sorted = List<Article>.from(widget.articles);
    sorted.sort((a, b) => _isNewestFirst
        ? b.date.compareTo(a.date)
        : a.date.compareTo(b.date));
    return sorted;
  }

  // int get _totalPages {
  //   return (_sortedArticles.length / widget.pageSize).ceil();
  // } // (已移除分页功能)

  // List<Article> get _currentPageArticles {
  //   final start = (_currentPage - 1) * widget.pageSize;
  //   final end = start + widget.pageSize;
  //   if (start >= _sortedArticles.length) return [];
  //   return _sortedArticles.sublist(
  //     start,
  //     end > _sortedArticles.length ? _sortedArticles.length : end,
  //   );
  // } // (已移除分页功能)

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
  }

  // void _goToPage(int page) {
  //   setState(() {
  //     _currentPage = page;
  //   });
  // } // (已移除分页功能)

  // void _previousPage() {
  //   if (_currentPage > 1) {
  //     setState(() {
  //       _currentPage--;
  //     });
  //   }
  // } // (已移除分页功能)

  // void _nextPage() {
  //   if (_currentPage < _totalPages) {
  //     setState(() {
  //       _currentPage++;
  //     });
  //   }
  // } // (已移除分页功能)

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayArticles = _sortedArticles; // 直接显示所有文章（不分页）

    return Column(
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
                ),
                const SizedBox(width: 8),
                // 排序按钮
                _SortToggleButton(
                  isNewestFirst: _isNewestFirst,
                  onTap: _toggleSort,
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
              return _ArticleListItem(article: article);
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
    );
  }
}

/// 分页控制组件
class _PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final void Function(int page) onPageChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _PaginationControls({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 上一页按钮
        IconButton(
          onPressed: currentPage > 1 ? onPrevious : null,
          icon: const Icon(Icons.chevron_left, size: 20),
          iconSize: 20,
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
        ),

        // 页码按钮
        ...List.generate(totalPages, (index) {
          final page = index + 1;
          final isCurrentPage = page == currentPage;

          // 如果页码太多，只显示部分页码
          if (totalPages > 7) {
            if (page == 1 ||
                page == totalPages ||
                (page >= currentPage - 1 && page <= currentPage + 1)) {
              return _PageButton(
                page: page,
                isCurrent: isCurrentPage,
                onPressed: () => onPageChanged(page),
              );
            } else if (page == currentPage - 2 || page == currentPage + 2) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('...', style: TextStyle(fontSize: 14)),
              );
            }
            return const SizedBox.shrink();
          }

          return _PageButton(
            page: page,
            isCurrent: isCurrentPage,
            onPressed: () => onPageChanged(page),
          );
        }),

        // 下一页按钮
        IconButton(
          onPressed: currentPage < totalPages ? onNext : null,
          icon: const Icon(Icons.chevron_right, size: 20),
          iconSize: 20,
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
        ),
      ],
    );
  }
}

/// 页码按钮组件
class _PageButton extends StatelessWidget {
  final int page;
  final bool isCurrent;
  final VoidCallback onPressed;

  const _PageButton({
    required this.page,
    required this.isCurrent,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isCurrent
              ? theme.colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: isCurrent
              ? null
              : Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
        ),
        child: Text(
          '$page',
          style: TextStyle(
            fontSize: 14,
            color: isCurrent
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// 文章列表项组件
class _ArticleListItem extends StatelessWidget {
  final Article article;

  const _ArticleListItem({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日期
          SizedBox(
            width: 100,
            child: Text(
              article.formattedDate,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 文章标题（带下划线）
          Expanded(
            child: Text(
              article.title,
              style: TextStyle(
                fontSize: 14,
                decoration: TextDecoration.underline,
                decorationColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// 视图切换按钮组件
class _ViewToggleButton extends StatelessWidget {
  final bool isCardView;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.isCardView,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
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
            Icon(
              isCardView ? Icons.view_list : Icons.grid_view,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              isCardView ? '列表' : '卡片',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// 排序切换按钮组件
class _SortToggleButton extends StatelessWidget {
  final bool isNewestFirst;
  final VoidCallback onTap;

  const _SortToggleButton({
    required this.isNewestFirst,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
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
    );
  }
}

/// 文章卡片组件
class _ArticleCard extends StatelessWidget {
  final Article article;
  final bool isTall;

  const _ArticleCard({
    required this.article,
    required this.isTall,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 根据高度类型决定显示的内容长度
    final excerpt = isTall
        ? _getLongExcerpt(article.content ?? '')
        : _getShortExcerpt(article.content ?? '');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
          Text(
            article.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // 日期
          Text(
            article.formattedDate,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          // 内容摘要
          Text(
            excerpt,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
            maxLines: isTall ? 4 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 获取长摘要(用于高卡片)
  String _getLongExcerpt(String content) {
    // 移除空格和换行,取前100个字符
    final cleanContent = content.replaceAll('\n', ' ').trim();
    if (cleanContent.length <= 100) return cleanContent;
    return '${cleanContent.substring(0, 100)}...';
  }

  /// 获取短摘要(用于矮卡片)
  String _getShortExcerpt(String content) {
    // 移除空格和换行,取前50个字符
    final cleanContent = content.replaceAll('\n', ' ').trim();
    if (cleanContent.length <= 50) return cleanContent;
    return '${cleanContent.substring(0, 50)}...';
  }
}
