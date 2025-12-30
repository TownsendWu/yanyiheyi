/// 图片 URL 优化工具类
/// 用于优化图片 URL，添加压缩参数以减少带宽和提升加载速度
class ImageUrlOptimizer {
  /// 优化图片 URL，添加压缩参数
  ///
  /// [url] 原始图片 URL
  /// 返回优化后的 URL，如果不需要优化则返回原 URL
  static String? optimize(String? url) {
    if (url == null || url.isEmpty) return url;

    // 如果是 Unsplash 图片，添加压缩参数
    if (url.contains('images.unsplash.com')) {
      return _addUnsplashParams(url);
    }

    // 可以在这里添加其他图片源的优化逻辑
    // 例如: imgur, cloudinary 等

    return url;
  }

  /// 为 Unsplash 图片添加优化参数
  static String _addUnsplashParams(String url) {
    // 解析 URL
    final uri = Uri.parse(url);
    final params = Map<String, String>.from(uri.queryParameters);

    // 设置优化参数（覆盖已有参数）
    params['w'] = '400';
    params['q'] = '70';
    params['auto'] = 'format';
    params['fit'] = 'crop';

    // 重建 URL
    return uri.replace(queryParameters: params).toString();
  }

  /// 验证图片 URL 是否有效
  ///
  /// [url] 待验证的 URL
  /// 返回 true 如果 URL 格式有效
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    // 基本的 URL 格式验证
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return false;
    }

    // 检查是否是支持的协议（http 或 https）
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return false;
    }

    // 如果 URL 包含图片扩展名，验证它
    // 但不强制要求，因为很多动态图片 URL 没有扩展名
    return true;
  }

  /// 从 URL 中提取文件名（用于缓存 key 等）
  ///
  /// [url] 图片 URL
  /// 返回文件名，如果无法提取则返回 null
  static String? extractFileName(String? url) {
    if (url == null || url.isEmpty) return null;

    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final fileName = path.split('/').last;

      // 移除查询参数
      final queryIndex = fileName.indexOf('?');
      if (queryIndex != -1) {
        return fileName.substring(0, queryIndex);
      }

      return fileName.isNotEmpty ? fileName : null;
    } catch (e) {
      return null;
    }
  }
}
