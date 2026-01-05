import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:yanyiheyi/core/logger/app_logger.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_toast.dart';
import 'ai_cache_manager.dart';

/// AI 面板组件
class AIPanel extends StatefulWidget {
  final double height;
  final QuillController? controller;
  final VoidCallback? onExpand;
  final VoidCallback? onRefresh;
  final VoidCallback? onAdopt;

  const AIPanel({
    super.key,
    required this.height,
    this.controller,
    this.onExpand,
    this.onRefresh,
    this.onAdopt,
  });

  /// 清空 AI 缓存（公开静态方法供外部调用）
  static void clearCache() {
    _AIPanelState._cacheManager.clear();
  }

  @override
  State<AIPanel> createState() => _AIPanelState();
}

class _AIPanelState extends State<AIPanel> {
  // AI 缓存管理器（单例模式）
  static final AICacheManager _cacheManager = AICacheManager();

  String _originalText = '';
  String _aiSuggestion = '';
  bool _isLoading = false;
  bool _hasError = false;

  // 记录原始文本的位置信息
  int _startPos = 0;
  int _endPos = 0;
  bool _hasSelection = false; // 是否是从选区获取的文本

  @override
  void initState() {
    super.initState();
    _loadText();
  }

  @override
  void didUpdateWidget(AIPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 每次面板打开时重新加载文本
    if (widget.controller != oldWidget.controller) {
      _loadText();
    }
  }

  /// 加载文本
  void _loadText() {
    final controller = widget.controller;
    if (controller == null) {
      setState(() {
        _originalText = '';
        _aiSuggestion = '';
        _isLoading = false;
        _hasError = true;
        _startPos = 0;
        _endPos = 0;
        _hasSelection = false;
      });
      return;
    }

    // 获取选中的文本或光标所在句子
    final text = _getSelectedTextOrSentence(controller);

    if (text.isEmpty) {
      setState(() {
        _originalText = '';
        _aiSuggestion = '';
        _isLoading = false;
        _hasError = true;
        _startPos = 0;
        _endPos = 0;
        _hasSelection = false;
      });
      return;
    }

    setState(() {
      _originalText = text;
      _hasError = false;
    });

    // 检查缓存逻辑
    appLogger.info('=== 检查 AI 缓存 ===');
    appLogger.info('当前原文: "$text"');

    if (_cacheManager.hasCache(text)) {
      // 有缓存
      appLogger.info('发现缓存');

      if (_cacheManager.hasSuggestion(text)) {
        // 有 AI 建议，直接显示
        final cachedSuggestion = _cacheManager.getCachedSuggestion(text)!;
        appLogger.info('使用缓存的 AI 建议: "$cachedSuggestion"');
        setState(() {
          _aiSuggestion = cachedSuggestion;
          _isLoading = false;
        });
      } else {
        // 有缓存但无 AI 建议，生成新建议
        appLogger.info('缓存存在但无 AI 建议，开始生成');
        setState(() {
          _isLoading = true;
        });
        _generateAISuggestion();
      }
    } else {
      // 无缓存，创建并生成
      appLogger.info('无缓存，创建新缓存并生成 AI 建议');
      _cacheManager.updateOriginalText(text);
      setState(() {
        _isLoading = true;
      });
      _generateAISuggestion();
    }
  }

  /// 获取选中的文本或光标所在句子
  String _getSelectedTextOrSentence(QuillController controller) {
    final selection = controller.selection;
    final plainText = controller.document.toPlainText();

    // 1. 如果有选中文本，直接返回
    if (!selection.isCollapsed && selection.baseOffset >= 0 && selection.extentOffset >= 0) {
      // 确保索引在有效范围内
      if (selection.start >= 0 && selection.end <= plainText.length && selection.start < selection.end) {
        final selectedText = plainText.substring(selection.start, selection.end);
        if (selectedText.trim().isNotEmpty) {
          // 记录选区位置
          _startPos = selection.start;
          _endPos = selection.end;
          _hasSelection = true;
          return selectedText.trim();
        }
      }
    }

    // 2. 没有选中文本，获取光标所在句子
    if (plainText.trim().isEmpty) {
      _startPos = 0;
      _endPos = 0;
      _hasSelection = false;
      return '';
    }

    final cursorOffset = selection.baseOffset;

    // 确保光标位置在有效范围内
    if (cursorOffset < 0 || cursorOffset > plainText.length) {
      _startPos = 0;
      _endPos = 0;
      _hasSelection = false;
      return '';
    }

    // 向前查找句子开始位置
    int start = cursorOffset;
    while (start > 0) {
      start--;
      if (start - 1 < 0) break; // 防止索引越界
      final char = plainText[start - 1];
      if (char == '。' || char == '？' || char == '！' || char == '\n') {
        break;
      }
    }

    // 向后查找句子结束位置
    int end = cursorOffset;
    while (end < plainText.length) {
      final char = plainText[end];
      if (char == '。' || char == '？' || char == '！' || char == '\n') {
        end++;
        break;
      }
      end++;
      // 防止无限循环
      if (end >= plainText.length) {
        end = plainText.length;
        break;
      }
    }

    // 确保索引有效
    if (start < 0) start = 0;
    if (end > plainText.length) end = plainText.length;
    if (start >= end) {
      // 如果 start >= end，说明光标在文本末尾或文本为空
      // 至少选择光标位置的字符
      if (cursorOffset < plainText.length) {
        end = cursorOffset + 1;
      } else {
        // 光标在末尾，选择整段文本
        start = 0;
        end = plainText.length;
      }
    }

    // 记录句子位置
    _startPos = start;
    _endPos = end;
    _hasSelection = false;

    final sentence = plainText.substring(start, end).trim();
    return sentence;
  }

  /// 生成 AI 建议（模拟流式输出）
  Future<void> _generateAISuggestion({bool forceRefresh = false}) async {
    if (_originalText.isEmpty) return;

    setState(() {
      _isLoading = true;
      _aiSuggestion = '';
    });

    // 模拟 AI 扩写建议
    final suggestions = [
      '$_originalText（这是 AI 的扩写建议，让内容更加丰富和详细。）',
      '$_originalText\n\n此外，我们还可以从另一个角度来思考这个问题。',
      '$_originalText\n\n这个观点非常有趣，值得我们深入探讨。',
      '$_originalText\n\n从实践角度来看，这一观点具有重要的指导意义。',
      '$_originalText\n\n可以说，这不仅仅是一个简单的问题，而是涉及到多个层面的思考。',
      '$_originalText\n\n通过进一步分析，我们可以发现更多有价值的细节。',
      '$_originalText\n\n在实际应用中，这种方法往往能取得意想不到的效果。',
      '$_originalText\n\n值得注意的是，这个观点背后蕴含着深刻的哲理。',
      '$_originalText\n\n结合具体案例来看，这一论断具有更强的说服力。',
      '$_originalText\n\n从长远发展来看，这种思路将会带来更多可能性。',
    ];

    final fullSuggestion = (suggestions..shuffle()).first;

    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 打字机效果：逐字输出
    await _streamText(fullSuggestion);

    // 生成完成后更新缓存
    if (forceRefresh) {
      // 强制刷新：更新缓存
      appLogger.info('强制刷新，更新缓存');
      _cacheManager.updateSuggestion(_originalText, fullSuggestion);
    } else {
      // 正常生成：更新缓存
      appLogger.info('AI 建议生成完成，更新缓存');
      _cacheManager.updateSuggestion(_originalText, fullSuggestion);
    }

    // 打印缓存统计
    appLogger.info('缓存统计: ${_cacheManager.getStats()}');
  }

  /// 流式输出文本（打字机效果）
  Future<void> _streamText(String fullText) async {
    final buffer = StringBuffer();
    int currentIndex = 0;

    while (currentIndex < fullText.length) {
      // 每次添加 1-3 个字符，模拟真实的打字速度变化
      final charsToAdd = 1 + (currentIndex % 3);
      final nextIndex = (currentIndex + charsToAdd).clamp(0, fullText.length);

      buffer.write(fullText.substring(currentIndex, nextIndex));

      setState(() {
        _aiSuggestion = buffer.toString();
      });

      currentIndex = nextIndex;

      // 模拟打字延迟（10-30ms 之间随机）
      final delay = 10 + (currentIndex % 3) * 10;
      await Future.delayed(Duration(milliseconds: delay));
    }

    // 输出完成
    setState(() {
      _isLoading = false;
    });
  }

  /// 刷新 AI 建议
  void _handleRefresh() {
    if (widget.onRefresh != null) {
      widget.onRefresh!();
    } else {
      // 强制刷新，忽略缓存
      appLogger.info('用户点击刷新按钮，强制生成新建议');
      _generateAISuggestion(forceRefresh: true);
    }
  }

  /// 采用 AI 建议
  void _handleAdopt() {
    if (_aiSuggestion.isEmpty) {
      AppToast.showError('没有可采用的 AI 建议');
      return;
    }

    final controller = widget.controller;
    if (controller == null) {
      AppToast.showError('编辑器未就绪');
      return;
    }

    try {
      // 使用之前记录的位置信息
      final plainText = controller.document.toPlainText();
      final textLength = plainText.length;
      final document = controller.document;
      final blockCount = document.length;

      // 详细日志
      appLogger.info('=== 采用 AI 建议 ===');
      appLogger.info('文本长度: $textLength');
      appLogger.info('文档块数量: $blockCount');
      appLogger.info('记录的位置: $_startPos -> $_endPos');
      appLogger.info('原始文本: "$_originalText"');
      appLogger.info('AI 建议: "$_aiSuggestion"');

      // 打印文档结构信息
      appLogger.info('=== 文档结构 ===');
      document.toPlainText().split('\n').asMap().forEach((i, line) {
        appLogger.info('行 $i: "$line"');
      });
      appLogger.info('文档 Delta: ${document.toDelta()}');

      // 确保记录的位置仍然有效
      if (_startPos < 0 || _endPos < 0 || _startPos > _endPos) {
        appLogger.error('位置关系错误: start=$_startPos, end=$_endPos');
        AppToast.showError('文本位置已改变，请重新选择');
        _loadText();
        return;
      }

      if (_startPos >= textLength || _endPos > textLength) {
        appLogger.error('位置超出范围: start=$_startPos, end=$_endPos, length=$textLength');
        AppToast.showError('文本位置已改变，请重新选择');
        _loadText();
        return;
      }

      // 计算要删除的长度
      final length = _endPos - _startPos;

      appLogger.info('删除长度: $length');

      // 确保删除的长度有效
      if (length <= 0) {
        appLogger.error('删除长度无效: $length');
        AppToast.showError('文本位置无效');
        return;
      }

      if (_startPos + length > textLength) {
        appLogger.error('删除范围超出: start=$_startPos, length=$length, total=$textLength');
        AppToast.showError('文本位置无效');
        return;
      }

      // 关键修复：确保不会删除换行符
      // 如果删除范围包含换行符，需要调整删除长度
      int adjustedLength = length;
      int checkPos = _startPos + length;

      // 检查删除范围的末尾是否是换行符
      if (checkPos <= textLength && checkPos > 0) {
        final charBeforeDelete = plainText[checkPos - 1];
        appLogger.info('删除范围前的字符: "$charBeforeDelete" (${charBeforeDelete.codeUnitAt(0)})');

        // 如果删除范围末尾的前一个字符是换行符，需要保留它
        if (charBeforeDelete == '\n' || charBeforeDelete == '\r') {
          appLogger.info('检测到换行符，调整删除长度');
          adjustedLength = length - 1;
        }
      }

      // 同样检查删除范围的开始位置
      if (_startPos > 0) {
        final charAtStart = plainText[_startPos];
        if (charAtStart == '\n' || charAtStart == '\r') {
          appLogger.info('删除范围开始位置是换行符，调整位置');
          // 不应该从换行符开始删除，跳过它
          final actualStart = _startPos + 1;
          final actualLength = adjustedLength - 1;
          if (actualLength > 0) {
            appLogger.info('执行替换: position=$actualStart, length=$actualLength');
            controller.replaceText(actualStart, actualLength, _aiSuggestion, null);
          } else {
            // 如果调整后长度为0，直接插入
            appLogger.info('调整后长度为0，执行插入: position=$_startPos');
            controller.replaceText(_startPos, 0, _aiSuggestion, null);
          }
          if (widget.onAdopt != null) {
            widget.onAdopt!();
          }
          AppToast.showSuccess('已采用 AI 建议');
          return;
        }
      }

      // 使用记录的位置进行替换（使用调整后的长度）
      appLogger.info('执行替换: position=$_startPos, length=$adjustedLength');
      controller.replaceText(_startPos, adjustedLength, _aiSuggestion, null);

      if (widget.onAdopt != null) {
        widget.onAdopt!();
      }

      AppToast.showSuccess('已采用 AI 建议');
    } catch (e) {
      AppToast.showError('采用失败');
      appLogger.error('采用异常: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取底部安全区高度
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return GestureDetector(
      // 消费点击事件，阻止冒泡到外层，避免面板被关闭
      behavior: HitTestBehavior.opaque,
      onTap: () {}, // 空回调，消费点击事件
      child: Container(
        height: widget.height,
        color: Colors.white,
        child: Column(
          children: [
            // 中部左右布局
            Expanded(
              child: _buildContent(),
            ),

            // 底部功能按钮
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: bottomPadding > 0 ? bottomPadding : 16,
                top: 8, // 与内容区隔开
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 左侧：扩写按钮
                  AIActionButton(
                    icon: Icons.psychology,
                    label: '扩写',
                    onTap: widget.onExpand ?? () => _generateAISuggestion(),
                  ),

                  // 右侧：刷新和采用按钮组
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AIActionButton(
                        icon: Icons.refresh,
                        label: '刷新',
                        onTap: _handleRefresh,
                      ),
                      const SizedBox(width: 12),
                      AIActionButton(
                        icon: Icons.check_circle,
                        label: '采用',
                        onTap: _handleAdopt,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContent() {
    if (_hasError || _originalText.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '请先选中文本或开始编辑\n编辑后 AI 将自动提供建议',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        // 左侧：原始文本
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                right: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.short_text, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      '原文',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: IgnorePointer(
                    child: SingleChildScrollView(
                      child: Text(
                        _originalText,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 右侧：AI 建议
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(
                left: BorderSide(color: Colors.blue[200]!, width: 2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFFF6B6B),
                          Color(0xFFFFA06B),
                          Color(0xFFFFD93D),
                          Color(0xFF6BCF7F),
                          Color(0xFF4D9DE0),
                          Color(0xFF9B72FF),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'AI 建议',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: IgnorePointer(
                    child: _isLoading
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(strokeWidth: 2),
                                SizedBox(height: 12),
                                Text(
                                  'AI 正在思考...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            child: Text(
                              _aiSuggestion,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 带呼吸动画的图标组件
class _BreathingIcon extends StatefulWidget {
  final IconData icon;
  final double size;

  const _BreathingIcon({
    required this.icon,
    this.size = 16,
  });

  @override
  State<_BreathingIcon> createState() => _BreathingIconState();
}

class _BreathingIconState extends State<_BreathingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 缩放动画：从 1.0 到 1.2 再到 1.0
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // 透明度动画：从 1.0 到 0.6 再到 1.0
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.6,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // 循环播放动画
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [
            Color(0xFFFF6B6B), // 红色
            Color(0xFFFFA06B), // 橙色
            Color(0xFFFFD93D), // 黄色
            Color(0xFF6BCF7F), // 绿色
            Color(0xFF4D9DE0), // 蓝色
            Color(0xFF9B72FF), // 紫色
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: Icon(
          widget.icon,
          size: widget.size,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// AI 功能按钮组件（用于工具栏）
class AIFeatureButton extends StatefulWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final QuillController? controller;

  const AIFeatureButton({
    super.key,
    required this.isSelected,
    required this.onTap,
    this.controller,
  });

  @override
  State<AIFeatureButton> createState() => _AIFeatureButtonState();
}

class _AIFeatureButtonState extends State<AIFeatureButton>
    with WidgetsBindingObserver {
  // 显示的建议文字
  String _suggestionText = '让AI来帮你';

  // 停顿检测定时器
  Timer? _typingTimer;

  // 上次生成完成的时间戳
  DateTime? _lastGenerationTime;

  // 当前生成任务的 Future，用于取消
  Future<void>? _currentGenerationFuture;

  // 防抖定时器
  Timer? _debounceTimer;

  // 是否正在生成
  bool _isGenerating = false;

  // 生命周期监听器
  AppLifecycleListener? _lifecycleListener;

  // 记录上次的文档内容，用于检测是否真正变化
  String _lastDocumentContent = '';

  // 记录上次的光标位置，用于检测光标移动
  int _lastCursorPosition = -1;

  // 标记在生成过程中是否有新的输入
  bool _hasNewInputDuringGeneration = false;

  // 常量配置
  static const Duration _typingPauseDuration = Duration(seconds: 5); // 停顿检测时长
  static const Duration _cooldownDuration = Duration(seconds: 10); // 冷却时长
  static const Duration _debounceDuration = Duration(milliseconds: 300); // 防抖时长

  @override
  void initState() {
    super.initState();

    appLogger.info('AIFeatureButton: initState, controller = ${widget.controller != null}');

    // 监听应用生命周期变化
    _lifecycleListener = AppLifecycleListener(
      onStateChange: _onAppStateChanged,
    );

    // 监听编辑器变化
    if (widget.controller != null) {
      // 初始化记录当前文档内容
      _lastDocumentContent = widget.controller!.document.toPlainText();

      // 初始化记录当前光标位置
      _lastCursorPosition = widget.controller!.selection.baseOffset;

      widget.controller!.addListener(_onDocumentChanged);
      appLogger.info('AIFeatureButton: 已监听 QuillController');
      appLogger.info('AIFeatureButton: 初始文档长度 = ${_lastDocumentContent.length}');
      appLogger.info('AIFeatureButton: 初始光标位置 = $_lastCursorPosition');

      // 启动初始停顿检测（无论文档是否为空）
      _startInitialTypingTimer();
    } else {
      appLogger.warning('AIFeatureButton: controller 为 null，无法监听文档变化');
    }
  }

  @override
  void didUpdateWidget(AIFeatureButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果 controller 发生变化，重新监听
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onDocumentChanged);
      widget.controller?.addListener(_onDocumentChanged);
    }
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    _debounceTimer?.cancel();
    _typingTimer?.cancel();
    widget.controller?.removeListener(_onDocumentChanged);
    _cancelGeneration();
    super.dispose();
  }

  /// 应用生命周期状态变化监听器
  void _onAppStateChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // 取消生成任务
        _cancelGeneration();
        // 清空临时文字，重置为默认文字
        if (mounted) {
          setState(() {
            _suggestionText = '让AI来帮你';
            _isGenerating = false;
          });
        }
        // 取消所有定时器
        _typingTimer?.cancel();
        _debounceTimer?.cancel();
        break;
      case AppLifecycleState.resumed:
      case AppLifecycleState.hidden:
        // 无需特殊处理
        break;
    }
  }

  /// 监听文档变化（带防抖）
  void _onDocumentChanged() {
    final currentContent = widget.controller?.document.toPlainText() ?? '';
    final currentCursorPosition = widget.controller?.selection.baseOffset ?? -1;

    // 检测是否有变化（内容变化 或 光标移动）
    final contentChanged = currentContent != _lastDocumentContent;
    final cursorMoved = currentCursorPosition != _lastCursorPosition;

    if (contentChanged || cursorMoved) {
      if (contentChanged) {
        appLogger.info('AIFeatureButton: 文档内容已变化，长度从 ${_lastDocumentContent.length} 变为 ${currentContent.length}');
        _lastDocumentContent = currentContent;
      }

      if (cursorMoved) {
        appLogger.info('AIFeatureButton: 光标位置已移动，从 $_lastCursorPosition 移动到 $currentCursorPosition');
        _lastCursorPosition = currentCursorPosition;
      }

      // 取消之前的防抖定时器
      _debounceTimer?.cancel();

      // 如果正在生成，标记有新输入，但继续生成
      // 冷却时间以生成完成的时间为准
      if (_isGenerating) {
        appLogger.info('AIFeatureButton: 正在生成中，标记有新输入');
        _hasNewInputDuringGeneration = true;
        return;
      }

      // 启动新的防抖定时器
      _debounceTimer = Timer(_debounceDuration, () {
        _restartTypingTimer();
      });
    }
  }

  /// 重启停顿检测定时器
  void _restartTypingTimer() {
    // 取消之前的定时器
    _typingTimer?.cancel();

    // 启动新的定时器
    _typingTimer = Timer(_typingPauseDuration, () {
      _onUserPaused();
    });
  }

  /// 启动初始停顿检测定时器
  void _startInitialTypingTimer() {
    // 清理旧定时器
    _debounceTimer?.cancel();
    _typingTimer?.cancel();

    appLogger.info('AIFeatureButton: 启动初始停顿检测定时器（10秒）');

    // 直接启动10秒停顿检测（不需要防抖）
    _typingTimer = Timer(_typingPauseDuration, () {
      appLogger.info('AIFeatureButton: 初始停顿检测触发');
      _onUserPaused();
    });
  }

  /// 用户停顿后的处理
  void _onUserPaused() {
    // 检查冷却时间
    if (_lastGenerationTime != null) {
      final timeSinceLastGeneration = DateTime.now().difference(_lastGenerationTime!);
      if (timeSinceLastGeneration < _cooldownDuration) {
        final remainingSeconds = _cooldownDuration.inSeconds - timeSinceLastGeneration.inSeconds;
        appLogger.info('距离上次生成不足${_cooldownDuration.inSeconds}秒，还需等待 $remainingSeconds 秒，跳过本次生成');

        // 关键修复：即使跳过本次生成，也要重新启动停顿检测
        // 这样冷却时间过后，用户停顿5秒后就能再次触发
        appLogger.info('AIFeatureButton: 冷却中，重新启动停顿检测');
        _typingTimer = Timer(Duration(milliseconds: 500), () {
          _onUserPaused();
        });

        return;
      }
    }

    // 开始生成建议
    _generateSuggestion();
  }

  /// 取消当前生成任务
  void _cancelGeneration() {
    _currentGenerationFuture = null;
    _isGenerating = false;
  }

  /// 生成 AI 建议
  Future<void> _generateSuggestion() async {
    if (_isGenerating) return;

    final controller = widget.controller;
    if (controller == null) return;

    setState(() {
      _isGenerating = true;
      _hasNewInputDuringGeneration = false; // 重置标记
      _suggestionText = '';
    });

    try {
      // 获取生成内容
      final suggestion = await _generateAISuggestionContent(controller);

      // 流式显示
      await _streamText(suggestion);

      // 记录生成完成时间
      _lastGenerationTime = DateTime.now();

      setState(() {
        _isGenerating = false;
      });

      // 检查生成过程中是否有新输入
      if (_hasNewInputDuringGeneration) {
        appLogger.info('AIFeatureButton: 生成过程中检测到新输入，重新启动停顿检测');
        _hasNewInputDuringGeneration = false;
        // 重新启动停顿检测定时器
        _debounceTimer?.cancel();
        _debounceTimer = Timer(_debounceDuration, () {
          _restartTypingTimer();
        });
      }
    } catch (e) {
      appLogger.error('生成建议失败: $e');
      setState(() {
        _suggestionText = '让AI来帮你';
        _isGenerating = false;
        _hasNewInputDuringGeneration = false;
      });
    }
  }

  /// 生成 AI 建议内容（预留接口）
  Future<String> _generateAISuggestionContent(QuillController controller) async {
    // TODO: 接入真实 AI API
    // 这里使用模拟生成，后续可以替换为真实 API 调用

    final plainText = controller.document.toPlainText();
    final selection = controller.selection;

    // 场景1：光标处有选中文本
    if (!selection.isCollapsed &&
        selection.baseOffset >= 0 &&
        selection.extentOffset >= 0 &&
        selection.start < selection.end &&
        selection.end <= plainText.length) {
      final selectedText = plainText.substring(selection.start, selection.end);
      return _generateForSelectedText(selectedText);
    }

    // 场景2：光标处无内容，但文章有内容
    if (plainText.trim().isNotEmpty && selection.baseOffset >= 0) {
      final cursorPos = selection.baseOffset;
      final context = _getContextAroundPosition(plainText, cursorPos);
      return _generateForContext(context);
    }

    // 场景3：文章完全为空
    return _generateForEmptyDocument();
  }

  /// 场景1：针对选中文本生成建议
  Future<String> _generateForSelectedText(String selectedText) async {
    // TODO: 接入真实 AI API，将 selectedText 发送给 AI
    final suggestions = [
      '这段表述可以更精炼',
      '建议增加具体数据支撑',
      '这里用词可以更准确',
      '逻辑可以更清晰',
      '可以增加举例说明',
    ];
    suggestions.shuffle();
    return suggestions.first;
  }

  /// 场景2：针对上下文生成建议
  Future<String> _generateForContext(String context) async {
    // TODO: 接入真实 AI API，将 context 发送给 AI
    final suggestions = [
      '此处可以展开论述',
      '建议补充相关背景',
      '可以增加过渡句',
      '这个观点很有深度',
      '建议进一步阐述',
    ];
    suggestions.shuffle();
    return suggestions.first;
  }

  /// 场景3：空文档生成建议
  Future<String> _generateForEmptyDocument() async {
    // TODO: 接入真实 AI API
    final suggestions = [
      '开始写作吧',
      '记录你的想法',
      '写下第一句话',
      '创意从这里开始',
    ];
    suggestions.shuffle();
    return suggestions.first;
  }

  /// 获取光标周围的上下文
  String _getContextAroundPosition(String text, int cursorPos) {
    const contextLength = 100; // 上下文长度
    int start = (cursorPos - contextLength).clamp(0, text.length);
    int end = (cursorPos + contextLength).clamp(0, text.length);
    return text.substring(start, end);
  }

  /// 流式显示文本（打字机效果）
  Future<void> _streamText(String fullText) async {
    final buffer = StringBuffer();
    int currentIndex = 0;

    while (currentIndex < fullText.length && _isGenerating) {
      final charsToAdd = 1 + (currentIndex % 2);
      final nextIndex = (currentIndex + charsToAdd).clamp(0, fullText.length);

      buffer.write(fullText.substring(currentIndex, nextIndex));

      if (mounted) {
        setState(() {
          _suggestionText = buffer.toString();
        });
      }

      currentIndex = nextIndex;
      await Future.delayed(const Duration(milliseconds: 30));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 28,
        margin: const EdgeInsets.only(left: 12, right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.isSelected ? AppColors.primary : Colors.grey[300]!,
            width: widget.isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 使用带呼吸动画的图标
            const _BreathingIcon(
              icon: Icons.auto_awesome,
              size: 16,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _suggestionText.isEmpty
                    ? 'AI 正在思考...'
                    : _suggestionText,
                style: TextStyle(
                  fontSize: 13,
                  color: widget.isSelected ? AppColors.primary : Colors.grey[700],
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// AI 操作按钮
class AIActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const AIActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 60,
        ),
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
