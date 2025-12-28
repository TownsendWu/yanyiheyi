import 'package:flutter/material.dart';

/// 统一的页面容器，所有页面都应该使用这个组件
class PageContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? extraPadding; // 额外的 padding，会与默认值相加

  const PageContainer({
    super.key,
    required this.child,
    this.padding,
    this.extraPadding,
  });

  @override
  Widget build(BuildContext context) {
    // 计算最终的 padding
    EdgeInsetsGeometry effectivePadding;

    if (padding != null) {
      // 如果提供了 padding，直接使用
      effectivePadding = padding!;
    } else if (extraPadding != null) {
      // 如果提供了 extraPadding，与默认值合并
      effectivePadding = EdgeInsets.only(
        left: 20,
        right: 20,
        top: (extraPadding as EdgeInsets).top,
        bottom: (extraPadding as EdgeInsets).bottom,
      );
    } else {
      // 使用默认值
      effectivePadding = const EdgeInsets.symmetric(horizontal: 20);
    }

    return Padding(
      padding: effectivePadding,
      child: child,
    );
  }
}
