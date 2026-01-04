/// 应用常量配置
class AppConstants {
  AppConstants._();

  // Mock 数据配置
  static const int mockDataSeed = 1704067200000;
  static const int totalArticles = 138;
  static const int dataDays = 365;
  static const double activityProbability = 0.7;

  // UI 配置
  static const double sideSheetWidthRatio = 0.8;
  static const Duration exitConfirmationDuration = Duration(seconds: 2);

  // 活动等级阈值
  static const int level1Min = 1;
  static const int level2Min = 2;
  static const int level3Min = 3;
  static const int level4Min = 4;

  // 开屏页配置
  static const int splashDuration = 1500; // 开屏页显示时长（毫秒）
  static const int animationDuration = 1200; // 动画时长（毫秒）
  static const int pageTransitionDuration = 300; // 页面过渡时长（毫秒）
  static const double logoSize = 120.0; // Logo 尺寸
  static const double shadowBlurRadius = 30.0; // 阴影模糊半径
  static const double shadowSpreadRadius = 10.0; // 阴影扩散半径
  static const double shadowAlpha = 0.3; // 阴影透明度
  static const double brandNameFontSize = 36.0; // 品牌名称字体大小
  static const double brandNameLetterSpacing = 4.0; // 品牌名称字间距
  static const double sloganFontSize = 14.0; // 标语字体大小
  static const double sloganLetterSpacing = 2.0; // 标语字间距
  static const double scaleAnimationBegin = 0.3; // 缩放动画起始值
  static const double scaleAnimationEnd = 1.0; // 缩放动画结束值
  static const double fadeAnimationIntervalBegin = 0.3; // 渐隐动画区间起始
  static const double fadeAnimationIntervalEnd = 1.0; // 渐隐动画区间结束
}
