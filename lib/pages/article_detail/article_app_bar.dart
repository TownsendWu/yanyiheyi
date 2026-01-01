import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:io';

/// 文章详情页 AppBar（支持背景图）
class ArticleAppBar extends StatefulWidget {
  final String? cachedImagePath;
  final VoidCallback onBackPress;
  final VoidCallback onMenuPress;
  final QuillController? controller;

  const ArticleAppBar({
    super.key,
    this.cachedImagePath,
    required this.onBackPress,
    required this.onMenuPress,
    this.controller,
  });

  @override
  State<ArticleAppBar> createState() => _ArticleAppBarState();
}

class _ArticleAppBarState extends State<ArticleAppBar> {
  bool _hasUndo = false;
  bool _hasRedo = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _updateHistoryState();
      // 监听 controller 变化
      widget.controller!.changes.listen((_) {
        if (mounted) {
          setState(_updateHistoryState);
        }
      });
    }
  }

  void _updateHistoryState() {
    if (widget.controller != null) {
      _hasUndo = widget.controller!.hasUndo;
      _hasRedo = widget.controller!.hasRedo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasController = widget.controller != null;

    return SliverAppBar(
      expandedHeight: widget.cachedImagePath != null ? 120 : 0,
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
        onPressed: widget.onBackPress,
        padding: const EdgeInsets.only(left: 16),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
      actions: [
        // 撤销和重做按钮
        if (hasController) ...[
          _HistoryButton(
            icon: Icons.undo_outlined,
            tooltip: '撤销',
            onTap: () {
              if (widget.controller != null && widget.controller!.hasUndo) {
                widget.controller!.undo();
              }
            },
            canPress: _hasUndo,
          ),
          _HistoryButton(
            icon: Icons.redo_outlined,
            tooltip: '重做',
            onTap: () {
              if (widget.controller != null && widget.controller!.hasRedo) {
                widget.controller!.redo();
              }
            },
            canPress: _hasRedo,
          ),
        ],
        GestureDetector(
          onTap: widget.onMenuPress,
          child: Container(
            padding: const EdgeInsets.only(right: 16),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            child: Icon(
              Icons.more_horiz,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
          ),
        ),
      ],
      flexibleSpace: widget.cachedImagePath != null
          ? FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(widget.cachedImagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: theme.colorScheme.surfaceContainerHighest,
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
                          theme.colorScheme.surface.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

/// 历史记录按钮组件
class _HistoryButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool canPress;

  const _HistoryButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.canPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      icon: Icon(
        icon,
        color: canPress
            ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
            : theme.colorScheme.onSurface.withValues(alpha: 0.2),
        size: 20,
      ),
      onPressed: canPress ? onTap : null,
      tooltip: tooltip,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }
}
