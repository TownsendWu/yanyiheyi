import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

class ArticleContent extends StatefulWidget {
  // QuillController 从外部传入
  final QuillController controller;
  final ScrollController scrollController;
  final bool readOnly; // 可选：通常展示文章内容时可能是只读的
  final FocusNode focusNode;
  final VoidCallback? onTap; // 新增
  final GlobalKey quillEditorGlobalKey; // 新增：从外部传入的 GlobalKey

  const ArticleContent({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.focusNode,
    this.readOnly = false,
    this.onTap, // 新增
    required this.quillEditorGlobalKey, // 新增
  });

  @override
  State<ArticleContent> createState() => ArticleContentState();
}

class ArticleContentState extends State<ArticleContent> {
  //quill 相关配置 关键：用于获取 Editor 的 RenderObject
  // 使用外部传入的 GlobalKey
  GlobalKey get _quillEditorKey => widget.quillEditorGlobalKey;
  // OverlayEntry? _cursorButtonOverlay;

  // void _onFocusChange() {
  //   if (widget.focusNode.hasFocus) {
  //     _showCursorButton();
  //   } else {
  //     _hideCursorButton();
  //   }
  // }

  // void _onSelectionChange() {
  //   if (widget.focusNode.hasFocus) {
  //     _updateCursorButtonPosition();
  //   } else {
  //     _hideCursorButton();
  //   }
  // }

  // void _showCursorButton() {
  //   if (_cursorButtonOverlay != null) {
  //     _updateCursorButtonPosition();
  //     return;
  //   }

  //   _cursorButtonOverlay = OverlayEntry(
  //     builder: (context) => Positioned(
  //       left: 0,
  //       top: 0,
  //       child: _CursorButton(
  //         onPositionUpdate: (position) {
  //           _cursorButtonOverlay?.markNeedsBuild();
  //         },
  //         onTap: () {
  //           AppToast.showSuccess('光标按钮被点击了！');
  //         },
  //       ),
  //     ),
  //   );

  //   Overlay.of(context).insert(_cursorButtonOverlay!);
  //   _updateCursorButtonPosition();
  // }

  // void _hideCursorButton() {
  //   _cursorButtonOverlay?.remove();
  //   _cursorButtonOverlay = null;
  // }

  // void _updateCursorButtonPosition() {
  //   if (_cursorButtonOverlay == null) return;

  //   final cursorRect = QuillUtils.getCursorPosition(
  //     editorKey: _quillEditorKey,
  //     controller: widget.controller,
  //   );

  //   if (cursorRect != null) {
  //     _cursorButtonOverlay!.remove();
  //     _cursorButtonOverlay = OverlayEntry(
  //       builder: (context) => Positioned(
  //         left: cursorRect.left + (cursorRect.width / 2) - 20,
  //         top: cursorRect.top - 50,
  //         child: _CursorButton(
  //           onPositionUpdate: (position) {},
  //           onTap: () {
  //             AppToast.showSuccess('光标按钮被点击了！');
  //           },
  //         ),
  //       ),
  //     );
  //     Overlay.of(context).insert(_cursorButtonOverlay!);
  //   }
  // }

  @override
  void initState() {
    super.initState();
    // widget.focusNode.addListener(_onFocusChange);
    // widget.controller.addListener(_onSelectionChange);
  }

  @override
  void dispose() {
    // widget.focusNode.removeListener(_onFocusChange);
    // widget.controller.removeListener(_onSelectionChange);
    // _hideCursorButton();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultTextStyle = DefaultTextStyle.of(context);

    return Listener(
      onPointerDown: widget.onTap != null
          ? (event) {
              // 使用 onPointerDown 而不是 onTap，因为 QuillEditor 可能会消费掉点击事件
              widget.onTap!();
            }
          : null,
      child: QuillEditor(
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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
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
