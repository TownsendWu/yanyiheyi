import 'package:flutter/material.dart';

class ExpandableFAB extends StatefulWidget {
  final List<FABItem> items;
  final double? offsetFromBottom; // 距离底部的偏移量
  final double buttonSize; // 按钮大小（默认 56）
  final double expandedButtonSize; // 展开按钮大小（默认 40）
  final double spacing; // 按钮之间的间距（默认 8）
  final double offsetFromRight; // 距离右边的偏移量（默认 16）

  const ExpandableFAB({
    super.key,
    required this.items,
    this.offsetFromBottom,
    this.buttonSize = 56,
    this.expandedButtonSize = 40,
    this.spacing = 8,
    this.offsetFromRight = 16,
  });

  @override
  State<ExpandableFAB> createState() => _ExpandableFABState();
}

class _ExpandableFABState extends State<ExpandableFAB>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.easeInOut,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 当展开时,添加一个全屏的透明覆盖层来捕获点击事件
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggle,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),

        // FAB 按钮本身
        Align(
          alignment: Alignment.bottomRight,
          child: Transform.translate(
            offset: Offset(-widget.offsetFromRight, widget.offsetFromBottom ?? 0),
            child: SizedBox(
              width: widget.buttonSize,
              height: widget.buttonSize +
                  (widget.items.length * widget.expandedButtonSize) +
                  (widget.items.length * widget.spacing),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // 展开的按钮列表
                  if (_isExpanded)
                    ...widget.items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return _buildItemButton(item, index);
                    }),

                  // 主按钮
                  _buildMainButton(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainButton() {
    return SizedBox(
      width: widget.buttonSize,
      height: widget.buttonSize,
      child: FloatingActionButton(
        heroTag: 'main_fab',
        onPressed: _toggle,
        elevation: 0, // 去掉阴影
        highlightElevation: 0, // 去掉点击高亮阴影
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: AnimatedRotation(
          turns: _isExpanded ? 0.125 : 0,
          duration: const Duration(milliseconds: 250),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildItemButton(FABItem item, int index) {
    // 计算按钮位置（从下往上）
    // 主按钮高度 + (index + 1) * 间距 + index * 展开按钮高度
    final offset = widget.buttonSize +
        ((index + 1) * widget.spacing) +
        (index * widget.expandedButtonSize);

    return Transform.translate(
      offset: Offset(0, -offset),
      child: ScaleTransition(
        scale: _expandAnimation,
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: widget.expandedButtonSize,
          height: widget.expandedButtonSize,
          child: FloatingActionButton(
            heroTag: 'fab_$index',
            onPressed: () {
              item.onPressed();
              _toggle(); // 点击后收起
            },
            elevation: 0, // 去掉阴影
            highlightElevation: 0, // 去掉点击高亮阴影
            backgroundColor: item.backgroundColor ?? Colors.white,
            child: Icon(
              item.icon,
              color: item.iconColor ?? Colors.black87,
              size: widget.expandedButtonSize * 0.4, // 图标大小为按钮的 40%
            ),
          ),
        ),
      ),
    );
  }
}

class FABItem {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? tooltip;

  FABItem({
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.tooltip,
  });
}
