import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../core/theme/app_colors.dart';
import '../providers/activity_provider.dart';
import '../data/services/article_storage_service.dart';
import '../data/services/mock_data_service.dart';
import '../core/services/local_storage_service.dart';

/// 设置页面
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isResetting = false;

  Future<void> _resetData() async {
    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认重置'),
        content: const Text(
          '这将清除所有文章数据并从 JSON 文件重新加载。\n\n此操作不可撤销！',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('确认重置'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isResetting = true;
    });

    try {
      // 清除内存缓存
      MockDataService.clearCache();

      // 获取存储服务实例并重置数据
      final storageService = LocalStorageService.instance;
      final articleStorage = ArticleStorageService.getInstance(storageService);
      await articleStorage.resetToMockData();

      // 刷新 ActivityProvider 的数据
      if (mounted) {
        final activityProvider = context.read<ActivityProvider>();
        await activityProvider.refresh();

        // 显示成功提示
        Fluttertoast.showToast(
          msg: '数据已重置成功',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      // 显示错误提示
      if (mounted) {
        Fluttertoast.showToast(
          msg: '重置失败: $e',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResetting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkSurface : AppColors.lightBackground;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: ListView(
        children: [
          // 开发者选项
          _SectionHeader(
            title: '开发者选项',
            textColor: subtitleColor,
          ),
          _SettingCard(
            isDark: isDark,
            children: [
              _SettingItem(
                icon: Icons.refresh,
                iconColor: Colors.orange,
                title: '重置文章数据',
                subtitle: '从 JSON 文件重新加载文章数据',
                trailing: _isResetting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: _isResetting ? null : _resetData,
              ),
              _SettingItem(
                icon: Icons.info_outline,
                iconColor: Colors.blue,
                title: '当前文章数量',
                subtitle: '查看本地存储的文章总数',
                trailing: FutureBuilder<int>(
                  future: _getArticleCount(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    return Text(
                      '${snapshot.data ?? 0} 篇',
                      style: TextStyle(
                        color: subtitleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                onTap: null,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 应用信息
          _SectionHeader(
            title: '应用信息',
            textColor: subtitleColor,
          ),
          _SettingCard(
            isDark: isDark,
            children: [
              _SettingItem(
                icon: Icons.storage,
                iconColor: Colors.green,
                title: '数据存储',
                subtitle: '文章数据保存在本地 SharedPreferences',
                onTap: null,
              ),
              _SettingItem(
                icon: Icons.cloud_sync,
                iconColor: Colors.purple,
                title: '数据来源',
                subtitle: 'Mock API 服务 (开发模式)',
                onTap: null,
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<int> _getArticleCount() async {
    try {
      final storageService = LocalStorageService.instance;
      final articleStorage = ArticleStorageService.getInstance(storageService);
      final articles = await articleStorage.loadArticles();
      return articles.length;
    } catch (e) {
      return 0;
    }
  }
}

/// 分组标题
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color textColor;

  const _SectionHeader({
    required this.title,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// 设置卡片容器
class _SettingCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const _SettingCard({
    required this.isDark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
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

/// 设置项
class _SettingItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // 图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 22,
                color: iconColor,
              ),
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
                      fontWeight: FontWeight.w500,
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
            // 右侧内容
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ] else if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: subtitleColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
