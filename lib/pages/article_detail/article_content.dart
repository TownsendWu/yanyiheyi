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

  const ArticleContent({
    super.key,
    required this.controller,
    required this.scrollController,
    this.readOnly = false,
  });

  @override
  State<ArticleContent> createState() => ArticleContentState();
}

class ArticleContentState extends State<ArticleContent> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTextStyle = DefaultTextStyle.of(context);

    return QuillEditor(
      focusNode: _focusNode,
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
              null
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
