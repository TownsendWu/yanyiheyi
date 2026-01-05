import 'dart:collection';
import 'package:yanyiheyi/core/logger/app_logger.dart';

/// 缓存项
class _AICacheItem {
  final String originalText;
  String aiSuggestion;
  final DateTime timestamp;

  _AICacheItem({
    required this.originalText,
    this.aiSuggestion = '',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// AI 建议缓存管理器
/// 使用队列（FIFO）机制，限制缓存大小
class AICacheManager {
  /// 最大缓存数量
  static const int _maxCacheSize = 20;

  /// 缓存队列（使用 LinkedHashMap 保持插入顺序）
  final LinkedHashMap<String, _AICacheItem> _cache = LinkedHashMap<String, _AICacheItem>();

  /// 获取缓存的 AI 建议
  /// 返回：建议文本，如果缓存不存在返回 null
  String? getCachedSuggestion(String originalText) {
    appLogger.info('🔍 [查缓存] 查找原文: "$originalText"');
    final item = _cache[originalText];
    if (item == null) {
      appLogger.info('❌ [查缓存] 未找到');
      return null;
    }
    appLogger.info('✅ [查缓存] 找到建议: "${item.aiSuggestion}"');
    return item.aiSuggestion;
  }

  /// 检查是否有缓存
  bool hasCache(String originalText) {
    final has = _cache.containsKey(originalText);
    appLogger.info('🔍 [查缓存] 检查原文 "$originalText": ${has ? "存在" : "不存在"}');
    return has;
  }

  /// 检查是否有 AI 建议（缓存存在且建议不为空）
  bool hasSuggestion(String originalText) {
    final item = _cache[originalText];
    final has = item != null && item.aiSuggestion.isNotEmpty;
    appLogger.info('🔍 [查缓存] 检查建议 "$originalText": ${has ? "有建议" : "无建议"}');
    return has;
  }

  /// 更新或创建缓存
  void updateCache(String originalText, String aiSuggestion) {
    appLogger.info('📥 [入缓存] 更新缓存 - 原文: "$originalText", 建议: "$aiSuggestion"');
    if (_cache.containsKey(originalText)) {
      // 更新现有缓存
      _cache[originalText]!.aiSuggestion = aiSuggestion;
      _moveToEnd(originalText); // 移到队列末尾（最新使用）
      appLogger.info('♻️ [入缓存] 更新现有缓存');
    } else {
      // 创建新缓存
      _ensureCapacity();
      _cache[originalText] = _AICacheItem(
        originalText: originalText,
        aiSuggestion: aiSuggestion,
      );
      appLogger.info('➕ [入缓存] 创建新缓存');
    }
    _printCacheStatus();
  }

  /// 只更新原文（用于开始生成 AI 建议时）
  void updateOriginalText(String originalText) {
    appLogger.info('📝 [入缓存] 创建原文缓存: "$originalText"');
    if (!_cache.containsKey(originalText)) {
      _ensureCapacity();
      _cache[originalText] = _AICacheItem(
        originalText: originalText,
        aiSuggestion: '',
      );
      appLogger.info('➕ [入缓存] 新建原文缓存');
      _printCacheStatus();
    } else {
      appLogger.info('⚠️ [入缓存] 原文缓存已存在');
    }
  }

  /// 更新 AI 建议
  void updateSuggestion(String originalText, String aiSuggestion) {
    appLogger.info('💾 [入缓存] 更新建议 - 原文: "$originalText", 建议: "$aiSuggestion"');
    if (_cache.containsKey(originalText)) {
      _cache[originalText]!.aiSuggestion = aiSuggestion;
      _moveToEnd(originalText);
      appLogger.info('✅ [入缓存] 建议已更新');
      _printCacheStatus();
    } else {
      appLogger.error('❌ [入缓存] 错误：原文缓存不存在');
    }
  }

  /// 清空所有缓存
  void clear() {
    final count = _cache.length;
    appLogger.info('🗑️ [清缓存] 开始清空 $count 个缓存项');
    _cache.clear();
    appLogger.info('✅ [清缓存] 缓存已清空，当前大小: ${_cache.length}');
  }

  /// 删除指定缓存
  void removeCache(String originalText) {
    _cache.remove(originalText);
  }

  /// 获取缓存大小
  int get size => _cache.length;

  /// 获取所有缓存的键（原文列表）
  List<String> get cachedOriginalTexts => _cache.keys.toList();

  /// 确保缓存容量不超过限制
  void _ensureCapacity() {
    while (_cache.length >= _maxCacheSize) {
      // 移除最旧的缓存（第一个）
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }
  }

  /// 将缓存项移到队列末尾（标记为最新使用）
  void _moveToEnd(String originalText) {
    final item = _cache.remove(originalText);
    if (item != null) {
      _cache[originalText] = item;
    }
  }

  /// 打印缓存状态
  void _printCacheStatus() {
    appLogger.info('📊 [缓存状态] 当前缓存数: ${_cache.length}/$_maxCacheSize');
    if (_cache.isNotEmpty) {
      _cache.forEach((key, value) {
        final hasSuggestion = value.aiSuggestion.isNotEmpty;
        appLogger.info('  - "$key": ${hasSuggestion ? "有建议" : "无建议"}');
      });
    }
  }

  /// 获取缓存统计信息（用于调试）
  Map<String, dynamic> getStats() {
    return {
      'size': _cache.length,
      'maxSize': _maxCacheSize,
      'cachedTexts': _cache.keys.map((text) => '"$text"').toList(),
    };
  }
}
