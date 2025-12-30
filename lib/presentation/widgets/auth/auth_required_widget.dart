import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../common/error_widget.dart';

/// 需要登录的组件包装器
/// 如果用户未登录，显示提示登录的界面
class AuthRequiredWidget extends StatelessWidget {
  final Widget child;
  final String userId;
  final bool isAuthenticated;
  final VoidCallback? onLoginTap;

  const AuthRequiredWidget({
    super.key,
    required this.child,
    required this.userId,
    required this.isAuthenticated,
    this.onLoginTap,
  });

  @override
  Widget build(BuildContext context) {
    // 如果已登录，显示子组件
    if (isAuthenticated) {
      return child;
    }

    // 未登录，显示提示
    return _buildLoginPrompt(context);
  }

  Widget _buildLoginPrompt(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 64,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            '请先登录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '登录后即可使用此功能',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onLoginTap,
            icon: const Icon(Icons.login),
            label: const Text('立即登录'),
          ),
        ],
      ),
    );
  }
}

/// 简化版：仅显示需要登录提示的组件
class LoginPromptWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onLoginTap;

  const LoginPromptWidget({
    super.key,
    this.message,
    this.onLoginTap,
  });

  @override
  Widget build(BuildContext context) {
    return const EmptyDataWidget(
      message: '请先登录后使用此功能',
      icon: Icons.lock_outline,
    );
  }
}
