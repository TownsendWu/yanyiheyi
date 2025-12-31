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
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import './artic_content_editor.dart';

// 假设 MyQuillEditor 定义在同文件或已导入
// import 'path/to/my_quill_editor.dart';

class ArticleContent extends StatefulWidget {
  // 这里的 content 应当是 Quill 的 JSON Delta 字符串
  final String? content;
  final bool readOnly; // 可选：通常展示文章内容时可能是只读的

  const ArticleContent({
    super.key,
    required this.content,
    this.readOnly = false,
  });

  @override
  State<ArticleContent> createState() => _ArticleContentState();
}

class _ArticleContentState extends State<ArticleContent> {
  late final QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 这里使用一个固定高度的盒子，导致页面往上推的时候压缩不了，应该使用Expanded
    // 但是使用Expanded时 父容器要是一个有限高度的容量，也就是外层Column
    // 但是外层的Column 又是在一个滚动组件内，高度无法确定，导致无法使用Expanded
    return Expanded(
      child: MyQuillEditor(
        controller: _controller,
        focusNode: _focusNode,
        scrollController: _scrollController,
      ),
    );
  }
}
