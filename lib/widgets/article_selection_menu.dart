import 'package:flutter/material.dart';

/// 文章多选底部菜单组件
class ArticleSelectionMenu extends StatelessWidget {
  final int selectedCount;
  final int totalCount; // 总文章数量
  final VoidCallback onPin;
  final VoidCallback onDelete;
  final VoidCallback onCancel;
  final VoidCallback onSelectAll; // 全选/取消全选回调

  const ArticleSelectionMenu({
    super.key,
    required this.selectedCount,
    required this.totalCount,
    required this.onPin,
    required this.onDelete,
    required this.onCancel,
    required this.onSelectAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 取消按钮
              TextButton(onPressed: onCancel, child: const Text('取消')),
              const SizedBox(width: 4),
              // 选中数量提示
              Expanded(
                child: Text(
                  '已选中 $selectedCount 篇',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 全选按钮
              _MenuButton(
                icon: selectedCount == totalCount
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                label: selectedCount == totalCount ? '全选' : '全选',
                onTap: onSelectAll,
              ),
              const SizedBox(width: 8),
              // 置顶按钮
              _MenuButton(icon: Icons.push_pin, label: '置顶', onTap: onPin),
              const SizedBox(width: 8),
              // 删除按钮
              _MenuButton(
                icon: Icons.delete_outline,
                label: '删除',
                onTap: onDelete,
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 菜单按钮组件
class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isDestructive
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDestructive
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
