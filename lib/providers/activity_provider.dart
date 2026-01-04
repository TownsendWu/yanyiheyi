import 'package:flutter/material.dart';
import '../data/models/activity_data.dart';
import '../data/models/article.dart';
import '../data/services/mock_data_service.dart';
import '../data/repositories/article_repository.dart';
import '../data/services/api/api_service_interface.dart';

/// 活动数据状态管理 Provider
class ActivityProvider extends ChangeNotifier {
  List<ActivityData> _activities = [];
  List<Article> _articles = [];
  bool _isLoading = true;

  final ArticleRepository _articleRepository;

  ActivityProvider({
    required ApiService apiService,
    bool syncInit = false,
    bool delayInit = false,
  }) : _articleRepository = ArticleRepository(apiService: apiService),
       super() {
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

    // 从持久化存储加载文章数据
    final result = await _articleRepository.getArticles(
      page: 1,
      pageSize: 1000, // 加载所有文章
    );

    if (result.isSuccess && result.getData != null) {
      _articles = result.getData!;
      _activities = MockDataService.generateActivityDataFromArticles(_articles);
    } else {
      // 如果加载失败，使用 mock 数据
      print('ActivityProvider: 加载失败，使用 mock 数据');
      _articles = await MockDataService.generateArticleData();
      _activities = MockDataService.generateActivityData();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 同步初始化数据 (用于测试)
  /// 注意：由于文章数据现在是异步加载的，这个方法只初始化活动数据
  void _initializeDataSync() {
    _activities = [];
    _articles = []; // 文章数据需要异步加载
    _isLoading = false;
    notifyListeners();
  }

  /// 更新文章的置顶状态
  Future<void> updateArticlePinnedStatus(
    String articleId,
    bool isPinned,
  ) async {
    // 调用 repository 更新置顶状态（会持久化到 SharedPreferences）
    final result = await _articleRepository.toggleArticlePin(
      articleId,
      isPinned,
    );

    if (result.isSuccess) {
      // 更新内存中的文章状态
      final updatedArticles = _articles.map((article) {
        if (article.id == articleId) {
          return article.copyWith(
            isPinned: isPinned,
            pinnedAt: isPinned ? DateTime.now() : null,
          );
        }
        return article;
      }).toList();

      // 检查是否有变化
      final hasChanges = updatedArticles.any((a) {
        final oldArticle = _articles.firstWhere((b) => b.id == a.id);
        return a.isPinned != oldArticle.isPinned;
      });

      if (hasChanges) {
        _articles = updatedArticles;
        notifyListeners();
      }
    }
  }

  /// 更新文章的封面图
  Future<void> updateArticleCoverImage(
    String articleId,
    String? coverImage,
  ) async {
    // 查找文章
    final article = _articles.firstWhere((a) => a.id == articleId);

    // 调用 repository 更新文章（会持久化到 SharedPreferences）
    final updatedArticle = article.copyWith(
      coverImage: coverImage,
      clearCoverImage: coverImage == null,
    );
    final result = await _articleRepository.updateArticle(updatedArticle);

    if (result.isSuccess) {
      // 更新内存中的文章状态
      final updatedArticles = _articles.map((a) {
        if (a.id == articleId) {
          return updatedArticle;
        }
        return a;
      }).toList();

      _articles = updatedArticles;
      notifyListeners();
    }
  }

  /// 更新文章的标签
  Future<void> updateArticleTags(String articleId, List<String> tags) async {
    // 查找文章
    final article = _articles.firstWhere((a) => a.id == articleId);

    // 调用 repository 更新文章（会持久化到 SharedPreferences）
    final updatedArticle = article.copyWith(tags: tags);
    final result = await _articleRepository.updateArticle(updatedArticle);

    if (result.isSuccess) {
      // 更新内存中的文章状态
      final updatedArticles = _articles.map((a) {
        if (a.id == articleId) {
          return updatedArticle;
        }
        return a;
      }).toList();

      _articles = updatedArticles;
      notifyListeners();
    }
  }

  /// 更新文章的标题和内容
  Future<void> updateArticleContent(
    String articleId, {
    String? title,
    dynamic content,
  }) async {
    // 查找文章
    final article = _articles.firstWhere((a) => a.id == articleId);

    // 检查是否真的有变化
    final titleChanged = title != null && title != article.title;
    final contentChanged = content != null && content != article.content;

    // 如果没有任何变化，直接返回
    if (!titleChanged && !contentChanged) {
      return;
    }

    // 调用 repository 更新文章（会持久化到 SharedPreferences）
    final updatedArticle = article.copyWith(
      title: title,
      content: content,
      updatedAt: DateTime.now(),
    );
    final result = await _articleRepository.updateArticle(updatedArticle);

    if (result.isSuccess) {
      // 更新内存中的文章状态
      final updatedArticles = _articles.map((a) {
        if (a.id == articleId) {
          return updatedArticle;
        }
        return a;
      }).toList();

      _articles = updatedArticles;

      // 重新生成活动数据（基于最新的文章列表）
      _activities = MockDataService.generateActivityDataFromArticles(_articles);

      notifyListeners();
    }
  }

  /// 删除文章
  Future<void> deleteArticle(String articleId) async {
    // 调用 repository 删除文章（会持久化到 SharedPreferences）
    final result = await _articleRepository.deleteArticle(articleId);

    if (result.isSuccess) {
      // 从内存中移除文章
      _articles = _articles.where((a) => a.id != articleId).toList();

      // 重新生成活动数据
      _activities = MockDataService.generateActivityDataFromArticles(_articles);

      notifyListeners();
    }
  }

  /// 批量删除文章
  Future<void> deleteArticles(List<String> articleIds) async {
    // 逐个删除文章
    for (final articleId in articleIds) {
      await _articleRepository.deleteArticle(articleId);
    }

    // 从内存中移除文章
    _articles = _articles.where((a) => !articleIds.contains(a.id)).toList();

    // 重新生成活动数据
    _activities = MockDataService.generateActivityDataFromArticles(_articles);

    notifyListeners();
  }

  /// 刷新数据
  Future<void> refresh() async {
    await _initializeData();
  }

  /// 预加载数据（供 SplashPage 使用）
  Future<void> preload() async {
    await _initializeData();
  }

  /// 创建新文章
  Future<Article?> createNewArticle() async {
    // 创建一个空文章
    final now = DateTime.now();
    final newArticle = Article(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '',
      date: now,
      updatedAt: now,
      content: null,
    );

    // 调用 repository 创建文章（会持久化到 SharedPreferences）
    final result = await _articleRepository.createArticle(newArticle);

    if (result.isSuccess && result.getData != null) {
      // 添加到内存中的文章列表
      _articles.insert(0, result.getData!);

      // 重新生成活动数据
      _activities = MockDataService.generateActivityDataFromArticles(_articles);

      notifyListeners();

      return result.getData!;
    }

    return null;
  }
}
