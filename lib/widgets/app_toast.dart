import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// 应用自定义 Toast 提示组件
class AppToast {
  AppToast._();

  /// 显示成功提示
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    _showToast(
      context,
      message: message,
      icon: Icons.check_circle_outline,
      iconColor: AppColors.primary,
      duration: duration,
    );
  }

  /// 显示信息提示
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    final theme = Theme.of(context);
    _showToast(
      context,
      message: message,
      icon: Icons.info_outline,
      iconColor: theme.colorScheme.primary,
      duration: duration,
    );
  }

  /// 显示警告提示
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    _showToast(
      context,
      message: message,
      icon: Icons.warning_amber_outlined,
      iconColor: Colors.amber,
      duration: duration,
    );
  }

  /// 显示错误提示
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    final theme = Theme.of(context);
    _showToast(
      context,
      message: message,
      icon: Icons.error_outline,
      iconColor: theme.colorScheme.error,
      duration: duration,
    );
  }

  /// 显示自定义 Toast
  static void _showToast(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color iconColor,
    required Duration duration,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 检查 Scaffold 是否有 floatingActionButton
    final scaffold = Scaffold.of(context);
    final hasFab = scaffold.hasFloatingActionButton;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            // 图标
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // 消息文本
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        duration: duration,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: hasFab ? 80 : 12, // 如果有 FAB，向上偏移
          top: 12,
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: isDark ? 2 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
