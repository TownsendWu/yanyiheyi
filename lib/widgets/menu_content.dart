import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../data/models/user_profile.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../pages/user_profile_edit_page.dart';
import '../pages/help_and_feedback_page.dart';
import '../pages/about_page.dart';
import '../pages/settings_page.dart';
import 'auth/login_prompt_widget.dart';

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
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.help_outline,
                    title: '帮助与反馈',
                    subtitle: '使用帮助和问题反馈',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpAndFeedbackPage(),
                        ),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.info_outline,
                    title: '关于',
                    subtitle: '应用信息和版本',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutPage(),
                        ),
                      );
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
    final authProvider = context.watch<AuthProvider>();

    // 未登录时显示登录提示
    if (!authProvider.isAuthenticated) {
      return LoginPromptWidget(
        onLoginTap: () => _showLoginBottomSheet(context),
      );
    }

    // 已登录时显示用户信息
    final userProvider = context.watch<UserProvider>();
    final userProfile = userProvider.userProfile;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return InkWell(
      onTap: () async {
        // 跳转到用户信息编辑页面
        final updatedProfile = await Navigator.push<UserProfile>(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileEditPage(
              initialProfile: userProfile,
            ),
          ),
        );

        // 如果用户修改了信息，更新全局状态
        if (updatedProfile != null) {
          userProvider.updateUserProfile(updatedProfile);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(5, 40, 0, 20),
        child: Row(
          children: [
            // 头像
            CircleAvatar(
              radius: 28,
              backgroundColor: isDark
                  ? AppColors.primaryDark
                  : AppColors.primary,
              backgroundImage: userProfile.avatar != null
                  ? NetworkImage(userProfile.avatar!)
                  : null,
              child: userProfile.avatar == null
                  ? const Icon(
                      Icons.person,
                      size: 28,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // 用户名和签名
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 用户名
                  Text(
                    userProfile.nickname,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 签名
                  Text(
                    userProfile.bio ?? '',
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
      ),
    );
  }

  /// 显示登录底部弹窗
  void _showLoginBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LoginBottomSheet(),
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

/// 登录底部弹窗
class _LoginBottomSheet extends StatefulWidget {
  @override
  State<_LoginBottomSheet> createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends State<_LoginBottomSheet> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isSendingCode = false;
  bool _isLoggingIn = false;
  int? _countdown;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 标题
              Row(
                children: [
                  Text(
                    '登录',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: subtitleColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '登录后可同步数据到云端',
                style: TextStyle(
                  fontSize: 14,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 24),

              // 手机号输入
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: InputDecoration(
                  labelText: '手机号',
                  hintText: '请输入手机号',
                  prefixIcon: const Icon(Icons.phone),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 验证码输入
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: '验证码',
                        hintText: '请输入验证码',
                        prefixIcon: const Icon(Icons.verified),
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _countdown == null && !_isSendingCode
                          ? _sendVerificationCode
                          : null,
                      child: _isSendingCode
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              _countdown != null
                                  ? '${_countdown}秒'
                                  : '获取验证码',
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 登录按钮
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoggingIn ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? AppColors.primaryDark : AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoggingIn
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '登录',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // 游客模式
              TextButton(
                onPressed: () => _handleGuestMode(context),
                child: Text(
                  '暂不登录，继续使用',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 发送验证码
  void _sendVerificationCode() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 11) {
      _showError('请输入正确的手机号');
      return;
    }

    setState(() => _isSendingCode = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.sendVerificationCode(phone);

      if (mounted) {
        setState(() => _isSendingCode = false);
        if (success) {
          _startCountdown();
          _showSuccess('验证码已发送');
        } else {
          _showError('发送失败,请重试');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSendingCode = false);
        _showError('发送失败,请重试');
      }
    }
  }

  /// 开始倒计时
  void _startCountdown() {
    setState(() => _countdown = 60);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _countdown = _countdown! - 1);
      return _countdown! > 0;
    });
  }

  /// 处理登录
  void _handleLogin() async {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();

    if (phone.length != 11) {
      _showError('请输入正确的手机号');
      return;
    }

    if (code.isEmpty) {
      _showError('请输入验证码');
      return;
    }

    setState(() => _isLoggingIn = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.loginWithPhone(phone, code);

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          _showSuccess('登录成功');
        } else {
          setState(() => _isLoggingIn = false);
          final error = authProvider.error;
          _showError(error?.message ?? '登录失败,请重试');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoggingIn = false);
        _showError('登录失败,请重试');
      }
    }
  }

  /// 处理游客模式
  void _handleGuestMode(BuildContext context) async {
    Navigator.pop(context);
    // 游客模式不需要额外操作，AuthProvider 已经初始化为游客
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
