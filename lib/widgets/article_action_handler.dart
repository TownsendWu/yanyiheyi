import 'package:flutter/material.dart';
import '../data/models/article.dart';

/// 文章操作处理器 - 公共类，用于处理文章的置顶和删除操作
class ArticleActionHandler {
  final BuildContext context;
  final List<Article> articles;

  ArticleActionHandler({
    required this.context,
    required this.articles,
  });

  /// 处理置顶操作
  Future<void> handlePin(List<String> articleIds, Function(Article) onUpdate) async {
    for (var article in articles) {
      if (articleIds.contains(article.id)) {
        // 切换置顶状态
        final updatedArticle = article.copyWith(
          isPinned: !article.isPinned,
          pinnedAt: !article.isPinned ? DateTime.now() : null,
        );
        onUpdate(updatedArticle);
      }
    }
  }

  /// 处理删除操作
  Future<void> handleDelete(List<String> articleIds, Function(String) onDelete) async {
    final confirmed = await _showDeleteConfirmDialog(articleIds.length);
    if (confirmed == true) {
      for (var articleId in articleIds) {
        onDelete(articleId);
      }
    }
  }

  /// 显示删除确认对话框
  Future<bool?> _showDeleteConfirmDialog(int count) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除选中的 $count 篇文章吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 处理单个文章的置顶操作（用于 ArticleMenuManager）
  static Future<void> togglePinForSingle({
    required BuildContext context,
    required Article article,
    required Function(Article) onUpdate,
  }) async {
    final updatedArticle = article.copyWith(
      isPinned: !article.isPinned,
      pinnedAt: !article.isPinned ? DateTime.now() : null,
    );
    onUpdate(updatedArticle);

    // 显示提示
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(article.isPinned ? '已取消置顶' : '已置顶'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  /// 处理单个文章的删除操作（用于 ArticleMenuManager）
  static Future<bool?> deleteSingle({
    required BuildContext context,
    required Article article,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除「${article.title}」吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    return confirmed;
  }
}
