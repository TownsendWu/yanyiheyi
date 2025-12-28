import 'dart:async';
import 'package:flutter/material.dart';

/// 可拖动关闭的 SideSheet 包装器
/// 支持向右拖动右侧侧边栏来关闭它
class DraggableSideSheet {
  /// 显示右侧可拖动关闭的侧边栏
  static Future<T?> right<T>({
    required BuildContext context,
    required Widget body,
    double? width,
    bool barrierDismissible = true,
  }) {
    return Navigator.of(context).push<T>(
      DraggableSideSheetRoute<T>(
        builder: (context) => body,
        width: width,
        barrierDismissible: barrierDismissible,
        sheetSide: SheetSide.right,
      ),
    );
  }

  /// 显示左侧可拖动关闭的侧边栏
  static Future<T?> left<T>({
    required BuildContext context,
    required Widget body,
    double? width,
    bool barrierDismissible = true,
  }) {
    return Navigator.of(context).push<T>(
      DraggableSideSheetRoute<T>(
        builder: (context) => body,
        width: width,
        barrierDismissible: barrierDismissible,
        sheetSide: SheetSide.left,
      ),
    );
  }
}

/// 侧边栏方向枚举
enum SheetSide { left, right }

/// 可拖动的侧边栏路由
class DraggableSideSheetRoute<T> extends PopupRoute<T> {
  final WidgetBuilder builder;
  final double? width;
  final Color? sheetBarrierColor;
  final bool sheetBarrierDismissible;
  final SheetSide sheetSide;

  DraggableSideSheetRoute({
    required this.builder,
    this.width,
    Color? barrierColor,
    bool barrierDismissible = true,
    required this.sheetSide,
  })  : sheetBarrierColor = barrierColor,
        sheetBarrierDismissible = barrierDismissible;

  @override
  Color? get barrierColor => sheetBarrierColor ?? Colors.black54;

  @override
  bool get barrierDismissible => sheetBarrierDismissible;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 250);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sheetWidth = width ?? screenWidth * 0.8;

    return _DraggableSideSheetPage<T>(
      route: this,
      builder: builder,
      sheetWidth: sheetWidth,
      sheetSide: sheetSide,
      animation: animation,
    );
  }
}

/// 可拖动的侧边栏页面
class _DraggableSideSheetPage<T> extends StatefulWidget {
  final DraggableSideSheetRoute<T> route;
  final WidgetBuilder builder;
  final double sheetWidth;
  final SheetSide sheetSide;
  final Animation<double> animation;

  const _DraggableSideSheetPage({
    required this.route,
    required this.builder,
    required this.sheetWidth,
    required this.sheetSide,
    required this.animation,
  });

  @override
  State<_DraggableSideSheetPage<T>> createState() =>
      _DraggableSideSheetPageState<T>();
}

class _DraggableSideSheetPageState<T>
    extends State<_DraggableSideSheetPage<T>> {
  double _dragOffset = 0.0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: Navigator.of(context),
      duration: widget.route.transitionDuration,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      // 根据侧边栏方向计算偏移量
      if (widget.sheetSide == SheetSide.right) {
        // 右侧侧边栏:向右拖动为正偏移
        _dragOffset += details.delta.dx;
        // 限制最大偏移量
        if (_dragOffset < 0) _dragOffset = 0;
        if (_dragOffset > widget.sheetWidth) _dragOffset = widget.sheetWidth;
      } else {
        // 左侧侧边栏:向左拖动为负偏移
        _dragOffset += details.delta.dx;
        // 限制最小偏移量
        if (_dragOffset > 0) _dragOffset = 0;
        if (_dragOffset < -widget.sheetWidth) _dragOffset = -widget.sheetWidth;
      }
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    // 判断是否应该关闭侧边栏
    final threshold = widget.sheetWidth * 0.3; // 拖动超过 30% 即关闭

    if (widget.sheetSide == SheetSide.right) {
      if (_dragOffset > threshold) {
        // 关闭侧边栏
        Navigator.of(context).pop();
      } else {
        // 回弹
        setState(() {
          _dragOffset = 0;
        });
      }
    } else {
      if (_dragOffset < -threshold) {
        // 关闭侧边栏
        Navigator.of(context).pop();
      } else {
        // 回弹
        setState(() {
          _dragOffset = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onHorizontalDragUpdate: _handleDragUpdate,
        onHorizontalDragEnd: _handleDragEnd,
        behavior: HitTestBehavior.translucent,
        child: AnimatedBuilder(
          animation: widget.animation,
          builder: (context, child) {
            // 计算滑入/滑出的偏移量
            final slideOffset = widget.sheetSide == SheetSide.right
                ? (1 - widget.animation.value) * widget.sheetWidth
                : -(1 - widget.animation.value) * widget.sheetWidth;

            // 组合动画偏移和拖动偏移
            final totalOffset = slideOffset +
                (widget.sheetSide == SheetSide.right
                    ? _dragOffset
                    : -_dragOffset);

            return Stack(
              children: [
                // 遮罩层
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      if (widget.route.barrierDismissible) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      color: widget.route.barrierColor?.withValues(
                          alpha: widget.animation.value * 0.5),
                    ),
                  ),
                ),
                // 侧边栏内容
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: widget.sheetSide == SheetSide.right
                      ? screenWidth - widget.sheetWidth + totalOffset
                      : totalOffset,
                  width: widget.sheetWidth,
                  child: child!,
                ),
              ],
            );
          },
          child: Builder(builder: widget.builder),
        ),
      ),
    );
  }
}
