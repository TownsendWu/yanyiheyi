import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

/// 主题模式切换按钮
/// 支持浅色/深色模式切换
class ThemeModeButton extends StatelessWidget {
  /// 主题控制器
  final ThemeProvider themeController;

  const ThemeModeButton({
    super.key,
    required this.themeController,
  });

  /// 根据主题模式获取对应的图标
  /// 显示切换后的图标（当前是深色就显示太阳，当前是浅色就显示月亮）
  IconData _getIcon(ThemeMode mode) {
    return mode == ThemeMode.dark
        ? Icons.light_mode // 当前深色，显示太阳（点击后切换到浅色）
        : Icons.dark_mode; // 当前浅色，显示月亮（点击后切换到深色）
  }

  /// 根据主题模式获取提示文本
  /// 显示切换后的模式提示
  String _getTooltip(ThemeMode mode) {
    return mode == ThemeMode.dark ? '切换到浅色模式' : '切换到深色模式';
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => themeController.toggleTheme(),
      icon: Icon(_getIcon(themeController.themeMode)),
      tooltip: _getTooltip(themeController.themeMode),
    );
  }
}
