import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import 'theme_mode_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ThemeProvider themeController;
  final VoidCallback onMenuPressed;

  const CustomAppBar({
    super.key,
    required this.themeController,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      leading: null,
      title: const _LogoWithNickname(),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () {
            // TODO: 实现搜索功能
            print('搜索按钮被点击');
          },
          icon: const Icon(Icons.search),
        ),
        ThemeModeButton(
          themeController: themeController,
        ),
        // 用户头像按钮
        _UserAvatarButton(onMenuPressed: onMenuPressed),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _LogoWithNickname extends StatelessWidget {
  const _LogoWithNickname();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // 未登录时只显示 Logo
    if (!authProvider.isAuthenticated) {
      return const _LogoWithAnimation();
    }

    // 已登录时显示 Logo + 昵称
    final userProvider = context.watch<UserProvider>();
    final userProfile = userProvider.userProfile;

    return Row(
      children: [
        const _LogoWithAnimation(),
        const SizedBox(width: 8),
        Text(
          userProfile.nickname,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _UserAvatarButton extends StatelessWidget {
  final VoidCallback onMenuPressed;

  const _UserAvatarButton({required this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final userProfile = userProvider.userProfile;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        onPressed: onMenuPressed,
        icon: CircleAvatar(
          radius: 16,
          backgroundColor: authProvider.isAuthenticated
              ? null
              : Colors.transparent,
          backgroundImage: (authProvider.isAuthenticated && userProfile.avatar != null)
              ? NetworkImage(userProfile.avatar!)
              : null,
          child: (!authProvider.isAuthenticated || userProfile.avatar == null)
              ? Icon(
                  Icons.person,
                  size: 20,
                  color: authProvider.isAuthenticated ? Colors.white : Colors.grey,
                )
              : null,
        ),
      ),
    );
  }
}

class _LogoWithAnimation extends StatefulWidget {
  const _LogoWithAnimation();

  @override
  State<_LogoWithAnimation> createState() => _LogoWithAnimationState();
}

class _LogoWithAnimationState extends State<_LogoWithAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_controller.isAnimating) return;
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // 轻微颤抖效果
          final progress = _controller.value;
          double rotation = 0;

          if (progress < 0.2) {
            // 向右微转
            rotation = progress * 5 * 0.08;
          } else if (progress < 0.4) {
            // 向左微转
            rotation = 0.08 - (progress - 0.2) * 5 * 0.16;
          } else if (progress < 0.6) {
            // 向右微转
            rotation = -0.08 + (progress - 0.4) * 5 * 0.16;
          } else if (progress < 0.8) {
            // 向左微转
            rotation = 0.08 - (progress - 0.6) * 5 * 0.16;
          } else {
            // 回到中心
            rotation = -0.08 + (progress - 0.8) * 5 * 0.08;
          }

          return Transform.rotate(
            angle: rotation,
            child: child,
          );
        },
        child: SvgPicture.asset(
          'assets/icons/icon.svg',
          width: 32,
          height: 32,
        ),
      ),
    );
  }
}
