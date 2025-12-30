import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../main.dart' show navigatorKey;

/// 应用自定义 Toast 提示组件
/// 基于 FlutterToast 的 FToast 实现，支持队列管理和多种位置
class AppToast {
  AppToast._();

  /// 单例 FToast 实例
  static FToast? _fToast;

  /// 获取 FToast 实例，按需初始化
  static FToast get _instance {
    _fToast ??= FToast();
    _fToast!.init(navigatorKey.currentContext!);
    return _fToast!;
  }

  /// 显示成功提示
  static void showSuccess(
    String message, {
    Duration duration = const Duration(milliseconds: 1500),
    ToastGravity gravity = ToastGravity.TOP,
  }) {
    _showToast(
      message: message,
      duration: duration,
      gravity: gravity,
    );
  }

  /// 显示信息提示
  static void showInfo(
    String message, {
    Duration duration = const Duration(milliseconds: 1500),
    ToastGravity gravity = ToastGravity.TOP,
  }) {
    _showToast(
      message: message,
      duration: duration,
      gravity: gravity,
    );
  }

  /// 显示警告提示
  static void showWarning(
    String message, {
    Duration duration = const Duration(milliseconds: 2000),
    ToastGravity gravity = ToastGravity.TOP,
  }) {
    _showToast(
      message: message,
      duration: duration,
      gravity: gravity,
    );
  }

  /// 显示错误提示
  static void showError(
    String message, {
    Duration duration = const Duration(milliseconds: 2000),
    ToastGravity gravity = ToastGravity.TOP,
  }) {
    _showToast(
      message: message,
      duration: duration,
      gravity: gravity,
    );
  }

  /// 显示自定义 Toast
  static void _showToast({
    required String message,
    required Duration duration,
    ToastGravity gravity = ToastGravity.TOP,
  }) {
    final fToast = _instance;

    // 创建自定义 Toast widget
    final toast = _ToastWidget(message: message);

    // 显示 Toast
    fToast.showToast(
      child: toast,
      gravity: gravity,
      toastDuration: duration,
      fadeDuration: const Duration(milliseconds: 300),
      isDismissible: true, // 支持点击关闭
    );
  }

  /// 移除当前显示的 Toast
  static void removeCustomToast() {
    _fToast?.removeCustomToast();
  }

  /// 移除所有排队等待的 Toast
  static void removeQueuedCustomToasts() {
    _fToast?.removeQueuedCustomToasts();
  }
}

/// Toast Widget - 基于 Container 的自定义 UI
class _ToastWidget extends StatelessWidget {
  final String message;

  const _ToastWidget({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
            blurRadius: isDark ? 8 : 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 15,
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
