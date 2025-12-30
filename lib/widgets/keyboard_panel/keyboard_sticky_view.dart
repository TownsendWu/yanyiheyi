import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// 1. 核心封装组件: KeyboardStickyView
// ---------------------------------------------------------------------------
class KeyboardStickyView extends StatelessWidget {
  /// 主体内容（通常是列表或页面的中间部分）
  final Widget body;

  /// 键盘上方的自定义组件（输入框、按钮组等）
  final Widget bottomContent;

  /// 可选：标题
  final String? title;

  /// 背景颜色
  final Color backgroundColor;

  const KeyboardStickyView({
    Key? key,
    required this.body,
    required this.bottomContent,
    this.title,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 关键属性：当键盘弹出时，重新调整布局大小，使底部内容被顶上去
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[100], // 页面背景色
      appBar: title != null ? AppBar(title: Text(title!)) : null,
      body: GestureDetector(
        // 关键属性：点击空白处收起键盘
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // 收起键盘的核心代码
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            // 1. 页面主体内容（占据剩余空间）
            Expanded(
              child: body,
            ),

            // 2. 底部吸附组件 (键盘上方的内容)
            Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                // 顶部加个阴影，更有层次感
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: SafeArea(
                // SafeArea 保证在 iOS 底部横条区域之上
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 高度包裹内容
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 可选标题区域 ---
                    if (title != null && title!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(
                          title!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),

                    if (title != null && title!.isNotEmpty)
                      const Divider(height: 1),

                    // --- 实际的自定义内容 (输入框/按钮) ---
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: bottomContent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. 使用示例: DemoPage（带自动聚焦和优化）
// ---------------------------------------------------------------------------
class DemoPage extends StatefulWidget {
  const DemoPage({Key? key}) : super(key: key);

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showInput = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 显示输入框并自动聚焦
  void _showInputAndFocus() {
    setState(() {
      _showInput = true;
    });
    // 延迟聚焦，确保UI已经更新
    Future.microtask(() {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardStickyView(
      // 顶部可选标题（如果不需要可不传，或者在 bottomContent 里自定义）
      title: "评论页面",

      // 页面主体：这里放一个列表作为示例
      body: ListView.builder(
        itemCount: 20,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: _showInputAndFocus,
              child: Text("这是一条模拟的聊天或内容记录 #$index\n点击显示输入框"),
            ),
          );
        },
      ),

      // 底部内容：这就是你要的"键盘上方的组件"
      bottomContent: _showInput
          ? Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: "请输入内容...",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      // 设为 true，当TextField有多行时也会自适应
                      isDense: true,
                    ),
                    // 允许输入多行
                    maxLines: null,
                    // 文本提交时收起键盘
                    onSubmitted: (value) {
                      print("发送: $value");
                      _controller.clear();
                      setState(() {
                        _showInput = false;
                      });
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // 按钮组示例
                IconButton(
                  onPressed: () {
                    print("发送: ${_controller.text}");
                    _controller.clear();
                    setState(() {
                      _showInput = false;
                    });
                    FocusScope.of(context).unfocus();
                  },
                  icon: const Icon(Icons.send, color: Colors.blue),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}
