import 'package:flutter/material.dart';
import '../data/models/activity_data.dart';
import '../data/models/article.dart';
import '../data/services/mock_data_service.dart';
import '../data/repositories/article_repository.dart';
import '../data/services/api/api_service_interface.dart';
import '../data/services/article_storage_service.dart';
import '../core/logger/app_logger.dart';

/// 活动数据状态管理 Provider
class ActivityProvider extends ChangeNotifier {
  List<ActivityData> _activities = [];
  List<Article> _articles = [];
  bool _isLoading = true;

  final ArticleRepository _articleRepository;
  final ArticleStorageService _articleStorage;

  ActivityProvider({
    required ApiService apiService,
    required ArticleStorageService articleStorage,
    bool syncInit = false,
    bool delayInit = false,
  })  : _articleRepository = ArticleRepository(apiService: apiService),
        _articleStorage = articleStorage,
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

  /// 初始化数据（本地 + 远程同步）
  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();

    appLogger.info('ActivityProvider: 开始初始化数据...');

    // 步骤 1: 从本地存储加载数据
    appLogger.info('步骤 1/4: 从本地存储加载数据');
    List<Article> localArticles = await _articleStorage.loadArticles();
    appLogger.info('本地存储加载完成，共 ${localArticles.length} 篇文章');

    // 步骤 2: 从远程服务器获取数据
    appLogger.info('步骤 2/4: 从远程服务器获取数据');
    final remoteResult = await _articleRepository.getArticles(
      page: 1,
      pageSize: 1000,
    );

    if (remoteResult.isSuccess && remoteResult.getData != null) {
      final remoteArticles = remoteResult.getData!;
      appLogger.info('远程服务器返回 ${remoteArticles.length} 篇文章');

      // 步骤 3: 对比并合并数据
      appLogger.info('步骤 3/4: 对比并合并本地和远程数据');
      _articles = _mergeArticles(localArticles, remoteArticles);

      // 步骤 4: 保存合并后的数据到本地
      appLogger.info('步骤 4/4: 保存合并后的数据到本地');
      await _articleStorage.saveArticles(_articles);
      appLogger.info('数据合并完成，共 ${_articles.length} 篇文章');
    } else {
      // 服务器无数据或请求失败，使用本地数据
      appLogger.warning('远程数据加载失败，使用本地数据');
      _articles = localArticles;
    }

    // 步骤 5: 生成活动数据
    _activities = MockDataService.generateActivityDataFromArticles(_articles);

    _isLoading = false;
    notifyListeners();
    appLogger.info('ActivityProvider: 初始化完成');
  }

  /// 合并本地和远程文章数据
  List<Article> _mergeArticles(
    List<Article> localArticles,
    List<Article> remoteArticles,
  ) {
    final Map<String, Article> mergedMap = {};

    // 1. 先加入本地数据（排除已删除的）
    for (final article in localArticles) {
      if (!article.isDeleted) {
        mergedMap[article.id] = article;
      }
    }

    // 2. 处理远程数据
    for (final remoteArticle in remoteArticles) {
      final localArticle = mergedMap[remoteArticle.id];

      if (remoteArticle.isDeleted) {
        // 情况 3: 服务器删除了文章 → 从本地删除
        if (localArticle != null) {
          mergedMap.remove(remoteArticle.id);
          appLogger.info('🗑️ 删除本地文章: ${remoteArticle.id}');
        }
      } else if (localArticle == null) {
        // 情况 2: 服务器新增了文章 → 合并到本地
        mergedMap[remoteArticle.id] = remoteArticle;
        appLogger.info('➕ 新增文章: ${remoteArticle.id}');
      } else {
        // 情况 1: 服务器修改了文章 → 用服务器数据覆盖本地
        final remoteUpdatedAt = remoteArticle.updatedAt ?? remoteArticle.date;
        final localUpdatedAt = localArticle.updatedAt ?? localArticle.date;

        if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
          mergedMap[remoteArticle.id] = remoteArticle;
          appLogger.info('🔄 更新文章: ${remoteArticle.id}');
        }
      }
    }

    return mergedMap.values.toList();
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
    // 1. 立即更新本地存储
    final success = await _articleStorage.toggleArticlePin(articleId, isPinned);

    if (!success) {
      appLogger.error('本地存储更新失败: toggleArticlePin', articleId);
      return;
    }

    // 2. 更新内存中的文章状态
    final updatedArticles = _articles.map((article) {
      if (article.id == articleId) {
        return article.copyWith(
          isPinned: isPinned,
          pinnedAt: isPinned ? DateTime.now() : null,
        );
      }
      return article;
    }).toList();

    _articles = updatedArticles;
    notifyListeners();

    // 3. 异步调用 API（后台执行，不阻塞 UI）
    _articleRepository.toggleArticlePin(articleId, isPinned).then((result) {
      if (result.isSuccess) {
        appLogger.info('✅ API 同步成功: 文章置顶状态已更新 | articleId: $articleId, isPinned: $isPinned');
      } else {
        appLogger.error('❌ API 同步失败: 文章置顶状态同步到服务器失败 | articleId: $articleId');
      }
    }).catchError((error) {
      appLogger.error('❌ API 同步异常: 文章置顶状态同步出错 | articleId: $articleId', error);
    });
  }

  /// 更新文章的封面图
  Future<void> updateArticleCoverImage(
    String articleId,
    String? coverImage,
  ) async {
    // 查找文章
    final article = _articles.firstWhere((a) => a.id == articleId);

    // 1. 立即更新本地存储
    final updatedArticle = article.copyWith(
      coverImage: coverImage,
      clearCoverImage: coverImage == null,
    );
    final success = await _articleStorage.updateArticle(updatedArticle);

    if (!success) {
      appLogger.error('本地存储更新失败: updateArticle (coverImage)', articleId);
      return;
    }

    // 2. 更新内存中的文章状态
    final updatedArticles = _articles.map((a) {
      if (a.id == articleId) {
        return updatedArticle;
      }
      return a;
    }).toList();

    _articles = updatedArticles;
    notifyListeners();

    // 3. 异步调用 API（后台执行，不阻塞 UI）
    _articleRepository.updateArticle(updatedArticle).then((result) {
      if (result.isSuccess) {
        appLogger.info('✅ API 同步成功: 文章封面图已更新 | articleId: $articleId');
      } else {
        appLogger.error('❌ API 同步失败: 文章封面图同步到服务器失败 | articleId: $articleId');
      }
    }).catchError((error) {
      appLogger.error('❌ API 同步异常: 文章封面图同步出错 | articleId: $articleId', error);
    });
  }

  /// 更新文章的标签
  Future<void> updateArticleTags(String articleId, List<String> tags) async {
    // 查找文章
    final article = _articles.firstWhere((a) => a.id == articleId);

    // 1. 立即更新本地存储
    final updatedArticle = article.copyWith(tags: tags);
    final success = await _articleStorage.updateArticle(updatedArticle);

    if (!success) {
      appLogger.error('本地存储更新失败: updateArticle (tags)', articleId);
      return;
    }

    // 2. 更新内存中的文章状态
    final updatedArticles = _articles.map((a) {
      if (a.id == articleId) {
        return updatedArticle;
      }
      return a;
    }).toList();

    _articles = updatedArticles;
    notifyListeners();

    // 3. 异步调用 API（后台执行，不阻塞 UI）
    _articleRepository.updateArticle(updatedArticle).then((result) {
      if (result.isSuccess) {
        appLogger.info('✅ API 同步成功: 文章标签已更新 | articleId: $articleId, tags: $tags');
      } else {
        appLogger.error('❌ API 同步失败: 文章标签同步到服务器失败 | articleId: $articleId');
      }
    }).catchError((error) {
      appLogger.error('❌ API 同步异常: 文章标签同步出错 | articleId: $articleId', error);
    });
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

    // 1. 立即更新本地存储
    final updatedArticle = article.copyWith(
      title: title,
      content: content,
      updatedAt: DateTime.now(),
    );
    final success = await _articleStorage.updateArticle(updatedArticle);

    if (!success) {
      appLogger.error('本地存储更新失败: updateArticle (content)', articleId);
      return;
    }

    // 2. 更新内存中的文章状态
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

    // 3. 异步调用 API（后台执行，不阻塞 UI）
    _articleRepository.updateArticle(updatedArticle).then((result) {
      if (result.isSuccess) {
        appLogger.info('✅ API 同步成功: 文章内容已更新 | articleId: $articleId');
      } else {
        appLogger.error('❌ API 同步失败: 文章内容同步到服务器失败 | articleId: $articleId');
      }
    }).catchError((error) {
      appLogger.error('❌ API 同步异常: 文章内容同步出错 | articleId: $articleId', error);
    });
  }

  /// 删除文章
  Future<void> deleteArticle(String articleId) async {
    // 1. 立即更新本地存储
    final success = await _articleStorage.deleteArticle(articleId);

    if (!success) {
      appLogger.error('本地存储删除失败: deleteArticle', articleId);
      return;
    }

    // 2. 从内存中移除文章
    _articles = _articles.where((a) => a.id != articleId).toList();

    // 重新生成活动数据
    _activities = MockDataService.generateActivityDataFromArticles(_articles);

    notifyListeners();

    // 3. 异步调用 API（后台执行，不阻塞 UI）
    _articleRepository.deleteArticle(articleId).then((result) {
      if (result.isSuccess) {
        appLogger.info('✅ API 同步成功: 文章已删除 | articleId: $articleId');
      } else {
        appLogger.error('❌ API 同步失败: 文章删除同步到服务器失败 | articleId: $articleId');
      }
    }).catchError((error) {
      appLogger.error('❌ API 同步异常: 文章删除同步出错 | articleId: $articleId', error);
    });
  }

  /// 批量删除文章
  Future<void> deleteArticles(List<String> articleIds) async {
    // 1. 立即更新本地存储（逐个删除）
    for (final articleId in articleIds) {
      final success = await _articleStorage.deleteArticle(articleId);
      if (!success) {
        appLogger.error('本地存储删除失败: deleteArticle (batch)', articleId);
      }
    }

    // 2. 从内存中移除文章
    _articles = _articles.where((a) => !articleIds.contains(a.id)).toList();

    // 重新生成活动数据
    _activities = MockDataService.generateActivityDataFromArticles(_articles);

    notifyListeners();

    // 3. 异步调用 API（后台执行，不阻塞 UI）
    for (final articleId in articleIds) {
      _articleRepository.deleteArticle(articleId).then((result) {
        if (result.isSuccess) {
          appLogger.info('✅ API 同步成功: 批量删除文章已同步 | articleId: $articleId');
        } else {
          appLogger.error('❌ API 同步失败: 批量删除文章同步到服务器失败 | articleId: $articleId');
        }
      }).catchError((error) {
        appLogger.error('❌ API 同步异常: 批量删除文章同步出错 | articleId: $articleId', error);
      });
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

    // 1. 立即更新本地存储
    final success = await _articleStorage.createArticle(newArticle);

    if (!success) {
      appLogger.error('本地存储创建失败: createArticle', newArticle.id);
      return null;
    }

    // 2. 添加到内存中的文章列表
    _articles.insert(0, newArticle);

    // 重新生成活动数据
    _activities = MockDataService.generateActivityDataFromArticles(_articles);

    notifyListeners();

    // 3. 异步调用 API（后台执行，不阻塞 UI）
    _articleRepository.createArticle(newArticle).then((result) {
      if (result.isSuccess) {
        appLogger.info('✅ API 同步成功: 新文章已创建 | articleId: ${newArticle.id}');
      } else {
        appLogger.error('❌ API 同步失败: 新文章同步到服务器失败 | articleId: ${newArticle.id}');
      }
    }).catchError((error) {
      appLogger.error('❌ API 同步异常: 新文章同步出错 | articleId: ${newArticle.id}', error);
    });

    return newArticle;
  }
}
