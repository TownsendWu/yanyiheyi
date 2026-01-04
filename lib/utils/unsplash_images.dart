import 'dart:math';

/// Unsplash 随机图片管理器
class UnsplashImages {
  // Unsplash 图片列表（精选自然、风景、艺术类图片）
  static const List<String> _imageUrls = [
    // 自然风景
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
    'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800&q=80',
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&q=80',
    'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=800&q=80',
    'https://images.unsplash.com/photo-1475924156734-496f6cac6ec1?w=800&q=80',
    'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&q=80',
    'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=800&q=80',
    'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=800&q=80',
    'https://images.unsplash.com/photo-1418065460487-3e41a6c84dc5?w=800&q=80',
    'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=800&q=80',

    // 天空云彩
    'https://images.unsplash.com/photo-1534088568595-a066f410bcda?w=800&q=80',
    'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&q=80',
    'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&q=80',
    'https://images.unsplash.com/photo-1507400492013-162706c8c05e?w=800&q=80',
    'https://images.unsplash.com/photo-1496568816309-51d7c20e3b21?w=800&q=80',

    // 森林树木
    'https://images.unsplash.com/photo-1448375240586-882707db888b?w=800&q=80',
    'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800&q=80',
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&q=80',
    'https://images.unsplash.com/photo-1425913397330-cf8af2ff40a1?w=800&q=80',
    'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=800&q=80',

    // 水面海洋
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80',
    'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=800&q=80',
    'https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=800&q=80',
    'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800&q=80',
    'https://images.unsplash.com/photo-1496568816309-51d7c20e3b21?w=800&q=80',
  ];

  static final Random _random = Random();

  /// 获取随机图片 URL
  static String getRandomImage() {
    final index = _random.nextInt(_imageUrls.length);
    return _imageUrls[index];
  }

  /// 获取随机图片 URL（排除指定的 URL）
  static String getRandomImageExcluding(String? excludeUrl) {
    if (excludeUrl == null || excludeUrl.isEmpty) {
      return getRandomImage();
    }

    // 过滤掉当前图片
    final availableImages = _imageUrls.where((url) => url != excludeUrl).toList();

    if (availableImages.isEmpty) {
      // 如果所有图片都被排除了，返回随机图片
      return getRandomImage();
    }

    final index = _random.nextInt(availableImages.length);
    return availableImages[index];
  }

  /// 获取所有图片列表
  static List<String> getAllImages() {
    return List.from(_imageUrls);
  }
}
