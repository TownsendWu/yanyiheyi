import 'package:flutter/material.dart';
import 'keyboard_panel.dart';

/// KeyboardPanel 使用示例
///
/// 展示如何在不同场景下使用 KeyboardPanel 组件（手动控制模式）
class KeyboardPanelExample extends StatefulWidget {
  const KeyboardPanelExample({super.key});

  @override
  State<KeyboardPanelExample> createState() => _KeyboardPanelExampleState();
}

class _KeyboardPanelExampleState extends State<KeyboardPanelExample> {
  final TextEditingController _textController = TextEditingController();
  final KeyboardPanelController _panelController = KeyboardPanelController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('键盘面板示例'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '点击"开始输入"按钮，面板会显示',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      // 点击按钮显示面板
                      _panelController.show();
                    },
                    child: const Text('开始输入'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '普通输入框',
                      hintText: '这个输入框不会触发面板',
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 键盘上方面板 - 使用 controller 控制
          KeyboardPanel(
            controller: _panelController,
            title: '快捷操作',
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '面板内的输入框',
                    hintText: '在这里输入...',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: 处理图片按钮点击
                        },
                        icon: const Icon(Icons.image),
                        label: const Text('图片'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: 处理文件按钮点击
                        },
                        icon: const Icon(Icons.attach_file),
                        label: const Text('文件'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () {
                    // 点击完成按钮隐藏面板
                    _panelController.hide();
                    FocusScope.of(context).unfocus();
                  },
                  child: const Text('完成'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 示例2: 不带标题的键盘面板
class KeyboardPanelExample2 extends StatefulWidget {
  const KeyboardPanelExample2({super.key});

  @override
  State<KeyboardPanelExample2> createState() => _KeyboardPanelExample2State();
}

class _KeyboardPanelExample2State extends State<KeyboardPanelExample2> {
  final KeyboardPanelController _panelController = KeyboardPanelController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('无标题示例'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: IconButton(
                iconSize: 48,
                onPressed: () {
                  _panelController.show();
                },
                icon: const Icon(Icons.edit),
              ),
            ),
          ),
          // 不带标题的面板
          KeyboardPanel(
            controller: _panelController,
            showDivider: false,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.sentiment_satisfied),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.sentiment_dissatisfied),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    _panelController.hide();
                  },
                  child: const Text('发送'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 示例3: 自定义样式的键盘面板
class KeyboardPanelExample3 extends StatefulWidget {
  const KeyboardPanelExample3({super.key});

  @override
  State<KeyboardPanelExample3> createState() => _KeyboardPanelExample3State();
}

class _KeyboardPanelExample3State extends State<KeyboardPanelExample3> {
  final KeyboardPanelController _panelController = KeyboardPanelController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义样式示例'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  _panelController.toggle(); // 切换显示状态
                },
                child: const Text('切换面板'),
              ),
            ),
          ),
          // 自定义样式的面板
          KeyboardPanel(
            controller: _panelController,
            title: '自定义样式',
            backgroundColor: theme.colorScheme.primaryContainer,
            titleStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline),
                    const SizedBox(width: 8),
                    Text(
                      '提示：这里是自定义样式的面板',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    _panelController.hide();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: const Text('关闭面板'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
