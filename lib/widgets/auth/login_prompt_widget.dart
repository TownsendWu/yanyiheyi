import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 未登录提示组件
/// 显示在侧边菜单的用户信息区域,引导用户登录
class LoginPromptWidget extends StatelessWidget {
  final VoidCallback? onLoginTap;

  const LoginPromptWidget({
    super.key,
    this.onLoginTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return InkWell(
      onTap: onLoginTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(5, 40, 0, 20),
        child: Row(
          children: [
            // 默认头像
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.darkSurface
                    : AppColors.lightSurface,
                border: Border.all(
                  color: subtitleColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person_outline,
                size: 28,
                color: subtitleColor,
              ),
            ),
            const SizedBox(width: 16),
            // 提示文本
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '点击登录',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '登录后同步数据到云端',
                    style: TextStyle(
                      fontSize: 13,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            // 箭头图标
            Icon(
              Icons.chevron_right,
              size: 20,
              color: subtitleColor,
            ),
          ],
        ),
      ),
    );
  }
}
