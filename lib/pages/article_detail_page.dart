import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quill/flutter_quill.dart';
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
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _key = GlobalKey();
  double? height;

  late TextEditingController _titleController;
  late QuillController _quillController;
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

    // 初始化 QuillController
    _initQuillController();

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
    });
  }

  /// 初始化 QuillController
  void _initQuillController() {
    Document doc;
    try {
      if (_article.content != null && _article.content!.isNotEmpty) {
        final dynamic json = jsonDecode(_article.content!);
        doc = Document.fromJson(json);
      } else {
        doc = Document();
      }
    } catch (e) {
      doc = Document()..insert(0, _article.content ?? '');
      debugPrint('Error parsing Quill JSON: $e');
    }

    _quillController = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
    _quillController.document.history.clear();
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
    _quillController.dispose();
    _titleFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 构建主体内容（CustomScrollView）
    // 这里定义了一个自定义滚动
    final body = CustomScrollView(
      controller: _scrollController,
      slivers: [
        // App Bar with back button and more options
        ArticleAppBar(
          cachedImagePath: _cachedImagePath,
          onBackPress: () => Navigator.pop(context),
          onMenuPress: () => _menuManager.showMoreMenu(),
          controller: _quillController,
        ),

        // 内容区域
        SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ArticleHeader(
                    article: _article,
                    titleController: _titleController,
                    titleFocusNode: _titleFocusNode,
                  ),
                  ArticleContent(
                    controller: _quillController,
                    scrollController: _scrollController,
                  ),
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
