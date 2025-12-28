import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// 侧边菜单的内容组件
///
/// 提供常见的菜单选项,如设置、关于等
class MenuContent extends StatelessWidget {
  const MenuContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkSurface : AppColors.lightBackground;

    return Container(
      color: backgroundColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户信息区域
              _UserInfoSection(),

              // const SizedBox(height: 10),

              // 菜单选项列表 - 使用卡片风格
              _MenuCard(
                items: [
                  _MenuItem(
                    icon: Icons.card_membership,
                    title: '订阅会员',
                    subtitle: '查看会员权益',
                    onTap: () {
                      Navigator.pop(context);
                      print('打开订阅会员');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.smart_toy_outlined,
                    title: 'AI设置',
                    subtitle: '配置AI助手',
                    onTap: () {
                      Navigator.pop(context);
                      print('打开AI设置');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.notifications_outlined,
                    title: '通知',
                    subtitle: '管理通知偏好',
                    onTap: () {
                      Navigator.pop(context);
                      print('打开通知');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _MenuCard(
                items: [
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    title: '设置',
                    subtitle: '应用设置和偏好',
                    onTap: () {
                      Navigator.pop(context);
                      print('打开设置');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.help_outline,
                    title: '帮助与反馈',
                    subtitle: '使用帮助和问题反馈',
                    onTap: () {
                      Navigator.pop(context);
                      print('打开帮助与反馈');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.info_outline,
                    title: '关于',
                    subtitle: '应用信息和版本',
                    onTap: () {
                      Navigator.pop(context);
                      print('打开关于');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// 用户信息区域
class _UserInfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(5, 40, 0, 20),
      // decoration: BoxDecoration(
      //   border: Border(
      //     bottom: BorderSide(
      //       color: subtitleColor.withValues(alpha: 0.1),
      //       width: 1,
      //     ),
      //   ),
      // ),
      child: Row(
        children: [
          // 头像
          CircleAvatar(
            radius: 28,
            backgroundColor: isDark
                ? AppColors.primaryDark
                : AppColors.primary,
            child: const Icon(
              Icons.person,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          // 用户名和签名
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户名
                Text(
                  '扭动的妖怪蝙蝠',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                // 签名
                Text(
                  '记录生活，分享思考',
                  style: TextStyle(
                    fontSize: 13,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 卡片风格的菜单组
class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuCard({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                indent: 56,
                color: isDark
                    ? AppColors.darkTextSecondary.withValues(alpha: 0.1)
                    : AppColors.lightTextSecondary.withValues(alpha: 0.1),
              ),
          ],
        ],
      ),
    );
  }
}

/// 单个菜单项
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
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
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // 图标
            Icon(
              icon,
              size: 24,
              color: subtitleColor,
            ),
            const SizedBox(width: 12),
            // 标题和副标题
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
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
