import 'package:flutter/material.dart';

/// 应用的统一颜色配置
/// 定义浅色和深色主题的所有颜色常量
class AppColors {
  // 私有构造函数，防止实例化
  AppColors._();

  // ==================== 主色调 ====================
  /// 主色调 - 绿色（浅色主题）
  static const primary = Color(0xFF53C68C);

  /// 主色调 - 深色主题下的绿色（更暗的绿色）
  static const primaryDark = Color(0xFF3A8F62);

  // ==================== 浅色主题颜色 ====================
  /// 浅色主题 - 背景色
  static const lightBackground = Color(0xFFFAFAFA);

  /// 浅色主题 - 表面色（卡片、对话框等）
  static const lightSurface = Color(0xFFFFFFFF);

  /// 浅色主题 - AppBar 背景色
  static const lightAppBarBackground = Color(0xFFFAFAFA);

  /// 浅色主题 - 主要文本颜色
  static const lightTextPrimary = Color(0xFF000000);

  /// 浅色主题 - 次要文本颜色（54% 不透明度）
  static const lightTextSecondary = Color(0x8A000000);

  /// 浅色主题 - 图标颜色
  static const lightIcon = Color(0xFF000000);

  // ==================== 深色主题颜色 ====================
  /// 深色主题 - 背景色
  static const darkBackground = Color(0xFF121212);

  /// 深色主题 - 表面色（卡片、对话框等）
  static const darkSurface = Color(0xFF1E1E1E);

  /// 深色主题 - AppBar 背景色
  static const darkAppBarBackground = Color(0xFF1E1E1E);

  /// 深色主题 - 主要文本颜色
  static const darkTextPrimary = Color(0xFFFFFFFF);

  /// 深色主题 - 次要文本颜色（70% 不透明度）
  static const darkTextSecondary = Color(0xB3FFFFFF);

  /// 深色主题 - 图标颜色
  static const darkIcon = Color(0xFFFFFFFF);

  // ==================== 日历组件专用颜色 ====================
  /// 日历 - 浅色主题空数据颜色
  static const calendarLightEmpty = Color(0xFFEEEEEE);

  /// 日历 - 深色主题空数据颜色
  static const calendarDarkEmpty = Color(0xFF2D333B);

  // ==================== 文章列表专用颜色 ====================
  /// 文章列表标题 - 浅色主题颜色（红色）
  static const articleListTitleLight = Color(0xFFCB2A42);

  /// 文章列表标题 - 深色主题颜色（绿色）
  static const articleListTitleDark = Color(0xFF53C68C);
}
