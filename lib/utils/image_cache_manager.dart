import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

/// 图片缓存管理器
/// 负责下载和缓存网络图片到本地
class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  factory ImageCacheManager() => _instance;
  ImageCacheManager._internal();

  Directory? _cacheDir;

  /// 获取缓存目录
  /// 优先使用临时目录，因为它的兼容性更好
  Future<Directory> get _cacheDirectory async {
    if (_cacheDir != null) return _cacheDir!;

    try {
      // 优先尝试使用应用支持目录
      final appSupportDir = await getApplicationSupportDirectory();
      _cacheDir = Directory('${appSupportDir.path}/image_cache');
      debugPrint('✓ 使用应用支持目录: ${_cacheDir!.path}');
    } catch (e) {
      // 降级到临时目录
      final tempDir = await getTemporaryDirectory();
      _cacheDir = Directory('${tempDir.path}/image_cache');
      debugPrint('✓ 使用临时目录: ${_cacheDir!.path}');
    }

    // 如果目录不存在，创建目录
    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }

    return _cacheDir!;
  }

  /// 从 URL 生成文件名
  /// 使用 URL 的 MD5 哈希值作为文件名，避免特殊字符问题
  /// 如果 URL 中包含图片扩展名，则使用该扩展名，否则默认使用 .jpg
  String _generateFileName(String url) {
    final bytes = utf8.encode(url);
    final hash = md5.convert(bytes);

    // 提取 URL 中的文件扩展名
    String extension = '.jpg'; // 默认扩展名
    final uri = Uri.tryParse(url);
    if (uri != null && uri.hasAbsolutePath) {
      final path = uri.path;
      final lastDotIndex = path.lastIndexOf('.');
      if (lastDotIndex != -1 && lastDotIndex < path.length - 1) {
        // 确保点后面有字符（排除以点结尾的情况）
        final ext = path.substring(lastDotIndex).toLowerCase();
        // 检查是否是常见的图片扩展名
        const imageExtensions = {'.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.svg'};
        if (imageExtensions.contains(ext)) {
          extension = ext;
        }
      }
    }

    return '$hash$extension';
  }

  /// 从文件路径提取扩展名
  /// 如果不是图片格式或无法识别，返回 .jpg
  String _extractImageExtension(String filePath) {
    final lastDotIndex = filePath.lastIndexOf('.');
    if (lastDotIndex != -1 && lastDotIndex < filePath.length - 1) {
      final ext = filePath.substring(lastDotIndex).toLowerCase();
      const imageExtensions = {'.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.svg'};
      if (imageExtensions.contains(ext)) {
        return ext;
      }
    }
    return '.jpg'; // 默认扩展名
  }

  /// 检查本地是否有缓存的图片
  Future<File?> getCachedImage(String url) async {
    try {
      final cacheDir = await _cacheDirectory;
      final fileName = _generateFileName(url);
      final file = File('${cacheDir.path}/$fileName');

      if (await file.exists()) {
        debugPrint('✓ 缓存命中: $url -> ${file.path}');
        return file;
      }

      debugPrint('✗ 缓存未命中: $url');
      return null;
    } catch (e) {
      debugPrint('✗ 检查缓存失败: $e');
      return null;
    }
  }

  /// 下载网络图片并保存到本地
  Future<File?> downloadAndCacheImage(String url) async {
    try {
      // 先检查是否已有缓存
      final cached = await getCachedImage(url);
      if (cached != null) {
        return cached;
      }

      debugPrint('⬇ 开始下载: $url');

      // 下载图片
      final request = await HttpClient().getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        debugPrint('✗ 下载失败: HTTP ${response.statusCode}');
        return null;
      }

      final bytes = await consolidateHttpClientResponseBytes(response);

      // 保存到本地
      final cacheDir = await _cacheDirectory;
      final fileName = _generateFileName(url);
      final file = File('${cacheDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      debugPrint('✓ 下载成功: ${file.path}');
      return file;
    } catch (e) {
      debugPrint('✗ 下载失败: $e');
      return null;
    }
  }

  /// 获取图片（优先从缓存，没有则下载）
  /// 返回本地文件路径，如果失败则返回 null
  Future<String?> getImage(String url) async {
    if (url.isEmpty) return null;

    // 检查是否是本地路径
    if (url.startsWith('/') || url.startsWith('file://')) {
      return url.replaceFirst('file://', '');
    }

    // 网络图片：先检查缓存，没有则下载
    final file = await getCachedImage(url);
    if (file != null) {
      return file.path;
    }

    // 下载并缓存
    final downloaded = await downloadAndCacheImage(url);
    return downloaded?.path;
  }

  /// 清除所有缓存
  Future<void> clearCache() async {
    try {
      final cacheDir = await _cacheDirectory;
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        debugPrint('✓ 缓存已清除');
      }
      // 重新创建目录
      _cacheDir = null;
      await _cacheDirectory;
    } catch (e) {
      debugPrint('✗ 清除缓存失败: $e');
    }
  }

  /// 获取缓存大小
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await _cacheDirectory;
      if (!await cacheDir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      debugPrint('✗ 获取缓存大小失败: $e');
      return 0;
    }
  }

  /// 保存本地图片到缓存目录
  /// 使用 UUID 作为文件名，保留原始文件的扩展名
  Future<String?> saveLocalImage(File imageFile) async {
    try {
      final cacheDir = await _cacheDirectory;
      final uuid = const Uuid().v4();
      final extension = _extractImageExtension(imageFile.path);
      final fileName = '$uuid$extension';
      final cachedFile = await imageFile.copy('${cacheDir.path}/$fileName');

      debugPrint('✓ 本地图片已缓存: ${cachedFile.path}');
      return cachedFile.path;
    } catch (e) {
      debugPrint('✗ 保存本地图片失败: $e');
      return null;
    }
  }

  /// 删除指定 URL 对应的缓存文件
  Future<bool> deleteCachedImage(String url) async {
    try {
      final cacheDir = await _cacheDirectory;
      final fileName = _generateFileName(url);
      final file = File('${cacheDir.path}/$fileName');

      if (await file.exists()) {
        await file.delete();
        debugPrint('✓ 缓存已删除: $url');
        return true;
      }

      debugPrint('✗ 缓存文件不存在: $url');
      return false;
    } catch (e) {
      debugPrint('✗ 删除缓存失败: $e');
      return false;
    }
  }

  /// 根据本地文件路径删除缓存
  Future<bool> deleteCachedFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('✓ 缓存文件已删除: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('✗ 删除缓存文件失败: $e');
      return false;
    }
  }
}
