import 'package:chat_bottom_container/chat_bottom_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '写作编辑器',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const EditorPage(),
    );
  }
}

// 自定义面板类型
enum PanelType {
  none,
  keyboard,
  formatting,     // 文字格式化
  more,          // 更多选项
  emoji,         // 表情面板
}

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late final QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ChatBottomPanelContainerController<PanelType> _panelController =
      ChatBottomPanelContainerController<PanelType>();

  PanelType _currentPanelType = PanelType.none;
  double _keyboardHeight = 300; // 默认键盘高度
  bool _isKeyboardVisible = false; // 键盘是否可见

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 监听焦点变化
  void _onFocusChange() {
    if (_focusNode.hasFocus && !_isKeyboardVisible) {
      // TextField 获得焦点，延迟显示工具栏，等待键盘动画完成
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _focusNode.hasFocus) {
          setState(() {
            _isKeyboardVisible = true;
          });
        }
      });
    } else if (!_focusNode.hasFocus && _currentPanelType == PanelType.none) {
      // TextField 失去焦点且没有面板，立即隐藏工具栏
      setState(() {
        _isKeyboardVisible = false;
      });
    }
  }

  // 切换面板
  void _switchPanel(PanelType type) {
    if (_currentPanelType == type) {
      // 如果点击的是当前面板，则唤起键盘
      setState(() {
        _currentPanelType = PanelType.keyboard;
      });
      _controller.readOnly = false;
      _panelController.updatePanelType(ChatBottomPanelType.keyboard);
    } else {
      // 切换到新面板
      if (type == PanelType.keyboard) {
        setState(() {
          _currentPanelType = type;
          _isKeyboardVisible = true;
        });
        _controller.readOnly = false;
        _panelController.updatePanelType(ChatBottomPanelType.keyboard);
      } else {
        // 切换到自定义面板，设置只读并强制请求焦点
        setState(() {
          _currentPanelType = type;
          _isKeyboardVisible = true;
        });
        _controller.readOnly = true;

        // 等待下一帧，确保状态更新完成
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _panelController.updatePanelType(
              ChatBottomPanelType.other,
              data: type,
              forceHandleFocus: ChatBottomHandleFocus.requestFocus,
            );
          }
        });
      }
    }
  }

  // 隐藏面板
  void _hidePanel() {
    setState(() {
      _currentPanelType = PanelType.none;
      _isKeyboardVisible = false;
    });
    _controller.readOnly = false;
    _focusNode.unfocus();
    _panelController.updatePanelType(ChatBottomPanelType.none);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        // 点击空白区域收起键盘和面板
        onTap: () {
          if (_currentPanelType != PanelType.none || _focusNode.hasFocus) {
            _hidePanel();
          }
        },
        child: Column(
          children: [
            // 主内容区域
            Expanded(
              child: CustomScrollView(
                slivers: [
                  const SliverAppBar(
                    title: Text('写作编辑器'),
                    floating: true,
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverFillRemaining(
                      child: GestureDetector(
                        onTap: () {
                          // 面板状态下点击编辑区，唤起键盘
                          if (_controller.readOnly && _currentPanelType != PanelType.none) {
                            setState(() {
                              _currentPanelType = PanelType.keyboard;
                            });
                            _controller.readOnly = false;
                            _panelController.updatePanelType(ChatBottomPanelType.keyboard);
                          }
                        },
                        child: QuillEditor(
                          controller: _controller,
                          focusNode: _focusNode,
                          scrollController: _scrollController,
                          config: QuillEditorConfig(
                            placeholder: '开始写作...',
                            padding: EdgeInsets.zero,
                            expands: true,
                            customStyles: DefaultStyles(
                              paragraph: DefaultTextBlockStyle(
                                const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                                const HorizontalSpacing(0, 0),
                                const VerticalSpacing(8, 0),
                                const VerticalSpacing(0, 0),
                                null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 工具栏 - 只在键盘可见或有面板时显示
            if (_isKeyboardVisible || _currentPanelType != PanelType.none)
              _buildToolbar(),

            // 底部面板容器
              _buildPanelContainer(),
          ],
        ),
      ),
    );
  }

  // 构建工具栏
  Widget _buildToolbar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          // 文字格式化按钮
          _ToolbarItem(
            icon: Icons.text_fields,
            isSelected: _currentPanelType == PanelType.formatting,
            onTap: () => _switchPanel(PanelType.formatting),
          ),

          // 表情按钮
          _ToolbarItem(
            icon: Icons.emoji_emotions_outlined,
            isSelected: _currentPanelType == PanelType.emoji,
            onTap: () => _switchPanel(PanelType.emoji),
          ),

          // 更多按钮
          _ToolbarItem(
            icon: Icons.more_horiz,
            isSelected: _currentPanelType == PanelType.more,
            onTap: () => _switchPanel(PanelType.more),
          ),

          const Spacer(),

          // 收起按钮
          if (_currentPanelType != PanelType.none)
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_down),
              iconSize: 20,
              padding: const EdgeInsets.all(8),
              onPressed: _hidePanel,
            ),
        ],
      ),
    );
  }

  // 构建底部面板容器
  Widget _buildPanelContainer() {
    return ChatBottomPanelContainer<PanelType>(
      controller: _panelController,
      inputFocusNode: _focusNode,
      otherPanelWidget: (type) {
        if (type == null) return const SizedBox.shrink();

        switch (type) {
          case PanelType.formatting:
            return _buildFormattingPanel();
          case PanelType.more:
            return _buildMorePanel();
          case PanelType.emoji:
            return _buildEmojiPanel();
          default:
            return const SizedBox.shrink();
        }
      },
      onPanelTypeChange: (panelType, data) {
        // 监听面板类型变化
        switch (panelType) {
          case ChatBottomPanelType.none:
            setState(() {
              _currentPanelType = PanelType.none;
              _isKeyboardVisible = false;
            });
            _controller.readOnly = false;
            break;
          case ChatBottomPanelType.keyboard:
            setState(() {
              _currentPanelType = PanelType.keyboard;
              _isKeyboardVisible = true;
            });
            _controller.readOnly = false;
            break;
          case ChatBottomPanelType.other:
            if (data != null) {
              setState(() {
                _currentPanelType = data;
                _isKeyboardVisible = true;
              });
              _controller.readOnly = true;
            }
            break;
        }
      },
      panelBgColor: Colors.white,
      // 记录键盘高度，用于自定义面板
      changeKeyboardPanelHeight: (keyboardHeight) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && keyboardHeight != _keyboardHeight) {
            setState(() {
              _keyboardHeight = keyboardHeight;
            });
          }
        });
        return keyboardHeight;
      },
    );
  }

  // 文字格式化面板
  Widget _buildFormattingPanel() {
    return Container(
      height: _keyboardHeight,
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _FormatButton(
            icon: Icons.format_bold,
            label: '粗体',
            onTap: () {
              _controller.formatSelection(Attribute.bold);
            },
          ),
          _FormatButton(
            icon: Icons.format_italic,
            label: '斜体',
            onTap: () {
              _controller.formatSelection(Attribute.italic);
            },
          ),
          _FormatButton(
            icon: Icons.format_underlined,
            label: '下划线',
            onTap: () {
              _controller.formatSelection(Attribute.underline);
            },
          ),
          _FormatButton(
            icon: Icons.format_strikethrough,
            label: '删除线',
            onTap: () {
              _controller.formatSelection(Attribute.strikeThrough);
            },
          ),
          _FormatButton(
            icon: Icons.title,
            label: '标题',
            onTap: () {
              _controller.formatSelection(Attribute.h1);
            },
          ),
          _FormatButton(
            icon: Icons.format_quote,
            label: '引用',
            onTap: () {
              _controller.formatSelection(Attribute.blockQuote);
            },
          ),
          _FormatButton(
            icon: Icons.code,
            label: '代码',
            onTap: () {
              _controller.formatSelection(Attribute.inlineCode);
            },
          ),
          _FormatButton(
            icon: Icons.link,
            label: '链接',
            onTap: () {
              // TODO: 实现链接插入功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('链接功能待实现')),
              );
            },
          ),
        ],
      ),
    );
  }

  // 更多选项面板
  Widget _buildMorePanel() {
    return Container(
      height: _keyboardHeight,
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _FormatButton(
            icon: Icons.image,
            label: '图片',
            onTap: () {
              // TODO: 实现图片插入功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('图片功能待实现')),
              );
            },
          ),
          _FormatButton(
            icon: Icons.folder_open,
            label: '文件',
            onTap: () {
              // TODO: 实现文件插入功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('文件功能待实现')),
              );
            },
          ),
          _FormatButton(
            icon: Icons.list,
            label: '列表',
            onTap: () {
              _controller.formatSelection(Attribute.ul);
            },
          ),
          _FormatButton(
            icon: Icons.format_list_numbered,
            label: '序号',
            onTap: () {
              _controller.formatSelection(Attribute.ol);
            },
          ),
          _FormatButton(
            icon: Icons.table_chart,
            label: '表格',
            onTap: () {
              // TODO: 实现表格插入功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('表格功能待实现')),
              );
            },
          ),
          _FormatButton(
            icon: Icons.check_box,
            label: '任务',
            onTap: () {
              _controller.formatSelection(Attribute.checked);
            },
          ),
          _FormatButton(
            icon: Icons.horizontal_rule,
            label: '分割线',
            onTap: () {
              _controller.document.insert(
                _controller.selection.baseOffset,
                '\n',
              );
            },
          ),
          _FormatButton(
            icon: Icons.settings_outlined,
            label: '设置',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('设置功能待实现')),
              );
            },
          ),
        ],
      ),
    );
  }

  // 表情面板
  Widget _buildEmojiPanel() {
    return Container(
      height: _keyboardHeight,
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        children: const [
          '😀', '😂', '😍', '🥰', '😎', '🤔', '😴', '🥺',
          '👍', '👎', '👏', '🙏', '💪', '🤝', '✌️', '🤟',
          '❤️', '💔', '💯', '✨', '🎉', '🎊', '🔥', '💡',
          '🌟', '⭐', '☀️', '🌙', '🌈', '🍀', '🌸', '🌺',
        ]
            .map((emoji) => GestureDetector(
                  onTap: () => _insertText(emoji),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  // 在光标位置插入文本
  void _insertText(String text) {
    final index = _controller.selection.baseOffset;
    if (index == -1) return;

    _controller.document.insert(index, text);
    _controller.updateSelection(
      TextSelection.collapsed(offset: index + text.length),
      ChangeSource.local,
    );
  }
}

// 工具栏按钮
class _ToolbarItem extends StatelessWidget {
  final IconData icon;
  final String? label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToolbarItem({
    required this.icon,
    this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey[700],
              size: 20,
            ),
            if (label != null) ...[
              const SizedBox(height: 2),
              Text(
                label!,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.blue : Colors.grey[700],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 格式化按钮
class _FormatButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FormatButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey[700]),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
