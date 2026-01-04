import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/article.dart';
import '../../providers/activity_provider.dart';
import '../../widgets/article_action_handler.dart';
import '../../widgets/app_toast.dart';
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
  Future<void> _showAddTagPanel() async {
    final activityProvider = context.read<ActivityProvider>();
    final TextEditingController tagController = TextEditingController();

    // 创建当前标签的副本（用于内存中的修改）
    final List<String> currentTags = List.from(article.tags);

    final theme = Theme.of(context);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 顶部指示条
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // 标题
                  Text(
                    '管理标签',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 当前标签列表
                  if (currentTags.isNotEmpty) ...[
                    Text(
                      '当前文章的标签',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: currentTags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setModalState(() {
                              currentTags.remove(tag);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 输入框
                  TextField(
                    controller: tagController,
                    decoration: InputDecoration(
                      hintText: '多个标签用空格隔开',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    ),
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 16),

                  // 确定按钮
                  FilledButton(
                    onPressed: () async {
                      final inputText = tagController.text.trim();

                      // 解析输入的标签（按空格分割）
                      if (inputText.isNotEmpty) {
                        final newTags = inputText.split(RegExp(r'\s+'));
                        setModalState(() {
                          // 去重：只添加不存在的标签
                          for (final tag in newTags) {
                            if (tag.isNotEmpty && !currentTags.contains(tag)) {
                              currentTags.add(tag);
                            }
                          }
                        });
                      }

                      // 更新文章标签
                      await activityProvider.updateArticleTags(article.id, currentTags);

                      if (context.mounted) {
                        article = article.copyWith(tags: currentTags);
                        onArticleUpdated(article);
                        AppToast.showSuccess('标签已更新');
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('确认'),
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
