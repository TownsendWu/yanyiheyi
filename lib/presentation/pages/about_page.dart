import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/page_container.dart';

/// 关于页面
///
/// 显示应用信息、版本号、开发者信息等
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo _packageInfo = PackageInfo(
    appName: '言意合一',
    packageName: 'unknown',
    version: '1.0.0',
    buildNumber: '1',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  /// 初始化包信息
  Future<void> _initPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _packageInfo = info;
      });
    } catch (e) {
      // 如果获取失败,使用默认值
      debugPrint('获取包信息失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('关于'),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
      ),
      body: PageContainer(
        child: ListView(
          children: [
            const SizedBox(height: 40),

            // Logo 和应用名称
            _buildAppHeader(context),

            const SizedBox(height: 40),

            // 版本信息
            _buildVersionCard(context),

            const SizedBox(height: 16),

            // 应用介绍
            _buildIntroductionCard(context),

            const SizedBox(height: 16),

            // 功能特性
            _buildFeaturesCard(context),

            const SizedBox(height: 16),

            // 开源协议
            _buildLicenseCard(context),

            const SizedBox(height: 16),

            // 链接
            _buildLinksCard(context),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// 应用头部 - Logo 和名称
  Widget _buildAppHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.primaryDark.withValues(alpha: 0.8), AppColors.primaryDark]
                  : [AppColors.primary.withValues(alpha: 0.8), AppColors.primary],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (isDark ? AppColors.primaryDark : AppColors.primary).withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.edit_note,
            size: 56,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        // 应用名称
        Text(
          '言意合一',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        // Slogan
        Text(
          '让写作成为一种习惯',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  /// 版本信息卡片
  Widget _buildVersionCard(BuildContext context) {
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
        children: [
          _buildInfoTile(
            context,
            icon: Icons.apps_outlined,
            title: '应用名称',
            value: _packageInfo.appName,
            showDivider: true,
          ),
          _buildInfoTile(
            context,
            icon: Icons.tag_outlined,
            title: '版本号',
            value: 'v${_packageInfo.version}',
            showDivider: true,
          ),
          _buildInfoTile(
            context,
            icon: Icons.build_outlined,
            title: '构建号',
            value: _packageInfo.buildNumber,
            showDivider: true,
          ),
          _buildInfoTile(
            context,
            icon: Icons.inventory_2_outlined,
            title: '包名',
            value: _packageInfo.packageName,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  /// 应用介绍卡片
  Widget _buildIntroductionCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '应用介绍',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '言意合一是一款专注于写作活动追踪的应用,帮助您建立持续的写作习惯,记录每一天的成长与进步。',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 功能特性卡片
  Widget _buildFeaturesCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(
                Icons.stars_outlined,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '主要功能',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            context,
            icon: Icons.calendar_today,
            title: '活动日历',
            description: '可视化展示每日写作活动,直观了解写作习惯',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            context,
            icon: Icons.edit_note,
            title: '富文本编辑',
            description: '支持丰富的文本格式,让创作更加自由',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            context,
            icon: Icons.insights,
            title: '数据统计',
            description: '多维度统计分析,追踪写作进度和成果',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            context,
            icon: Icons.palette_outlined,
            title: '主题切换',
            description: '支持浅色/深色主题,舒适护眼',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            context,
            icon: Icons.devices,
            title: '多平台支持',
            description: 'Android、iOS、Web、桌面端全覆盖',
          ),
        ],
      ),
    );
  }

  /// 功能特性项
  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.primaryDark.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.primaryDark : AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 开源协议卡片
  Widget _buildLicenseCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(
                Icons.gavel_outlined,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '开源协议',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '本应用采用 MIT 许可证开源,允许自由使用、修改和分发。',
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 链接卡片
  Widget _buildLinksCard(BuildContext context) {
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
        children: [
          _buildLinkTile(
            context,
            icon: Icons.code_outlined,
            title: '源代码',
            subtitle: 'GitHub 仓库',
            onTap: () {
              // TODO: 添加实际的 GitHub 链接
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('即将开放源代码仓库')),
              );
            },
            showDivider: true,
          ),
          _buildLinkTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: '隐私政策',
            subtitle: '了解我们如何保护您的隐私',
            onTap: () {
              _showPrivacyPolicyDialog(context);
            },
            showDivider: true,
          ),
          _buildLinkTile(
            context,
            icon: Icons.description_outlined,
            title: '用户协议',
            subtitle: '使用条款和条件',
            onTap: () {
              _showTermsDialog(context);
            },
            showDivider: true,
          ),
          _buildLinkTile(
            context,
            icon: Icons.favorite_outlined,
            title: '感谢支持',
            subtitle: '致谢与贡献',
            onTap: () {
              _showAcknowledgmentsDialog(context);
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  /// 信息列表项
  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required bool showDivider,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: subtitleColor,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: subtitleColor,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 58,
            color: isDark
                ? AppColors.darkTextSecondary.withValues(alpha: 0.1)
                : AppColors.lightTextSecondary.withValues(alpha: 0.1),
          ),
      ],
    );
  }

  /// 链接列表项
  Widget _buildLinkTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
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
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 58,
            color: isDark
                ? AppColors.darkTextSecondary.withValues(alpha: 0.1)
                : AppColors.lightTextSecondary.withValues(alpha: 0.1),
          ),
      ],
    );
  }

  /// 显示隐私政策对话框
  void _showPrivacyPolicyDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐私政策'),
        content: const SingleChildScrollView(
          child: Text(
            '言意合一隐私政策\n\n'
            '1. 数据收集\n'
            '我们不会收集或上传您的任何个人写作内容。所有数据均存储在您的本地设备上。\n\n'
            '2. 数据安全\n'
            '您的所有写作内容和个人信息都保存在本地,未经您的明确许可,绝不会上传到任何服务器。\n\n'
            '3. 第三方服务\n'
            '本应用不使用任何第三方分析工具或广告服务。\n\n'
            '4. 权限说明\n'
            '• 存储权限:用于保存您的写作内容和配置\n'
            '• 相机/相册权限:用于设置用户头像\n\n'
            '5. 联系我们\n'
            '如有任何隐私相关问题,请联系: support@yanyiheyi.com',
            style: TextStyle(fontSize: 13, height: 1.6),
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

  /// 显示用户协议对话框
  void _showTermsDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('用户协议'),
        content: const SingleChildScrollView(
          child: Text(
            '言意合一用户协议\n\n'
            '1. 服务说明\n'
            '言意合一是一款帮助用户追踪写作活动的应用,致力于帮助用户建立良好的写作习惯。\n\n'
            '2. 用户责任\n'
            '• 用户应对其创作的内容承担全部责任\n'
            '• 请勿发布违法违规、有害或侵犯他人权益的内容\n'
            '• 妥善保管个人账户信息\n\n'
            '3. 免责声明\n'
            '• 应用按"现状"提供服务,不提供任何明示或暗示的保证\n'
            '• 因不可抗力导致的服务中断,我们不承担责任\n'
            '• 我们保留随时修改或中断服务的权利\n\n'
            '4. 知识产权\n'
            '• 应用本身的知识产权归开发者所有\n'
            '• 用户创作的内容归用户所有\n\n'
            '5. 协议修改\n'
            '我们保留随时修改本协议的权利,修改后的协议一经公布即生效。',
            style: TextStyle(fontSize: 13, height: 1.6),
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

  /// 显示致谢对话框
  void _showAcknowledgmentsDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('感谢支持'),
        content: const SingleChildScrollView(
          child: Text(
            '特别感谢以下开源项目:\n\n'
            '• Flutter - Google 的跨平台 UI 框架\n'
            '• Provider - 状态管理解决方案\n'
            '• Flutter Quill - 富文本编辑器\n'
            '• 以及所有为 Flutter 生态系统做出贡献的开发者们\n\n'
            '感谢每一位用户的反馈和建议!\n\n'
            '言意合一团队的成长离不开您的支持。',
            style: TextStyle(fontSize: 13, height: 1.6),
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
}
