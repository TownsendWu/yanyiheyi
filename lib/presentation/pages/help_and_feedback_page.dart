import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/page_container.dart';

/// 帮助与反馈页面
///
/// 提供使用帮助、常见问题、联系方式等功能
class HelpAndFeedbackPage extends StatelessWidget {
  const HelpAndFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('帮助与反馈'),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
      ),
      body: PageContainer(
        child: ListView(
          children: [
            const SizedBox(height: 20),

            // 欢迎语
            _buildWelcomeCard(context),

            const SizedBox(height: 24),

            // 使用指南
            _buildSectionCard(
              context,
              title: '使用指南',
              items: [
                _SectionItem(
                  icon: Icons.calendar_today_outlined,
                  title: '如何查看写作活动',
                  description: '在首页可以看到每日写作活动的日历视图',
                  onTap: () {
                    _showGuideDialog(context, '查看写作活动', '''
在首页的日历视图中,您可以:

• 每个方块代表一天
• 颜色越深表示当天的写作量越大
• 点击日期可以查看当天的写作详情
• 支持按月/周切换视图
                    ''');
                  },
                ),
                _SectionItem(
                  icon: Icons.edit_outlined,
                  title: '如何记录写作',
                  description: '点击右下角的按钮开始写作',
                  onTap: () {
                    _showGuideDialog(context, '记录写作', '''
开始写作很简单:

• 点击首页右下角的 + 按钮
• 选择写作类型(日记/文章/随笔等)
• 使用富文本编辑器创作内容
• 保存后自动记录到日历中
                    ''');
                  },
                ),
                _SectionItem(
                  icon: Icons.person_outline,
                  title: '如何编辑个人信息',
                  description: '在侧边栏点击头像区域进行编辑',
                  onTap: () {
                    _showGuideDialog(context, '编辑个人信息', '''
个性化您的资料:

• 打开侧边菜单
• 点击顶部的头像区域
• 可以修改昵称、邮箱、简介
• 支持设置自定义头像
                    ''');
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 常见问题
            _buildSectionCard(
              context,
              title: '常见问题',
              items: [
                _SectionItem(
                  icon: Icons.cloud_outlined,
                  title: '数据会丢失吗?',
                  description: '了解数据存储和备份机制',
                  onTap: () {
                    _showGuideDialog(context, '数据安全', '''
数据安全说明:

• 所有数据均存储在本地设备
• 建议定期导出重要内容
• 未来版本将支持云端同步
• 卸载应用前请先备份数据
                    ''');
                  },
                ),
                _SectionItem(
                  icon: Icons.sync_outlined,
                  title: '如何同步数据?',
                  description: '多设备数据同步方案',
                  onTap: () {
                    _showGuideDialog(context, '数据同步', '''
多设备同步:

• 目前版本仅支持单设备使用
• 云端同步功能正在开发中
• 敬请期待后续版本更新
                    ''');
                  },
                ),
                _SectionItem(
                  icon: Icons.security_outlined,
                  title: '隐私保护',
                  description: '了解我们如何保护您的隐私',
                  onTap: () {
                    _showGuideDialog(context, '隐私保护', '''
隐私保护承诺:

• 您的所有写作内容完全私密
• 不会上传到任何服务器
• 不收集任何个人信息
• 本地存储,安全可控
                    ''');
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 联系我们
            _buildContactCard(context),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// 欢迎卡片
  Widget _buildWelcomeCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.primaryDark.withValues(alpha: 0.8), AppColors.primaryDark]
              : [AppColors.primary.withValues(alpha: 0.8), AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.help_outline,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '您好,有什么可以帮您?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '查看使用指南或提交反馈',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 分组卡片
  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<_SectionItem> items,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          // 列表项
          ...items.map((item) => _buildSectionItemTile(context, item)),
        ],
      ),
    );
  }

  /// 单个列表项
  Widget _buildSectionItemTile(BuildContext context, _SectionItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      children: [
        InkWell(
          onTap: item.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.primaryDark.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    size: 22,
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: subtitleColor,
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          indent: 66,
          color: isDark
              ? AppColors.darkTextSecondary.withValues(alpha: 0.1)
              : AppColors.lightTextSecondary.withValues(alpha: 0.1),
        ),
      ],
    );
  }

  /// 联系我们卡片
  Widget _buildContactCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              '联系我们',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildContactItem(
            context,
            icon: Icons.email_outlined,
            title: '发送邮件',
            subtitle: 'support@yanyiheyi.com',
            onTap: () {
              _launchEmail('support@yanyiheyi.com');
            },
          ),
          Divider(
            height: 1,
            thickness: 1,
            indent: 66,
            color: isDark
                ? AppColors.darkTextSecondary.withValues(alpha: 0.1)
                : AppColors.lightTextSecondary.withValues(alpha: 0.1),
          ),
          _buildContactItem(
            context,
            icon: Icons.feedback_outlined,
            title: '提交反馈',
            subtitle: '告诉我们您的建议',
            onTap: () {
              _showFeedbackDialog(context);
            },
          ),
          Divider(
            height: 1,
            thickness: 1,
            indent: 66,
            color: isDark
                ? AppColors.darkTextSecondary.withValues(alpha: 0.1)
                : AppColors.lightTextSecondary.withValues(alpha: 0.1),
          ),
          _buildContactItem(
            context,
            icon: Icons.bug_report_outlined,
            title: '报告问题',
            subtitle: '遇到问题了?我们来帮忙',
            onTap: () {
              _showFeedbackDialog(context, isBug: true);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// 联系方式列表项
  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: subtitleColor,
            ),
            const SizedBox(width: 16),
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

  /// 显示指南对话框
  void _showGuideDialog(BuildContext context, String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(
          content.trim(),
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: subtitleColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '我知道了',
              style: TextStyle(
                color: isDark ? AppColors.primaryDark : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示反馈对话框
  void _showFeedbackDialog(BuildContext context, {bool isBug = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isBug ? '报告问题' : '提交反馈'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: isBug ? '请描述您遇到的问题...' : '请告诉我们您的建议或想法...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isBug ? '问题报告已提交,感谢您的反馈!' : '反馈已提交,感谢您的建议!'),
                    backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
                );
              }
            },
            child: Text(
              '提交',
              style: TextStyle(
                color: isDark ? AppColors.primaryDark : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 发送邮件
  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=言意合一 - 用户反馈',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw '无法打开邮件应用';
    }
  }
}

/// 分组项数据模型
class _SectionItem {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  _SectionItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });
}
