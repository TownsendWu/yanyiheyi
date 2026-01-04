import 'dart:convert';
import '../models/article.dart';
import '../services/mock_data_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/constants/storage_keys.dart';

/// 文章数据存储服务
/// 负责文章数据的本地持久化存储
class ArticleStorageService {
  final LocalStorageService _storage;

  ArticleStorageService._(this._storage);

  /// 单例实例
  static ArticleStorageService? _instance;

  /// 获取实例
  static ArticleStorageService getInstance(LocalStorageService storage) {
    _instance ??= ArticleStorageService._(storage);
    return _instance!;
  }

  /// 初始化文章数据
  /// 如果是首次启动，生成 mock 数据并保存
  /// 否则从本地存储加载
  Future<List<Article>> initializeArticles() async {
    // 检查是否已初始化
    final isInitialized = _storage.getBoolSync(StorageKeys.articlesInitialized) ?? false;

    if (!isInitialized) {
      // 首次启动，生成并保存 mock 数据（现在从 JSON 文件加载）
      final articles = await MockDataService.generateArticleData();
      await saveArticles(articles);
      await _storage.setBool(StorageKeys.articlesInitialized, true);
      return articles;
    } else {
      // 从本地存储加载
      return await loadArticles();
    }
  }

  /// 从本地存储加载文章列表
  /// 返回值：成功返回文章列表，失败返回空列表
  Future<List<Article>> loadArticles() async {
    try {
      final jsonString = await _storage.getString(StorageKeys.articlesData);
      if (jsonString == null || jsonString.isEmpty) {
        // 如果没有数据，返回空列表
        return [];
      }

      final jsonArray = jsonDecode(jsonString) as List;
      return jsonArray.map((json) => Article.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      // 解析失败，返回空列表
      return [];
    }
  }

  /// 保存文章列表到本地存储
  /// 返回值：成功返回 true，失败返回 false
  Future<bool> saveArticles(List<Article> articles) async {
    try {
      final jsonArray = articles.map((article) => article.toJson()).toList();
      final jsonString = jsonEncode(jsonArray);
      await _storage.setString(StorageKeys.articlesData, jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取单个文章
  Future<Article?> getArticle(String articleId) async {
    final articles = await loadArticles();
    try {
      return articles.firstWhere((article) => article.id == articleId);
    } catch (e) {
      return null;
    }
  }

  /// 更新单个文章
  /// 返回值：成功返回 true，失败返回 false
  Future<bool> updateArticle(Article updatedArticle) async {
    try {
      final articles = await loadArticles();
      final index = articles.indexWhere((article) => article.id == updatedArticle.id);

      if (index != -1) {
        articles[index] = updatedArticle;
        return await saveArticles(articles);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 置顶/取消置顶文章
  /// 返回值：成功返回 true，失败返回 false
  Future<bool> toggleArticlePin(String articleId, bool isPinned) async {
    try {
      final articles = await loadArticles();
      final index = articles.indexWhere((article) => article.id == articleId);

      if (index != -1) {
        final updatedArticle = articles[index].copyWith(
          isPinned: isPinned,
          pinnedAt: isPinned ? DateTime.now() : null,
        );
        articles[index] = updatedArticle;
        return await saveArticles(articles);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 获取置顶的文章列表
  Future<List<Article>> getPinnedArticles() async {
    final articles = await loadArticles();
    final pinnedArticles = articles.where((article) => article.isPinned).toList();

    // 按置顶时间倒序排序
    pinnedArticles.sort((a, b) {
      if (a.pinnedAt == null || b.pinnedAt == null) return 0;
      return b.pinnedAt!.compareTo(a.pinnedAt!);
    });

    return pinnedArticles;
  }

  /// 创建新文章
  /// 返回值：成功返回 true，失败返回 false
  Future<bool> createArticle(Article article) async {
    try {
      final articles = await loadArticles();
      articles.add(article);
      return await saveArticles(articles);
    } catch (e) {
      return false;
    }
  }

  /// 删除文章
  /// 返回值：成功返回 true，失败返回 false
  Future<bool> deleteArticle(String articleId) async {
    try {
      final articles = await loadArticles();
      articles.removeWhere((article) => article.id == articleId);
      return await saveArticles(articles);
    } catch (e) {
      return false;
    }
  }

  /// 清空所有文章数据（用于重置）
  Future<void> clearArticles() async {
    await _storage.remove(StorageKeys.articlesData);
    await _storage.remove(StorageKeys.articlesInitialized);
  }

  /// 重置为默认 mock 数据
  Future<void> resetToMockData() async {
    await clearArticles();
    final articles = await MockDataService.generateArticleData();
    await saveArticles(articles);
    await _storage.setBool(StorageKeys.articlesInitialized, true);
  }
}
