import 'package:flutter/material.dart';
import '../../data/models/article.dart';
import '../../widgets/article_action_handler.dart';
import 'bottom_sheet_menu.dart';
import 'cover_image_manager.dart';

/// 文章菜单管理器
class ArticleMenuManager {
  final BuildContext context;
  Article article;
  final CoverImageManager coverImageManager;
  final Function(Article) onArticleUpdated;
  final Function(String)? onArticleDeleted;

  ArticleMenuManager({
    required this.context,
    required this.article,
    required this.coverImageManager,
    required this.onArticleUpdated,
    this.onArticleDeleted,
  });

  /// 显示更多选项菜单
  Future<void> showMoreMenu() async {
    final isPinned = article.isPinned;

    final result = await showCustomBottomSheet<String>(
      context: context,
      items: [
        BottomSheetMenuItem(
          icon: Icons.style_outlined,
          label: '生成文字卡片',
          onTap: () => Navigator.pop(context, 'generate_card'),
        ),
        BottomSheetMenuItem(
          icon: Icons.image_outlined,
          label: '添加/更换背景',
          onTap: () => Navigator.pop(context, 'add_or_update_cover'),
        ),
        BottomSheetMenuItem(
          icon: Icons.label_outline,
          label: '添加标签',
          onTap: () => Navigator.pop(context, 'add_tag'),
        ),
        BottomSheetMenuItem(
          icon: isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          label: isPinned ? '取消置顶' : '置顶',
          onTap: () => Navigator.pop(context, 'pin'),
          iconColor: isPinned ? Theme.of(context).colorScheme.primary : null,
        ),
        BottomSheetMenuItem(
          icon: Icons.delete_outline,
          label: '删除',
          onTap: () => Navigator.pop(context, 'delete'),
          isDestructive: true,
        ),
      ],
    );

    if (result == null) return;

    await _handleMenuAction(result);
  }

  /// 处理菜单选项点击
  Future<void> _handleMenuAction(String action) async {
    switch (action) {
      case 'generate_card':
        // TODO: 实现生成文字卡片功能
        break;
      case 'add_or_update_cover':
        await coverImageManager.showOptions();
        break;
      case 'add_tag':
        _showAddTagPanel();
        break;
      case 'pin':
        await _handlePin();
        break;
      case 'delete':
        await _handleDelete();
        break;
    }
  }

  /// 处理置顶操作 - 使用公共处理器
  Future<void> _handlePin() async {
    await ArticleActionHandler.togglePinForSingle(
      context: context,
      article: article,
      onUpdate: (updatedArticle) {
        article = updatedArticle;
        onArticleUpdated(updatedArticle);
      },
    );
  }

  /// 处理删除操作 - 使用公共处理器
  Future<void> _handleDelete() async {
    final confirmed = await ArticleActionHandler.deleteSingle(
      context: context,
      article: article,
    );

    if (confirmed == true && onArticleDeleted != null) {
      onArticleDeleted!(article.id);
      if (context.mounted) {
        Navigator.pop(context); // 返回上一页
      }
    }
  }

  /// 显示添加标签面板
  void _showAddTagPanel() {
    // TODO: 实现添加标签功能
  }
}
