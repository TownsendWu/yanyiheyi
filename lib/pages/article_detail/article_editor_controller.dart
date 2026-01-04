import 'dart:async';
import 'dart:convert';
import '../../data/models/article.dart';
import '../../providers/activity_provider.dart';
import '../../core/logger/app_logger.dart';

/// 文章编辑控制器 - 负责处理文章编辑的业务逻辑
///
/// 功能包括:
/// - 变更检测 (标题和内容)
/// - 临时文章管理
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
        _onError = onError {
    _isTempArticle = initialArticle.id.isEmpty;
  }

  // 当前文章对象
  Article _currentArticle;

  // Provider 引用
  final ActivityProvider _provider;

  // 回调函数
  final Function(Article) _onArticleUpdated;
  final Function(String) _onError;

  // 临时文章标记
  bool _isTempArticle = false;

  // 防抖定时器
  Timer? _titleSaveTimer;
  Timer? _contentSaveTimer;

  // ==================== Getters ====================

  /// 获取当前文章
  Article get currentArticle => _currentArticle;

  /// 是否是临时文章
  bool get isTempArticle => _isTempArticle;

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

  // ==================== 临时文章管理 ====================

  /// 确保文章存在（如果是临时文章，则创建新文章）
  Future<Article?> ensureArticleExists() async {
    if (!_isTempArticle) {
      return _currentArticle;
    }

    try {
      final createdArticle = await _provider.createNewArticle();
      if (createdArticle != null) {
        _isTempArticle = false;
        _currentArticle = createdArticle;
        appLogger.info('临时文章已创建: ${createdArticle.id}');
        return createdArticle;
      } else {
        _onError('创建文章失败');
        return null;
      }
    } catch (e) {
      appLogger.error('创建临时文章失败', e);
      _onError('创建文章失败');
      return null;
    }
  }

  /// 标记为临时文章
  void markAsTempArticle() {
    _isTempArticle = true;
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

      // 如果是临时文章，先创建文章
      if (_isTempArticle) {
        final createdArticle = await ensureArticleExists();
        if (createdArticle != null) {
          _currentArticle = createdArticle.copyWith(
            title: titleToSave,
            updatedAt: now,
          );
          // 立即保存到数据库
          await _provider.updateArticleContent(
            createdArticle.id,
            title: titleToSave,
          );
          _notifyArticleUpdated();
          appLogger.info('新文章已创建，标题已保存: $titleToSave');
        }
      } else {
        // 已存在的文章，直接更新
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
      }
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

      // 如果是临时文章，先创建文章
      if (_isTempArticle) {
        final createdArticle = await ensureArticleExists();
        if (createdArticle != null) {
          _currentArticle = createdArticle.copyWith(
            content: deltaJson,
            updatedAt: now,
          );
          // 立即保存到数据库
          await _provider.updateArticleContent(
            createdArticle.id,
            content: deltaJson,
          );
          _notifyArticleUpdated();
          appLogger.info('新文章已创建，内容已保存');
        }
      } else {
        // 已存在的文章，直接更新
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
      }
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

    // 快速检查：如果是临时文章，且标题和内容都为空，直接返回
    if (_isTempArticle) {
      final isTitleEmpty = titleToSave.isEmpty || titleToSave == 'Untitled';
      final isContentEmpty =
          content.isEmpty || (content.length == 1 && content[0]['insert'] == '\n');

      if (isTitleEmpty && isContentEmpty) {
        appLogger.info('临时文章无内容，不保存');
        return;
      }
    }

    // 如果是临时文章，先创建文章
    if (_isTempArticle) {
      final createdArticle = await ensureArticleExists();
      if (createdArticle != null) {
        // 立即保存标题和内容
        await _provider.updateArticleContent(
          createdArticle.id,
          title: titleToSave,
          content: content,
        );

        _currentArticle = createdArticle.copyWith(
          title: titleToSave,
          content: content,
          updatedAt: DateTime.now(),
        );
        appLogger.info('临时文章已保存到数据库');
      }
      return;
    }

    // 非临时文章的常规保存逻辑
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
