import '../core/constants/app_constants.dart';

/// 活动等级计算工具类
class LevelCalculator {
  LevelCalculator._();

  /// 根据文章数量计算活动等级
  /// 0篇 = 0级, 1篇 = 1级, 2篇 = 2级, 3篇 = 3级, 4篇及以上 = 4级
  static int calculateLevel(int count) {
    if (count == 0) return 0;
    if (count == 1) return AppConstants.level1Min;
    if (count == 2) return AppConstants.level2Min;
    if (count == 3) return AppConstants.level3Min;
    return AppConstants.level4Min;
  }
}
