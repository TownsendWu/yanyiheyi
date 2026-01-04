import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// QuillEditor 相关工具函数
class QuillUtils {
  /// 获取 QuillEditor 光标的物理位置（相对于屏幕）
  ///
  /// 参数:
  /// - [editorKey]: QuillEditor 的 GlobalKey
  /// - [controller]: QuillController 实例
  ///
  /// 返回:
  /// - Rect: 光标的位置和尺寸矩形，如果无法获取则返回 null
  ///
  /// 实现原理:
  /// 1. 从 editorKey.currentState 获取 QuillEditorState
  /// 2. 遍历 RenderObject 树查找 RenderEditor
  /// 3. 调用 renderEditor.getLocalRectForCaret() 获取光标局部位置
  /// 4. 转换为全局坐标
  static Rect? getCursorPosition({
    required GlobalKey editorKey,
    required QuillController controller,
  }) {
    try {
      // 步骤 1: 从 editorKey 获取 QuillEditorState
      final State<StatefulWidget>? state = editorKey.currentState;
      if (state == null || state is! QuillEditorState) {
        debugPrint('无法获取 QuillEditorState');
        return null;
      }

      // 步骤 2: 遍历 RenderObject 树查找 RenderEditor
      // 注意：由于 _selectionGestureDetectorBuilder 是私有的，我们直接遍历查找 RenderEditor
      final RenderObject? renderObject = editorKey.currentContext?.findRenderObject();
      if (renderObject == null || !renderObject.attached) {
        return null;
      }

      // 遍历 RenderObject 树查找 RenderEditor
      RenderEditor? renderEditor;
      void visitRenderObject(RenderObject object) {
        if (object is RenderEditor) {
          renderEditor = object;
          return;
        }
        object.visitChildren((child) {
          visitRenderObject(child);
        });
      }

      visitRenderObject(renderObject);

      if (renderEditor == null) {
        debugPrint('无法获取 RenderEditor');
        return null;
      }

      // 步骤 3 & 4: 调用 renderEditor 的方法获取光标位置
      final int offset = controller.selection.baseOffset;
      final TextPosition textPosition = TextPosition(offset: offset);

      // 获取局部坐标的光标位置
      final Rect localRect = renderEditor!.getLocalRectForCaret(textPosition);

      // 转换为全局坐标
      final Offset globalOffset = renderEditor!.localToGlobal(localRect.topLeft);
      final Rect globalRect = Rect.fromLTWH(
        globalOffset.dx,
        globalOffset.dy,
        localRect.width,
        localRect.height,
      );

      return globalRect;
    } catch (e) {
      debugPrint('获取光标位置失败: $e');
      return null;
    }
  }
}