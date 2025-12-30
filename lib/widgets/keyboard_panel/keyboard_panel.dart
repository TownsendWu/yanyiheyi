import 'package:flutter/material.dart';

/// 键盘上方面板组件
///
/// 手动控制显示/隐藏，适合配合输入框使用
/// 包含可选的标题和自定义内容区域
///
/// 使用示例:
/// ```dart
/// // 1. 创建 controller
/// final _panelController = KeyboardPanelController();
///
/// // 2. 使用组件
/// KeyboardPanel(
///   controller: _panelController,
///   title: '快捷操作',
///   child: TextField(...),
/// )
///
/// // 3. 需要显示时调用
/// _panelController.show();
///
/// // 4. 需要隐藏时调用
/// _panelController.hide();
/// ```
class KeyboardPanel extends StatefulWidget {
  /// 面板控制器（用于控制显示/隐藏）
  final KeyboardPanelController? controller;

  /// 面板标题（可选）
  final String? title;

  /// 内容区域
  final Widget child;

  /// 面板背景色
  final Color? backgroundColor;

  /// 面板圆角
  final BorderRadius? borderRadius;

  /// 面板内边距
  final EdgeInsetsGeometry? padding;

  /// 标题样式
  final TextStyle? titleStyle;

  /// 是否显示分割线
  final bool showDivider;

  /// 面板高度（null 表示自适应）
  final double? height;

  /// 是否启用安全区域（避开底部安全区域）
  final bool enableSafeArea;

  const KeyboardPanel({
    super.key,
    this.controller,
    this.title,
    required this.child,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.titleStyle,
    this.showDivider = true,
    this.height,
    this.enableSafeArea = true,
  });

  @override
  State<KeyboardPanel> createState() => _KeyboardPanelState();
}

class _KeyboardPanelState extends State<KeyboardPanel> {
  /// 是否显示面板
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // 注册 controller
    widget.controller?._attach(this);
  }

  @override
  void dispose() {
    // 注销 controller
    widget.controller?._detach();
    super.dispose();
  }

  @override
  void didUpdateWidget(KeyboardPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果 controller 变化，重新注册
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(this);
    }
  }

  /// 显示面板
  void show() {
    if (mounted && !_isVisible) {
      setState(() {
        _isVisible = true;
      });
    }
  }

  /// 隐藏面板
  void hide() {
    if (mounted && _isVisible) {
      setState(() {
        _isVisible = false;
      });
    }
  }

  /// 切换面板显示状态
  void toggle() {
    if (mounted) {
      setState(() {
        _isVisible = !_isVisible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final panelBackgroundColor =
        widget.backgroundColor ?? theme.colorScheme.surface;
    final defaultBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    );
    final panelPadding = widget.padding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      height: widget.height,
      decoration: BoxDecoration(
        color: panelBackgroundColor,
        borderRadius: widget.borderRadius ?? defaultBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: widget.enableSafeArea,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题区域
            if (widget.title != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  widget.title!,
                  style: widget.titleStyle ??
                      TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                ),
              ),
              if (widget.showDivider)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                ),
            ],
            // 内容区域
            Padding(
              padding: widget.title != null
                  ? panelPadding
                  : const EdgeInsets.all(16),
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}

/// 键盘面板控制器
///
/// 用于控制 KeyboardPanel 的显示和隐藏
class KeyboardPanelController {
  _KeyboardPanelState? _state;

  /// 绑定到面板
  void _attach(_KeyboardPanelState state) {
    _state = state;
  }

  /// 解绑面板
  void _detach() {
    _state = null;
  }

  /// 显示面板
  void show() {
    _state?.show();
  }

  /// 隐藏面板
  void hide() {
    _state?.hide();
  }

  /// 切换面板显示状态
  void toggle() {
    _state?.toggle();
  }

  /// 当前是否显示
  bool get isVisible => _state != null && _state!._isVisible;

  /// 释放资源（可选调用）
  void dispose() {
    _detach();
  }
}
