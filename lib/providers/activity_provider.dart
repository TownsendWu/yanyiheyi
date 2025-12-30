import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/activity_data.dart';
import '../data/models/article.dart';
import '../data/services/mock_data_service.dart';

/// 活动数据状态管理 Provider
class ActivityProvider extends ChangeNotifier {
  List<ActivityData> _activities = [];
  List<Article> _articles = [];
  bool _isLoading = true;

  static const String _pinnedArticlesKey = 'pinned_articles';

  ActivityProvider({bool syncInit = false, bool delayInit = false}) {
    if (!delayInit) {
      if (syncInit) {
        _initializeDataSync();
      } else {
        _initializeData();
      }
    }
  }

  List<ActivityData> get activities => _activities;
  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;

  /// 获取总文章数
  int get totalCount {
    return _activities.fold(0, (sum, item) => sum + item.count);
  }

  /// 获取某年总文章数
  int getTotalCountByYear(int year) {
    return _activities
        .where((activity) => activity.dateTime.year == year)
        .fold(0, (sum, item) => sum + item.count);
  }

  /// 初始化数据
  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();

    // 模拟异步加载
    await Future.delayed(const Duration(milliseconds: 100));

    _activities = MockDataService.generateActivityData();
    _articles = MockDataService.generateArticleData();

    // 加载置顶状态
    await _loadPinnedStatus();

    _isLoading = false;
    notifyListeners();
  }

  /// 同步初始化数据 (用于测试)
  void _initializeDataSync() {
    _activities = MockDataService.generateActivityData();
    _articles = MockDataService.generateArticleData();
    _isLoading = false;
    // 同步初始化也需要加载置顶状态
    SharedPreferences.getInstance().then((prefs) {
      final pinnedData = prefs.getStringList(_pinnedArticlesKey) ?? [];

      // 创建置顶信息映射
      final pinnedMap = <String, DateTime>{};
      for (final item in pinnedData) {
        final parts = item.split(':');
        if (parts.length == 2) {
          final pinnedAt = DateTime.tryParse(parts[1]);
          if (pinnedAt != null) {
            pinnedMap[parts[0]] = pinnedAt;
          }
        }
      }

      // 更新文章的置顶状态
      _articles = _articles.map((article) {
        final pinnedAt = pinnedMap[article.id];
        if (pinnedAt != null) {
          return article.copyWith(
            isPinned: true,
            pinnedAt: pinnedAt,
          );
        }
        return article;
      }).toList();

      notifyListeners();
    });
  }

  /// 从 SharedPreferences 加载置顶状态
  Future<void> _loadPinnedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final pinnedData = prefs.getStringList(_pinnedArticlesKey) ?? [];

    // 创建置顶信息映射
    final pinnedMap = <String, DateTime>{};
    for (final item in pinnedData) {
      final parts = item.split(':');
      if (parts.length == 2) {
        final pinnedAt = DateTime.tryParse(parts[1]);
        if (pinnedAt != null) {
          pinnedMap[parts[0]] = pinnedAt;
        }
      }
    }

    // 更新文章的置顶状态
    if (pinnedMap.isNotEmpty) {
      _articles = _articles.map((article) {
        final pinnedAt = pinnedMap[article.id];
        if (pinnedAt != null) {
          return article.copyWith(
            isPinned: true,
            pinnedAt: pinnedAt,
          );
        }
        return article;
      }).toList();
    }
  }

  /// 更新文章的置顶状态
  Future<void> updateArticlePinnedStatus(String articleId, bool isPinned) async {
    final prefs = await SharedPreferences.getInstance();
    final pinnedData = prefs.getStringList(_pinnedArticlesKey) ?? [];

    if (isPinned) {
      // 添加或更新置顶信息
      final now = DateTime.now();
      final newEntry = '$articleId:${now.toIso8601String()}';
      final existingIndex = pinnedData.indexWhere((item) => item.startsWith('$articleId:'));

      if (existingIndex != -1) {
        pinnedData[existingIndex] = newEntry;
      } else {
        pinnedData.add(newEntry);
      }

      await prefs.setStringList(_pinnedArticlesKey, pinnedData);

      // 更新内存中的文章状态
      final updatedArticles = _articles.map((article) {
        if (article.id == articleId) {
          return article.copyWith(
            isPinned: true,
            pinnedAt: now,
          );
        }
        return article;
      }).toList();

      // 只有当文章列表真正发生变化时才更新和通知
      if (updatedArticles.length != _articles.length ||
          updatedArticles.any((a) => a.isPinned != _articles.firstWhere((b) => b.id == a.id).isPinned)) {
        _articles = updatedArticles;
        notifyListeners();
      }
    } else {
      // 移除置顶信息
      pinnedData.removeWhere((item) => item.startsWith('$articleId:'));

      await prefs.setStringList(_pinnedArticlesKey, pinnedData);

      // 更新内存中的文章状态
      final updatedArticles = _articles.map((article) {
        if (article.id == articleId) {
          return article.copyWith(
            isPinned: false,
            pinnedAt: null,
          );
        }
        return article;
      }).toList();

      // 只有当文章列表真正发生变化时才更新和通知
      if (updatedArticles.length != _articles.length ||
          updatedArticles.any((a) => a.isPinned != _articles.firstWhere((b) => b.id == a.id).isPinned)) {
        _articles = updatedArticles;
        notifyListeners();
      }
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    await _initializeData();
  }

  /// 预加载数据（供 SplashPage 使用）
  Future<void> preload() async {
    await _initializeData();
  }
}
