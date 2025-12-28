import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/activity_provider.dart';
import 'home_page.dart';

/// 开屏页
/// 显示应用 Logo 和品牌名称,带有动画效果
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConstants.animationDuration),
    );

    // 创建缩放动画
    _scaleAnimation = Tween<double>(
      begin: AppConstants.scaleAnimationBegin,
      end: AppConstants.scaleAnimationEnd,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    // 创建渐隐动画
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          AppConstants.fadeAnimationIntervalBegin,
          AppConstants.fadeAnimationIntervalEnd,
          curve: Curves.easeInOut,
        ),
      ),
    );

    // 启动动画
    _animationController.forward();

    // 延迟到 build 阶段后预加载数据，避免在 build 期间调用 setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activityProvider = context.read<ActivityProvider>();
      activityProvider.preload();
    });

    // 1.8秒后自动跳转到主页
    Timer(
      const Duration(milliseconds: AppConstants.splashDuration),
      () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomePage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(
              milliseconds: AppConstants.pageTransitionDuration,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // 创建渐变背景
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF121212),
                    const Color(0xFF1E1E1E),
                    const Color(0xFF252525),
                  ]
                : [
                    const Color(0xFFFAFAFA),
                    const Color(0xFFF5F5F5),
                    const Color(0xFFEEEEEE),
                  ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo 图标
                      Container(
                        width: AppConstants.logoSize,
                        height: AppConstants.logoSize,
                        decoration: BoxDecoration(
                          // 添加柔和的阴影效果
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(
                                alpha: AppConstants.shadowAlpha,
                              ),
                              blurRadius: AppConstants.shadowBlurRadius,
                              spreadRadius: AppConstants.shadowSpreadRadius,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: SvgPicture.asset(
                          'lib/assets/icon.svg',
                          width: AppConstants.logoSize,
                          height: AppConstants.logoSize,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // 品牌名称
                      Text(
                        '言意合一',
                        style: TextStyle(
                          fontSize: AppConstants.brandNameFontSize,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                          letterSpacing: AppConstants.brandNameLetterSpacing,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 副标题/标语
                      Text(
                        '记录每一次书写的足迹',
                        style: TextStyle(
                          fontSize: AppConstants.sloganFontSize,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          letterSpacing: AppConstants.sloganLetterSpacing,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
