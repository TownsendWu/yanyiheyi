import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/article.dart';
import '../../providers/activity_provider.dart';
import '../../widgets/app_toast.dart';
import '../../utils/image_cache_manager.dart';

/// 文章详情页 (Notion 风格)
class ArticleDetailPage extends StatefulWidget {
  final Article article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  late TextEditingController _titleController;
  late Article _article;
  final FocusNode _titleFocusNode = FocusNode();

  // 本地缓存的图片路径
  String? _cachedImagePath;
  final ImageCacheManager _imageCacheManager = ImageCacheManager();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _article = widget.article;
    _titleController = TextEditingController(text: _article.title);
    // 初始化时加载缓存图片（延迟执行，避免阻塞启动）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCachedImage();
    });
  }

  /// 加载缓存的图片
  Future<void> _loadCachedImage() async {
    if (_article.coverImage == null || _article.coverImage!.isEmpty) {
      return;
    }

    // 在后台执行，避免阻塞主线程
    final cachedPath = await _imageCacheManager.getImage(_article.coverImage!);
    if (mounted) {
      setState(() {
        _cachedImagePath = cachedPath;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  /// 切换置顶状态
  Future<void> _togglePin() async {
    final activityProvider = context.read<ActivityProvider>();
    final newPinnedStatus = !_article.isPinned;

    await activityProvider.updateArticlePinnedStatus(
      _article.id,
      newPinnedStatus,
    );

    setState(() {
      _article = _article.copyWith(
        isPinned: newPinnedStatus,
        pinnedAt: newPinnedStatus ? DateTime.now() : null,
      );
    });

    if (mounted) {
      AppToast.showSuccess(newPinnedStatus ? '已置顶' : '已取消置顶');
    }
  }

  /// 添加或更新封面图
  Future<void> _add_or_update_cover_image() async {
    final theme = Theme.of(context);

    // 显示选项菜单
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 150,
        kToolbarHeight + MediaQuery.of(context).padding.top,
        MediaQuery.of(context).size.width,
        kToolbarHeight + MediaQuery.of(context).padding.top + 200,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'gallery',
          child: Row(
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 12),
              Text(
                '相册',
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'url',
          child: Row(
            children: [
              Icon(
                Icons.link_outlined,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 12),
              Text(
                'URL',
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        if (_article.coverImage != null)
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: theme.colorScheme.error.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 12),
                Text(
                  '删除',
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.colorScheme.error.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
      ],
    );

    if (result == null) return;

    switch (result) {
      case 'gallery':
        await _pickImageFromGallery();
        break;
      case 'url':
        await _inputImageUrl();
        break;
      case 'delete':
        await _deleteCoverImage();
        break;
    }
  }

  /// 从相册选择图片
  Future<void> _pickImageFromGallery() async {
    final activityProvider = context.read<ActivityProvider>();

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      // 将图片保存到缓存目录
      final imageFile = File(image.path);
      final cachedPath = await _imageCacheManager.saveLocalImage(imageFile);

      if (cachedPath != null) {
        // 更新文章的封面图（使用本地文件路径）
        await activityProvider.updateArticleCoverImage(_article.id, cachedPath);

        if (mounted) {
          setState(() {
            _article = _article.copyWith(coverImage: cachedPath);
            _cachedImagePath = cachedPath;
          });
          AppToast.showSuccess('封面图已更新');
        }
      } else {
        if (mounted) {
          AppToast.showError('保存图片失败');
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError('选择图片失败: $e');
      }
    }
  }

  /// 输入图片 URL
  Future<void> _inputImageUrl() async {
    final activityProvider = context.read<ActivityProvider>();
    final TextEditingController urlController = TextEditingController();

    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('输入图片 URL'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            hintText: 'https://example.com/image.jpg',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, urlController.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (url == null || url.isEmpty) return;

    try {
      // 下载并缓存图片
      AppToast.showInfo('正在下载图片...');
      final cachedPath = await _imageCacheManager.getImage(url);

      if (cachedPath != null) {
        // 更新文章的封面图（使用本地缓存路径）
        await activityProvider.updateArticleCoverImage(_article.id, cachedPath);

        if (mounted) {
          setState(() {
            _article = _article.copyWith(coverImage: cachedPath);
            _cachedImagePath = cachedPath;
          });
          AppToast.showSuccess('封面图已更新');
        }
      } else {
        if (mounted) {
          AppToast.showError('下载图片失败');
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError('下载图片失败: $e');
      }
    }
  }

  /// 删除封面图
  Future<void> _deleteCoverImage() async {
    final activityProvider = context.read<ActivityProvider>();

    // 删除缓存文件
    if (_cachedImagePath != null) {
      await _imageCacheManager.deleteCachedFile(_cachedImagePath!);
    }

    // 删除网络图片的缓存（如果原始是 URL）
    if (_article.coverImage != null &&
        _article.coverImage!.startsWith('http')) {
      await _imageCacheManager.deleteCachedImage(_article.coverImage!);
    }

    // 更新文章（删除 coverImage）
    await activityProvider.updateArticleCoverImage(_article.id, null);

    if (mounted) {
      setState(() {
        _article = _article.copyWith(coverImage: null);
        _cachedImagePath = null;
      });
      AppToast.showSuccess('封面图已删除');
    }
  }

  /// 显示更多选项菜单
  void _showMoreMenu(BuildContext context) {
    final theme = Theme.of(context);
    final isPinned = _article.isPinned;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 120,
        kToolbarHeight + MediaQuery.of(context).padding.top,
        MediaQuery.of(context).size.width,
        kToolbarHeight + MediaQuery.of(context).padding.top + 200,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'generate_card',
          child: Row(
            children: [
              Icon(
                Icons.style_outlined,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 12),
              Text(
                '生成文字卡片',
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'add_or_update_cover',
          child: Row(
            children: [
              Icon(
                Icons.style_outlined,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 12),
              Text(
                '添加/更换背景',
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'add_tag',
          child: Row(
            children: [
              Icon(
                Icons.label_outline,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 12),
              Text(
                '添加标签',
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'pin',
          child: Row(
            children: [
              Icon(
                isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                size: 20,
                color: isPinned
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 12),
              Text(
                isPinned ? '取消置顶' : '置顶',
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: 20,
                color: theme.colorScheme.error.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 12),
              Text(
                '删除',
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.error.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        _handleMenuAction(value);
      }
    });
  }

  /// 处理菜单选项点击
  void _handleMenuAction(String action) {
    switch (action) {
      case 'generate_card':
        // TODO: 实现生成文字卡片功能
        print('生成文字卡片');
        break;
      case 'add_or_update_cover':
        _add_or_update_cover_image();
        break;
      case 'add_tag':
        // TODO: 实现添加标签功能
        print('添加标签');
        break;
      case 'pin':
        _togglePin();
        break;
      case 'delete':
        // TODO: 实现删除功能
        print('删除');
        break;
    }
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
              expandedHeight: _cachedImagePath != null ? 100 : 0,
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
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 24,
                  ),
                  onPressed: () => _showMoreMenu(context),
                  padding: const EdgeInsets.only(right: 16),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ],
              flexibleSpace: _cachedImagePath != null
                  ? FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(_cachedImagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
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
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                    decoration: TextDecoration.underline,
                                    decorationColor: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                              // 逗号分隔符（最后一个标签不加）
                              if (!isLast)
                                Text(
                                  '，',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
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
