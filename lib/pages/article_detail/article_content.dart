import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

// 假设 MyQuillEditor 定义在同文件或已导入
// import 'path/to/my_quill_editor.dart';

class ArticleContent extends StatefulWidget {
  // QuillController 从外部传入
  final QuillController controller;
  final ScrollController scrollController;
  final bool readOnly; // 可选：通常展示文章内容时可能是只读的
  final bool isKeyboardVisible;
  final FocusNode focusNode;

  const ArticleContent({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.isKeyboardVisible,
    required this.focusNode,
    this.readOnly = false,
  });

  @override
  State<ArticleContent> createState() => ArticleContentState();
}

class ArticleContentState extends State<ArticleContent> {
  //quill 相关配置 关键：用于获取 Editor 的 RenderObject
  final GlobalKey _quillEditorKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  // 可选：如果你想用 CompositedTransformFollower
  final LayerLink _layerLink = LayerLink();

  // 核心逻辑：计算位置并显示/移动 Overlay
  void _updateAiButtonPosition() {
    // 1. 如果没有焦点或没有选区，隐藏按钮
    if (!widget.focusNode.hasFocus) {
      debugPrint("没有焦点或没有选区，隐藏按钮");
      _removeOverlay();
      return;
    }

    // 2. 获取 Editor 的 RenderObject
    // 注意：在较新版本的 flutter_quill 中，QuillEditor 可能包含多层嵌套
    // 这里我们尝试通过 GlobalKey 获取 context 进而拿到 RenderBox
    final currentState = _quillEditorKey.currentState;
    final BuildContext? editorContext = _quillEditorKey.currentContext;
    if (editorContext == null) return;

    final RenderBox? renderBox = editorContext.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // _showOverlay(editorContext);
  }

  // 显示悬浮按钮
  void _showOverlay(BuildContext context) {
    // 获取编辑器相对于屏幕的位置
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final editorOffset = renderBox.localToGlobal(Offset.zero);

    // *获取光标的真实像素位置*
    // 这通常最难，因为 QuillController 只给字符索引。
    // 在 flutter_quill 中，你可以通过 editorKey.currentState 访问。
    // 具体的 API 调用如下：

    Offset? cursorOffset;

    try {
      // 这是一个通用的 hack 方法，适用于 flutter_quill > 8.x
      // 获取底层的 RenderEditable
      final dynamic state = _quillEditorKey.currentState;

      // 注意：不同版本属性名可能不同，常见为 renderEditor 或 editableTextKey
      if (state != null) {
        // 获取选区的端点（通常是两个点：起点和终点）
        // 注意：这需要 import 'package:flutter/rendering.dart';
        // 并且需要根据具体的 flutter_quill 版本适配

        // 如果无法直接获取，我们通常会展示在选区的一侧，或者使用一种折中方案：
        // 暂时将按钮显示在编辑器顶部或跟随整个 Widget。

        // 为了回答你的问题，假设我们能调用 getEndpointsForSelection：
        // List<TextSelectionPoint> endpoints = state.renderEditor.getEndpointsForSelection(_controller.selection);
        // cursorOffset = endpoints.last.point; // 获取光标末尾位置
      }
    } catch (e) {
      print("无法获取精确光标位置: $e");
    }

    // 如果无法获取精确位置（因为API私有），这里演示如何显示在编辑器顶部作为 fallback
    // 实际项目中，建议 Fork 源码把 getEndpointsForSelection 暴露出来，或者使用 library 提供的 helper
    final overlayPosition = cursorOffset != null
        ? renderBox.localToGlobal(cursorOffset)
        : editorOffset + const Offset(50, 0); // 默认位置

    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: overlayPosition.dy - 50, // 显示在光标上方 50 像素
          left: overlayPosition.dx,
          child: Material(
            color: Colors.transparent,
            child: FloatingActionButton.extended(
              onPressed: () {
                print("AI 按钮点击");
              },
              label: const Text("AI 润色"),
              icon: const Icon(Icons.auto_awesome),
            ),
          ),
        ),
      );
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      // 如果已经存在，虽然 OverlayEntry 不支持直接 setState，
      // 但通常我们会重新构建它或者使用 ValueNotifier 包裹 Positioned 的位置参数来优化性能。
      // 为简单起见，这里先 remove 再 add (生产环境建议用 markNeedsBuild)
      _overlayEntry!.remove();
      _overlayEntry = null;
      _showOverlay(context);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void initState() {
    super.initState();
    // 监听选区变化
    // widget.controller.addListener(_updateAiButtonPosition);
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultTextStyle = DefaultTextStyle.of(context);

    return QuillEditor(
      key: _quillEditorKey,
      focusNode: widget.focusNode,
      scrollController: widget.scrollController,
      controller: widget.controller,
      config: QuillEditorConfig(
        scrollable: false,
        padding: EdgeInsetsGeometry.only(bottom: 20),
        placeholder: '今天从哪里开始呢...',
        customStyles: DefaultStyles(
          placeHolder: DefaultTextBlockStyle(
            defaultTextStyle.style.copyWith(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
            ),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(0, 0),
            const VerticalSpacing(0, 0),
            null,
          ),
          paragraph: DefaultTextBlockStyle(
            defaultTextStyle.style.copyWith(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
            ),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(0, 0),
            const VerticalSpacing(0, 0),
            null,
          ),
          h1: DefaultTextBlockStyle(
            defaultTextStyle.style.copyWith(
              fontSize: 32,
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(16, 8),
            const VerticalSpacing(0, 0),
            null,
          ),
          h2: DefaultTextBlockStyle(
            defaultTextStyle.style.copyWith(
              fontSize: 24,
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(8, 4),
            const VerticalSpacing(0, 0),
            null,
          ),
          h3: DefaultTextBlockStyle(
            defaultTextStyle.style.copyWith(
              fontSize: 20,
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(8, 4),
            const VerticalSpacing(0, 0),
            null,
          ),
          lists: DefaultListBlockStyle(
            defaultTextStyle.style.copyWith(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
              height: 1.8,
            ),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(0, 4),
            const VerticalSpacing(0, 0),
            null,
            null,
          ),
          quote: DefaultTextBlockStyle(
            defaultTextStyle.style.copyWith(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(8, 4),
            const VerticalSpacing(0, 0),
            null,
          ),
          code: DefaultTextBlockStyle(
            defaultTextStyle.style.copyWith(
              fontSize: 14,
              color: theme.colorScheme.onSurface,
              fontFamily: 'monospace',
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(8, 4),
            const VerticalSpacing(0, 0),
            null,
          ),
        ),
        embedBuilders: [
          ...FlutterQuillEmbeds.editorBuilders(
            imageEmbedConfig: QuillEditorImageEmbedConfig(
              imageProviderBuilder: (context, imageUrl) {
                if (imageUrl.startsWith('assets/')) {
                  return AssetImage(imageUrl);
                }
                return null;
              },
            ),
            videoEmbedConfig: QuillEditorVideoEmbedConfig(
              customVideoBuilder: (videoUrl, readOnly) {
                return null;
              },
            ),
          ),
          TimeStampEmbedBuilder(),
        ],
      ),
    );
  }
}

class TimeStampEmbed extends Embeddable {
  const TimeStampEmbed(String value) : super(timeStampType, value);

  static const String timeStampType = 'timeStamp';

  static TimeStampEmbed fromDocument(Document document) =>
      TimeStampEmbed(jsonEncode(document.toDelta().toJson()));

  Document get document => Document.fromJson(jsonDecode(data));
}

class TimeStampEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'timeStamp';

  @override
  String toPlainText(Embed node) {
    return node.value.data;
  }

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    return Row(
      children: [
        const Icon(Icons.access_time_rounded),
        Text(embedContext.node.value.data as String),
      ],
    );
  }
}
