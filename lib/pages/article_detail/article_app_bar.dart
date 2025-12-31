import 'package:flutter/material.dart';
import 'dart:io';

/// 文章详情页 AppBar（支持背景图）
class ArticleAppBar extends StatelessWidget {
  final String? cachedImagePath;
  final VoidCallback onBackPress;
  final VoidCallback onMenuPress;

  const ArticleAppBar({
    super.key,
    this.cachedImagePath,
    required this.onBackPress,
    required this.onMenuPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: cachedImagePath != null ? 120 : 0,
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
        onPressed: onBackPress,
        padding: const EdgeInsets.only(left: 16),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
      actions: [
        GestureDetector(
          onTap: onMenuPress,
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
      flexibleSpace: cachedImagePath != null
          ? FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(cachedImagePath!),
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
