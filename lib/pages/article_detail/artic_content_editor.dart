import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

class MyQuillEditor extends StatelessWidget {
  final QuillController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;

  const MyQuillEditor({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // QuillSimpleToolbar(
        //   controller: controller,
        //   config: QuillSimpleToolbarConfig(
        //     embedButtons: FlutterQuillEmbeds.toolbarButtons(),
        //     showClipboardPaste: true,
        //     customButtons: [
        //       QuillToolbarCustomButtonOptions(
        //         icon: const Icon(Icons.add_alarm_rounded),
        //         onPressed: () => _insertTimeStamp(controller),
        //       ),
        //     ],
        //     buttonOptions: QuillSimpleToolbarButtonOptions(
        //       base: QuillToolbarBaseButtonOptions(
        //         afterButtonPressed: () {
        //           final isDesktop = {
        //             TargetPlatform.linux,
        //             TargetPlatform.windows,
        //             TargetPlatform.macOS
        //           }.contains(defaultTargetPlatform);
        //           if (isDesktop) {
        //             focusNode.requestFocus();
        //           }
        //         },
        //       ),
        //       linkStyle: QuillToolbarLinkStyleButtonOptions(
        //         validateLink: (link) => true,
        //       ),
        //     ),
        //   ),
        // ),
        Flexible(
          child: QuillEditor(
            focusNode: focusNode,
            scrollController: scrollController,
            controller: controller,
            config: QuillEditorConfig(
              placeholder: 'Start writing your notes...',
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
        ),
      ],
    );
  }

  // 将插入时间戳的逻辑封装在组件内部的辅助方法中
  void _insertTimeStamp(QuillController controller) {
    controller.document.insert(
      controller.selection.extentOffset,
      TimeStampEmbed(
        DateTime.now().toString(),
      ),
    );

    controller.updateSelection(
      TextSelection.collapsed(
        offset: controller.selection.extentOffset + 1,
      ),
      ChangeSource.local,
    );
  }
}

class TimeStampEmbed extends Embeddable {
  const TimeStampEmbed(
    String value,
  ) : super(timeStampType, value);

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
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    return Row(
      children: [
        const Icon(Icons.access_time_rounded),
        Text(embedContext.node.value.data as String),
      ],
    );
  }
}