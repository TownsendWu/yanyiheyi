import 'dart:math';

/// 本地背景图片管理器
/// 从 assets/images 目录读取图片(以数字命名: 1.jpg, 2.jpg, ...)
class UnsplashImages {
  // 图片总数(与 assets/images 中的图片数量匹配)
  static const int _totalImages = 21;

  // 图片基础路径
  static const String _basePath = 'assets/images/';

  static final Random _random = Random();

  /// 获取随机图片路径
  static String getRandomImage() {
    final index = _random.nextInt(_totalImages) + 1; // 1 到 _totalImages
    return '$_basePath$index.jpg';
  }

  /// 获取随机图片路径(排除指定的路径)
  static String getRandomImageExcluding(String? excludePath) {
    if (excludePath == null || excludePath.isEmpty) {
      return getRandomImage();
    }

    // 从路径中提取图片编号
    int? excludeIndex;
    final match = RegExp(r'(\d+)\.jpg$').firstMatch(excludePath);
    if (match != null) {
      excludeIndex = int.tryParse(match.group(1)!);
    }

    // 如果无法提取编号,直接返回随机图片
    if (excludeIndex == null) {
      return getRandomImage();
    }

    // 生成一个不等于 excludeIndex 的随机编号
    int newIndex;
    do {
      newIndex = _random.nextInt(_totalImages) + 1;
    } while (newIndex == excludeIndex && _totalImages > 1);

    return '$_basePath$newIndex.jpg';
  }

  /// 获取所有图片路径列表
  static List<String> getAllImages() {
    return List.generate(_totalImages, (index) => '$_basePath${index + 1}.jpg');
  }
}
