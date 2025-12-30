import '../models/article.dart';
import '../services/api/api_service_interface.dart';
import '../../core/network/network_result.dart';

/// 文章仓储
/// 负责处理文章相关的数据操作
class ArticleRepository {
  final ApiService _apiService;

  ArticleRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  /// 获取文章列表
  Future<NetworkResult<List<Article>>> getArticles({
    required int page,
    required int pageSize,
    List<String>? tags,
  }) async {
    try {
      return await _apiService.getArticles(
        page: page,
        pageSize: pageSize,
        tags: tags,
      );
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  /// 获取文章详情
  Future<NetworkResult<Article>> getArticleDetail(String articleId) async {
    try {
      return await _apiService.getArticleDetail(articleId);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  /// 创建文章
  Future<NetworkResult<Article>> createArticle(Article article) async {
    try {
      return await _apiService.createArticle(article);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  /// 更新文章
  Future<NetworkResult<Article>> updateArticle(Article article) async {
    try {
      return await _apiService.updateArticle(article);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  /// 删除文章
  Future<NetworkResult<void>> deleteArticle(String articleId) async {
    try {
      return await _apiService.deleteArticle(articleId);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }

  /// 置顶/取消置顶文章
  Future<NetworkResult<void>> toggleArticlePin(String articleId, bool isPinned) async {
    try {
      return await _apiService.toggleArticlePin(articleId, isPinned);
    } catch (e) {
      return Failure(AppErrorFactory.fromException(e));
    }
  }
}
