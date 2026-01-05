import 'dart:async';
import 'dart:convert';
import '../../data/models/article.dart';
import '../../providers/activity_provider.dart';
import '../../core/logger/app_logger.dart';

/// 文章编辑控制器 - 负责处理文章编辑的业务逻辑
///
/// 功能包括:
/// - 变更检测 (标题和内容)
/// - 自动保存 (带防抖)
/// - 与 Provider 的交互
class ArticleEditorController {
  // ==================== 构造函数和属性 ====================

  ArticleEditorController({
    required Article initialArticle,
    required ActivityProvider provider,
    required Function(Article) onArticleUpdated,
    required Function(String) onError,
  })  : _currentArticle = initialArticle,
        _provider = provider,
        _onArticleUpdated = onArticleUpdated,
        _onError = onError;

  // 当前文章对象
  Article _currentArticle;

  // Provider 引用
  final ActivityProvider _provider;

  // 回调函数
  final Function(Article) _onArticleUpdated;
  final Function(String) _onError;

  // 防抖定时器
  Timer? _titleSaveTimer;
  Timer? _contentSaveTimer;

  // ==================== Getters ====================

  /// 获取当前文章
  Article get currentArticle => _currentArticle;

  // ==================== 变更检测 ====================

  /// 检测标题是否有变化
  bool detectTitleChange(String newTitle) {
    final normalizedTitle = normalizeTitle(newTitle);
    return normalizedTitle != _currentArticle.title;
  }

  /// 检测内容是否有变化
  bool detectContentChange(List newDeltaJson) {
    // 如果当前内容不是 List 类型，认为有变化
    if (_currentArticle.content is! List) {
      return true;
    }

    // 比较两个 List 是否相同（都进行标准化后再比较）
    final normalizedOldContent = normalizeDeltaJson(_currentArticle.content as List);
    final normalizedNewContent = normalizeDeltaJson(newDeltaJson);

    return jsonEncode(normalizedOldContent) != jsonEncode(normalizedNewContent);
  }

  // ==================== 保存操作（带防抖）====================

  /// 调度标题保存（1秒防抖）
  Future<void> scheduleTitleSave(String newTitle) async {
    // 取消之前的定时器
    _titleSaveTimer?.cancel();

    // 设置新的定时器（1秒后保存）
    _titleSaveTimer = Timer(const Duration(seconds: 1), () async {
      await saveTitleImmediately(newTitle);
    });
  }

  /// 调度内容保存（2秒防抖）
  Future<void> scheduleContentSave(List deltaJson) async {
    // 取消之前的定时器
    _contentSaveTimer?.cancel();

    // 设置新的定时器（2秒后保存，因为内容变化更频繁）
    _contentSaveTimer = Timer(const Duration(seconds: 2), () async {
      await saveContentImmediately(deltaJson);
    });
  }

  /// 立即保存标题
  Future<void> saveTitleImmediately(String newTitle) async {
    final titleToSave = normalizeTitle(newTitle);

    // 检查是否真的有变化
    if (!detectTitleChange(titleToSave)) {
      return;
    }

    try {
      final now = DateTime.now();

      // 直接更新文章
      await _provider.updateArticleContent(
        _currentArticle.id,
        title: titleToSave,
      );

      // 更新本地文章对象
      _currentArticle = _currentArticle.copyWith(
        title: titleToSave,
        updatedAt: now,
      );
      _notifyArticleUpdated();
      appLogger.info('标题已保存: $titleToSave');
    } catch (e) {
      appLogger.error('保存标题失败', e);
      _onError('保存标题失败');
    }
  }

  /// 立即保存内容
  Future<void> saveContentImmediately(List deltaJson) async {
    // 检查是否真的有变化
    if (!detectContentChange(deltaJson)) {
      return;
    }

    try {
      final now = DateTime.now();

      // 直接更新文章
      await _provider.updateArticleContent(
        _currentArticle.id,
        content: deltaJson,
      );

      // 更新本地文章对象
      _currentArticle = _currentArticle.copyWith(
        content: deltaJson,
        updatedAt: now,
      );
      _notifyArticleUpdated();
      appLogger.info('内容已自动保存');
    } catch (e) {
      appLogger.error('保存内容失败', e);
      _onError('保存内容失败');
    }
  }

  /// 立即保存所有更改（用于页面离开时）
  Future<void> saveAllImmediately(String title, List content) async {
    // 取消所有待执行的定时器
    _titleSaveTimer?.cancel();
    _contentSaveTimer?.cancel();

    final titleToSave = normalizeTitle(title);

    // 检查是否为空内容
    final isTitleEmpty = titleToSave.isEmpty || titleToSave == 'Untitled';
    final isContentEmpty =
        content.isEmpty || (content.length == 1 && content[0]['insert'] == '\n');

    // 检查是否有背景图
    final hasCoverImage = _currentArticle.coverImage != null &&
        _currentArticle.coverImage!.isNotEmpty;

    // 只有在标题、内容、背景图都为空时，才删除文章
    if (isTitleEmpty && isContentEmpty && !hasCoverImage) {
      appLogger.info('文章无内容，删除文章');
      try {
        await _provider.deleteArticle(_currentArticle.id);
        appLogger.info('空文章已删除');
      } catch (e) {
        appLogger.error('删除文章失败', e);
      }
      return;
    }

    // 常规保存逻辑
    final titleChanged = detectTitleChange(titleToSave);
    final contentChanged = detectContentChange(content);

    // 如果有变化，立即保存
    if (titleChanged || contentChanged) {
      try {
        final now = DateTime.now();
        await _provider.updateArticleContent(
          _currentArticle.id,
          title: titleChanged ? titleToSave : null,
          content: contentChanged ? content : null,
        );

        _currentArticle = _currentArticle.copyWith(
          title: titleChanged ? titleToSave : _currentArticle.title,
          content: contentChanged ? content : _currentArticle.content,
          updatedAt: now,
        );

        appLogger.info('页面离开时已保存所有更改');
      } catch (e) {
        appLogger.error('保存更改失败', e);
        _onError('保存更改失败');
      }
    } else {
      appLogger.info('页面离开时无需保存，内容未变化');
    }
  }

  // ==================== 工具方法 ====================

  /// 标准化 Delta JSON（移除 Quill 自动添加的末尾换行符）
  List normalizeDeltaJson(List deltaJson) {
    if (deltaJson.isEmpty) return deltaJson;

    // 移除所有 insert 值末尾的 '\n'
    return deltaJson.map((op) {
      if (op is Map && op.containsKey('insert')) {
        final insert = op['insert'];
        if (insert is String && insert.endsWith('\n')) {
          // 移除末尾的 '\n'
          final newInsert = insert.substring(0, insert.length - 1);
          return {"insert": newInsert};
        }
      }
      return op;
    }).toList();
  }

  /// 标准化标题（如果为空，返回 "Untitled"）
  String normalizeTitle(String title) {
    final trimmed = title.trim();
    return trimmed.isEmpty ? 'Untitled' : trimmed;
  }

  // ==================== 生命周期管理 ====================

  /// 通知外部文章已更新
  void _notifyArticleUpdated() {
    _onArticleUpdated(_currentArticle);
  }

  /// 释放资源
  void dispose() {
    _titleSaveTimer?.cancel();
    _contentSaveTimer?.cancel();
  }
}
