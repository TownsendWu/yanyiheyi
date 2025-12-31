import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models/article.dart';
import '../providers/activity_provider.dart';
import '../widgets/app_toast.dart';
import '../utils/image_cache_manager.dart';
import 'article_detail/article_app_bar.dart';
import 'article_detail/article_header.dart';
import 'article_detail/article_content.dart';
import 'article_detail/cover_image_manager.dart';
import 'article_detail/article_menu_manager.dart';

/// 文章详情页 (Notion 风格)
class ArticleDetailPage extends StatefulWidget {
  final Article article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  final GlobalKey _key = GlobalKey();
  double? height;

  late TextEditingController _titleController;
  late Article _article;
  final FocusNode _titleFocusNode = FocusNode();

  // 本地缓存的图片路径
  String? _cachedImagePath;
  final ImageCacheManager _imageCacheManager = ImageCacheManager();
  final ImagePicker _imagePicker = ImagePicker();

  // 管理器
  late CoverImageManager _coverImageManager;
  late ArticleMenuManager _menuManager;

  @override
  void initState() {
    super.initState();
    _article = widget.article;
    _titleController = TextEditingController(text: _article.title);

    // 初始化管理器
    _coverImageManager = CoverImageManager(
      context: context,
      article: _article,
      imagePicker: _imagePicker,
      imageCacheManager: _imageCacheManager,
      onArticleUpdated: _updateArticle,
    );

    _menuManager = ArticleMenuManager(
      context: context,
      article: _article,
      coverImageManager: _coverImageManager,
      onArticleUpdated: _updateArticle,
      onArticleDeleted: _handleArticleDeleted,
    );

    // 初始化时加载缓存图片（延迟执行，避免阻塞启动）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCachedImage();
      _getHeight();
    });
  }

  void _getHeight() {
    final RenderBox renderBox = _key.currentContext?.findRenderObject() as RenderBox;
    setState(() {
      height = renderBox.size.height;
    });
    print('组件高度: $height');
  }

  /// 更新文章状态
  void _updateArticle(Article newArticle, {String? newImagePath}) {
    // 如果置顶状态发生变化，需要同步到 Provider
    if (newArticle.isPinned != _article.isPinned) {
      final activityProvider = context.read<ActivityProvider>();
      activityProvider.updateArticlePinnedStatus(
        newArticle.id,
        newArticle.isPinned,
      );
    }

    // 如果封面图更新了，需要同步到 Provider
    if (newArticle.coverImage != _article.coverImage) {
      final activityProvider = context.read<ActivityProvider>();
      activityProvider.updateArticleCoverImage(
        newArticle.id,
        newArticle.coverImage,
      );
    }

    setState(() {
      _article = newArticle;
      // 如果有新的图片路径，直接使用（避免异步加载导致延迟显示）
      if (newImagePath != null) {
        _cachedImagePath = newImagePath;
      } else if (newArticle.coverImage == null) {
        // 删除背景图
        _cachedImagePath = null;
      } else if (newArticle.coverImage != _article.coverImage) {
        // 其他情况（如从 URL 加载），触发异步加载
        _loadCachedImage();
      }
    });
  }

  /// 加载缓存的图片
  Future<void> _loadCachedImage() async {
    if (_article.coverImage == null || _article.coverImage!.isEmpty) {
      return;
    }

    debugPrint('_loadCachedImage: ${_article.coverImage}');

    // 在后台执行，避免阻塞主线程
    final cachedPath = await _imageCacheManager.getImage(_article.coverImage!);
    debugPrint('_loadCachedImage: $cachedPath');
    if (mounted) {
      setState(() {
        _cachedImagePath = cachedPath;
      });
    }
  }

  /// 处理文章删除
  void _handleArticleDeleted(String articleId) {
    final activityProvider = context.read<ActivityProvider>();
    activityProvider.deleteArticle(articleId);
    if (mounted) {
      AppToast.showSuccess('文章已删除');
    }
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
    // 打印页面高度
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    debugPrint('页面高度: $screenHeight, 宽度: $screenWidth');

    // 构建主体内容（CustomScrollView）
    // 这里定义了一个自定义滚动
    final body = CustomScrollView(
      slivers: [
        // App Bar with back button and more options
        // 这是AppBart
        ArticleAppBar(
          cachedImagePath: _cachedImagePath,
          onBackPress: () => Navigator.pop(context),
          onMenuPress: () => _menuManager.showMoreMenu(),
        ),

        // 内容区域
        SliverFillRemaining(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            // 这里用了一个Column组件
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 这应该是顶部的图片
                ArticleHeader(
                  article: _article,
                  titleController: _titleController,
                  titleFocusNode: _titleFocusNode,
                ),
                // 这个是内容
                ArticleContent(content: _article.content),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );

    return GestureDetector(
      key: _key,
      // 点击空白区域时取消焦点
      onTap: () {
        _titleFocusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        // 这个配置运行页面往上推
        // resizeToAvoidBottomInset: true,
        body: body,
      ),
    );
  }
}
