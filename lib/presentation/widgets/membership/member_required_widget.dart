import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../common/error_widget.dart';

/// 需要会员权限的组件包装器
/// 如果用户不是会员或会员已过期，显示升级提示
class MemberRequiredWidget extends StatelessWidget {
  final Widget child;
  final bool isValidMember;
  final String? message;
  final VoidCallback? onUpgradeTap;

  const MemberRequiredWidget({
    super.key,
    required this.child,
    required this.isValidMember,
    this.message,
    this.onUpgradeTap,
  });

  @override
  Widget build(BuildContext context) {
    // 如果是有效会员，显示子组件
    if (isValidMember) {
      return child;
    }

    // 不是会员，显示升级提示
    return _buildUpgradePrompt(context);
  }

  Widget _buildUpgradePrompt(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_membership,
            size: 64,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            '此功能需要会员权限',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message ?? '升级会员即可解锁全部高级功能',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onUpgradeTap,
            icon: const Icon(Icons.upgrade),
            label: const Text('升级会员'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// 简化版：仅显示需要会员权限的提示组件
class MembershipPromptWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onUpgradeTap;

  const MembershipPromptWidget({
    super.key,
    this.message,
    this.onUpgradeTap,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyDataWidget(
      message: message ?? '此功能需要会员权限',
      icon: Icons.card_membership,
    );
  }
}
