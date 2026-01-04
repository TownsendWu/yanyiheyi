import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../data/models/article.dart';
import '../providers/activity_provider.dart';
import '../widgets/app_toast.dart';
import '../utils/image_cache_manager.dart';
import '../utils/quill_utils.dart';
import 'article_detail/article_app_bar.dart';
import 'article_detail/article_header.dart';
import 'article_detail/article_content.dart';
import 'article_detail/cover_image_manager.dart';
import 'article_detail/article_menu_manager.dart';
import 'article_detail/article_ai_panel.dart';

import 'package:chat_bottom_container/chat_bottom_container.dart';

// 自定义面板类型
enum PanelType {
  none,
  keyboard,
  formatting, // 文字格式化
  more, // 更多选项
  emoji, // 表情面板
  ai, // AI 面板
}

/// 文章详情页 (Notion 风格)
class ArticleDetailPage extends StatefulWidget {
  final Article article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  double? height;

  late TextEditingController _titleController;
  late QuillController _quillController;
  late Article _article;
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _quillFocusNode = FocusNode();

  // QuillEditor 的 GlobalKey，用于获取光标位置
  final GlobalKey _quillEditorGlobalKey = GlobalKey();

  //面板相关功能
  final ChatBottomPanelContainerController<PanelType> _panelController =
      ChatBottomPanelContainerController<PanelType>();

  PanelType _currentPanelType = PanelType.none;
  double _keyboardHeight = 300; // 默认键盘高度
  bool _isKeyboardVisible = false; // 键盘是否可见

  // 使用 WidgetsBinding 监听的键盘高度（更准确）
  double _systemKeyboardHeight = 0.0;

  // 本地缓存的图片路径
  String? _cachedImagePath;
  final ImageCacheManager _imageCacheManager = ImageCacheManager();
  final ImagePicker _imagePicker = ImagePicker();

  // 管理器
  late CoverImageManager _coverImageManager;
  late ArticleMenuManager _menuManager;

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

  // 监听焦点变化
  void _onFocusChange() {
    if (_quillFocusNode.hasFocus && !_isKeyboardVisible) {
      // TextField 获得焦点，延迟显示工具栏，等待键盘动画完成
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _quillFocusNode.hasFocus) {
          setState(() {
            _isKeyboardVisible = true;
          });
        }
      });
    } else if (!_quillFocusNode.hasFocus &&
        _currentPanelType == PanelType.none) {
      // TextField 失去焦点且没有面板，立即隐藏工具栏
      setState(() {
        _isKeyboardVisible = false;
      });
    }
  }

  // 监听光标位置变化
  void _onSelectionChanged() {
    // 只有在编辑器有焦点时才检查滚动
    if (_quillFocusNode.hasFocus) {
      // 延迟执行，确保布局已经更新
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _checkCursorAndScrollIfNeeded();
        }
      });
    }
  }

  // 切换面板
  void _switchPanel(PanelType type) {
    if (_currentPanelType == type) {
      // 如果点击的是当前面板，则唤起键盘
      setState(() {
        _currentPanelType = PanelType.keyboard;
      });
      _quillController.readOnly = false;
      _panelController.updatePanelType(ChatBottomPanelType.keyboard);
      // 延迟显示工具栏
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() {
            _isKeyboardVisible = true;
          });
        }
      });
    } else {
      // 切换到新面板
      if (type == PanelType.keyboard) {
        setState(() {
          _currentPanelType = type;
        });
        _quillController.readOnly = false;
        _panelController.updatePanelType(ChatBottomPanelType.keyboard);
        // 延迟显示工具栏
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            setState(() {
              _isKeyboardVisible = true;
            });
          }
        });
      } else {
        // 切换到自定义面板，设置只读并强制请求焦点
        setState(() {
          _currentPanelType = type;
        });
        _quillController.readOnly = true;

        // 等待下一帧，确保状态更新完成
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _panelController.updatePanelType(
              ChatBottomPanelType.other,
              data: type,
              forceHandleFocus: ChatBottomHandleFocus.requestFocus,
            );
            // 延迟显示工具栏
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                setState(() {
                  _isKeyboardVisible = true;
                });
              }
            });
          }
        });
      }
    }
  }

  // 隐藏面板
  void _hidePanel() {
    setState(() {
      _currentPanelType = PanelType.none;
      _isKeyboardVisible = false;
    });
    _quillController.readOnly = false;
    _quillFocusNode.unfocus();
    _panelController.updatePanelType(ChatBottomPanelType.none);
  }

  /// 检查光标位置并自动滚动，确保光标不被键盘和工具栏遮挡
  void _checkCursorAndScrollIfNeeded() {
    final rect = QuillUtils.getCursorPosition(
      editorKey: _quillEditorGlobalKey,
      controller: _quillController,
    );

    if (rect == null) {
      debugPrint('无法获取光标位置');
      return;
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = _systemKeyboardHeight + 40;
    final keyboardTopY = screenHeight - keyboardHeight;

    // 计算光标底部到键盘顶部的距离
    final cursorBottomY = rect.bottom;
    final distanceToKeyboard = keyboardTopY - cursorBottomY;

    debugPrint(
      '═══════════════════════════════════════\n'
      '光标位置检查：\n'
      '  屏幕高度: $screenHeight\n'
      '  键盘高度: $keyboardHeight\n'
      '  键盘顶部 Y 坐标: $keyboardTopY\n'
      '  光标底部 Y 坐标: $cursorBottomY\n'
      '  光标到键盘的距离: $distanceToKeyboard\n'
      '  光标完整位置: $rect\n'
      '═══════════════════════════════════════',
    );

    // 如果光标到键盘的距离小于 30，需要向上滚动
    if (distanceToKeyboard < 30) {
      final scrollOffset = _scrollController.offset;
      final needToScroll = 30 - distanceToKeyboard;

      debugPrint('光标距离键盘太近，向上滚动 $needToScroll 像素');

      _scrollController.animateTo(
        scrollOffset + needToScroll,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _article = widget.article;
    _titleController = TextEditingController(text: _article.title);

    // 添加 WidgetsBinding 观察者，监听键盘变化
    WidgetsBinding.instance.addObserver(this);

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

    // 2. 监听焦点变化，以便刷新 UI 显示工具栏
    _quillFocusNode.addListener(_onFocusChange);

    // 3. 监听光标位置变化，触发滚动检查
    _quillController.addListener(_onSelectionChanged);

    // 初始化时加载缓存图片（延迟执行，避免阻塞启动）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCachedImage();
    });
  }

  @override
  void dispose() {
    // 移除 WidgetsBinding 观察者
    WidgetsBinding.instance.removeObserver(this);
    _titleController.dispose();
    _quillController.dispose();
    _titleFocusNode.dispose();
    _quillFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // 当系统指标变化时（如键盘弹出/收起），获取键盘高度
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    setState(() {
      if (bottomInset > _systemKeyboardHeight) {
        _systemKeyboardHeight = bottomInset;
      }
      _isKeyboardVisible = bottomInset > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final editorBody = CustomScrollView(
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
                  focusNode: _quillFocusNode,
                  quillEditorGlobalKey: _quillEditorGlobalKey,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      // 设置背景色，底部安全区会使用这个颜色
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        // 点击空白区域收起键盘和面板
        onTap: () {
          if (_currentPanelType != PanelType.none || _quillFocusNode.hasFocus) {
            _hidePanel();
          }
        },
        child: Column(
          children: [
            Expanded(child: editorBody),

            // 工具栏 - 只在键盘可见或有面板时显示
            if (_isKeyboardVisible || _currentPanelType != PanelType.none)
              _buildToolbar(),

            // 底部面板容器
            _buildPanelContainer(),
          ],
        ),
      ),
    );
  }

  // 构建工具栏
  Widget _buildToolbar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          // 左侧 AI 功能区
          Expanded(
            child: AIFeatureButton(
              isSelected: _currentPanelType == PanelType.ai,
              onTap: () => _switchPanel(PanelType.ai),
            ),
          ),

          // 右侧图标按钮
          _ToolbarItem(
            icon: Icons.text_fields,
            isSelected: _currentPanelType == PanelType.formatting,
            onTap: () => _switchPanel(PanelType.formatting),
          ),
          _ToolbarItem(
            icon: Icons.more_horiz,
            isSelected: _currentPanelType == PanelType.more,
            onTap: () => _switchPanel(PanelType.more),
          ),
        ],
      ),
    );
  }

  // 构建底部面板容器
  Widget _buildPanelContainer() {
    return ChatBottomPanelContainer<PanelType>(
      controller: _panelController,
      inputFocusNode: _quillFocusNode,
      otherPanelWidget: (type) {
        if (type == null) return const SizedBox.shrink();

        switch (type) {
          case PanelType.formatting:
            return _buildFormattingPanel();
          case PanelType.more:
            return _buildMorePanel();
          case PanelType.ai:
            return _buildAIPanel();
          default:
            return const SizedBox.shrink();
        }
      },
      onPanelTypeChange: (panelType, data) {
        // 监听面板类型变化
        switch (panelType) {
          case ChatBottomPanelType.none:
            setState(() {
              _currentPanelType = PanelType.none;
              _isKeyboardVisible = false;
            });
            _quillController.readOnly = false;
            break;
          case ChatBottomPanelType.keyboard:
            setState(() {
              _currentPanelType = PanelType.keyboard;
              _isKeyboardVisible = true;
            });
            _quillController.readOnly = false;
            break;
          case ChatBottomPanelType.other:
            if (data != null) {
              setState(() {
                _currentPanelType = data;
                _isKeyboardVisible = true;
              });
              _quillController.readOnly = true;
            }
            break;
        }
      },
      panelBgColor: Colors.white,
      // 记录键盘高度，用于自定义面板
      changeKeyboardPanelHeight: (keyboardHeight) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && keyboardHeight != _keyboardHeight) {
            setState(() {
              _keyboardHeight = keyboardHeight;
            });
          }
        });
        return keyboardHeight;
      },
    );
  }

  // 文字格式化面板
  Widget _buildFormattingPanel() {
    return Container(
      height: _keyboardHeight,
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _FormatButton(
            icon: Icons.format_bold,
            label: '粗体',
            onTap: () {
              _quillController.formatSelection(Attribute.bold);
            },
          ),
          _FormatButton(
            icon: Icons.format_italic,
            label: '斜体',
            onTap: () {
              _quillController.formatSelection(Attribute.italic);
            },
          ),
          _FormatButton(
            icon: Icons.format_underlined,
            label: '下划线',
            onTap: () {
              _quillController.formatSelection(Attribute.underline);
            },
          ),
          _FormatButton(
            icon: Icons.format_strikethrough,
            label: '删除线',
            onTap: () {
              _quillController.formatSelection(Attribute.strikeThrough);
            },
          ),
          _FormatButton(
            icon: Icons.format_quote,
            label: '引用',
            onTap: () {
              _quillController.formatSelection(Attribute.blockQuote);
            },
          ),
          _FormatButton(
            icon: Icons.code,
            label: '代码',
            onTap: () {
              _quillController.formatSelection(Attribute.inlineCode);
            },
          ),
          _FormatButton(
            icon: Icons.link,
            label: '链接',
            onTap: () {
              // TODO: 实现链接插入功能
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('链接功能待实现')));
            },
          ),
        ],
      ),
    );
  }

  // 更多选项面板
  Widget _buildMorePanel() {
    return Container(
      height: _keyboardHeight,
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _FormatButton(
            icon: Icons.image,
            label: '图片',
            onTap: () {
              // TODO: 实现图片插入功能
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('图片功能待实现')));
            },
          ),
          _FormatButton(
            icon: Icons.folder_open,
            label: '文件',
            onTap: () {
              // TODO: 实现文件插入功能
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('文件功能待实现')));
            },
          ),
          _FormatButton(
            icon: Icons.list,
            label: '列表',
            onTap: () {
              _quillController.formatSelection(Attribute.ul);
            },
          ),
          _FormatButton(
            icon: Icons.format_list_numbered,
            label: '序号',
            onTap: () {
              _quillController.formatSelection(Attribute.ol);
            },
          ),
          _FormatButton(
            icon: Icons.table_chart,
            label: '表格',
            onTap: () {
              // TODO: 实现表格插入功能
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('表格功能待实现')));
            },
          ),
          _FormatButton(
            icon: Icons.check_box,
            label: '任务',
            onTap: () {
              _quillController.formatSelection(Attribute.checked);
            },
          ),
          _FormatButton(
            icon: Icons.horizontal_rule,
            label: '分割线',
            onTap: () {
              _quillController.document.insert(
                _quillController.selection.baseOffset,
                '\n',
              );
            },
          ),
          _FormatButton(
            icon: Icons.settings_outlined,
            label: '设置',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('设置功能待实现')));
            },
          ),
        ],
      ),
    );
  }

  // AI 面板
  Widget _buildAIPanel() {
    return AIPanel(
      height: _keyboardHeight,
      onContinue: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('AI 续写功能待实现')));
      },
      onSummarize: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('AI 总结功能待实现')));
      },
      onTranslate: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('AI 翻译功能待实现')));
      },
      onPolish: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('AI 润色功能待实现')));
      },
      onExpand: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('AI 扩写功能待实现')));
      },
      onContract: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('AI 缩写功能待实现')));
      },
    );
  }

  // 在光标位置插入文本
  void _insertText(String text) {
    final index = _quillController.selection.baseOffset;
    if (index == -1) return;

    _quillController.document.insert(index, text);
    _quillController.updateSelection(
      TextSelection.collapsed(offset: index + text.length),
      ChangeSource.local,
    );
  }
}

// 工具栏按钮
class _ToolbarItem extends StatelessWidget {
  final IconData icon;
  final String? label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToolbarItem({
    required this.icon,
    this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey[700],
              size: 20,
            ),
            if (label != null) ...[
              const SizedBox(height: 2),
              Text(
                label!,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.blue : Colors.grey[700],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 格式化按钮
class _FormatButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FormatButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey[700]),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
