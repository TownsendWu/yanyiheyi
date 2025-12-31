// import 'package:flutter/material.dart';

// /// 文章内容组件
// class ArticleContent extends StatelessWidget {
//   final String? content;

//   const ArticleContent({super.key, required this.content});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Text(
//       content ?? '暂无内容',
//       style: TextStyle(
//         fontSize: 16,
//         height: 1.8,
//         color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
//         letterSpacing: 0.3,
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

// 假设 MyQuillEditor 定义在同文件或已导入
// import 'path/to/my_quill_editor.dart';

class ArticleContent extends StatefulWidget {
  // 这里的 content 应当是 Quill 的 JSON Delta 字符串
  final String? content;
  final ScrollController scrollController;
  final bool readOnly; // 可选：通常展示文章内容时可能是只读的

  const ArticleContent({
    super.key,
    required this.content,
    required this.scrollController,
    this.readOnly = false,
  });

  @override
  State<ArticleContent> createState() => _ArticleContentState();
}

class _ArticleContentState extends State<ArticleContent> {
  late final QuillController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    Document doc;
    try {
      if (widget.content != null && widget.content!.isNotEmpty) {
        // 1. 尝试将字符串解析为 JSON
        final dynamic json = jsonDecode(widget.content!);
        // 2. 将 JSON 转换为 Quill Document
        doc = Document.fromJson(json);
      } else {
        doc = Document();
      }
    } catch (e) {
      // 容错处理：如果解析失败（比如传入的是纯文本而不是JSON），则作为普通文本插入
      doc = Document()..insert(0, widget.content ?? '暂无内容');
      debugPrint('Error parsing Quill JSON: $e');
    }

    _controller = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
      // 如果是只读模式，通常这里不需要做太多配置，主要在 EditorConfig 控制
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTextStyle = DefaultTextStyle.of(context);

    return Padding(
      padding: EdgeInsetsGeometry.only(top: 0.0),
      child: QuillEditor(
        focusNode: _focusNode,
        scrollController: widget.scrollController,
        controller: _controller,
        config: QuillEditorConfig(
          scrollable: false,
          padding: EdgeInsetsGeometry.only(bottom: 20),
          placeholder: 'Start writing your notes...',
          customStyles: DefaultStyles(
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
