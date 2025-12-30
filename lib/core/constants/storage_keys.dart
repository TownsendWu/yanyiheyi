/// 本地存储键常量
class StorageKeys {
  StorageKeys._();

  // 认证相关
  static const String authUser = 'auth_user';
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String tokenExpiresAt = 'token_expires_at';

  // 用户相关
  static const String userProfile = 'user_profile';
  static const String userPreferences = 'user_preferences';

  // 主题相关
  static const String themeMode = 'theme_mode';
  static const String fontSize = 'font_size';
  static const String customThemeColor = 'custom_theme_color';

  // 文章相关
  static const String pinnedArticles = 'pinned_articles';
  static const String draftArticles = 'draft_articles';
  static const String articlesData = 'articles_data'; // 文章数据
  static const String articlesInitialized = 'articles_initialized'; // 文章数据是否已初始化

  // 会员相关
  static const String membershipStatus = 'membership_status';
  static const String subscriptionExpiry = 'subscription_expiry';

  // 设置相关
  static const String firstLaunch = 'first_launch';
  static const String agreedToTerms = 'agreed_to_terms';
}
