import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';

class ConfettiCelebration extends StatefulWidget {
  final Widget child;

  const ConfettiCelebration({
    super.key,
    required this.child,
  });

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration> {
  late ConfettiController _confettiController;
  final Random _random = Random();
  final List<String> _messages = [
    '继续加油!',
    '笔耕不辍!',
    '终有所成!',
    '再接再厉!',
    '未来可期!',
    '保持热情!',
    '天天向上!',
    '前程似锦!',
  ];

  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _log('ConfettiCelebration: initState 开始');

    try {
      _confettiController = ConfettiController(
        duration: const Duration(seconds: 2),
      );
      _log('ConfettiController 创建成功');
    } catch (e, stackTrace) {
      _log('创建 ConfettiController 失败: $e');
      _log('堆栈跟踪: $stackTrace');
    }

    _log('ConfettiCelebration: initState 完成');
  }

  @override
  void dispose() {
    _log('ConfettiCelebration: dispose 开始');

    try {
      _confettiController.dispose();
      _log('ConfettiController 销毁成功');
    } catch (e) {
      _log('销毁 ConfettiController 失败: $e');
    }

    super.dispose();
    _log('ConfettiCelebration: dispose 完成');
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[ConfettiCelebration] $message');
    }
  }

  void _triggerCelebration() {
    _log('触发庆祝动画');

    try {
      // 检查是否正在播放
      if (_isPlaying) {
        _log('动画正在播放中,跳过本次触发');
        return;
      }

      _isPlaying = true;
      _log('开始播放彩带动画');
      _confettiController.play();

      // 显示鼓励文字
      final messageIndex = _random.nextInt(_messages.length);
      final message = _messages[messageIndex];
      _log('选择消息: $message (索引: $messageIndex)');

      // 使用 WidgetsBinding.instance.addPostFrameCallback 确保在正确的时机显示
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          _log('组件已销毁,取消显示 SnackBar');
          _isPlaying = false;
          return;
        }

        try {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          scaffoldMessenger.clearSnackBars();
          _log('清除旧的 SnackBar');

          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              duration: const Duration(milliseconds: 1500),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 140,
                left: 20,
                right: 20,
              ),
            ),
          );
          _log('SnackBar 显示成功');
        } catch (e, stackTrace) {
          _log('显示 SnackBar 失败: $e');
          _log('堆栈跟踪: $stackTrace');
        }
      });

      // 2秒后重置播放状态
      Future.delayed(const Duration(seconds: 2), () {
        _isPlaying = false;
        _log('重置播放状态');
      });
    } catch (e, stackTrace) {
      _log('触发庆祝动画失败: $e');
      _log('堆栈跟踪: $stackTrace');
      _isPlaying = false;
    }
  }

  Path _createParticlePath(Size size) {
    final path = Path();
    final shapeType = _random.nextInt(3);

    try {
      if (shapeType == 0) {
        // 圆形
        path.addOval(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2,
        ));
      } else if (shapeType == 1) {
        // 方形
        path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      } else {
        // 三角形
        path.moveTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        path.close();
      }
    } catch (e) {
      _log('创建粒子路径失败: $e');
      // 返回简单的圆形作为后备
      path.addOval(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ));
    }

    return path;
  }

  @override
  Widget build(BuildContext context) {
    _log('build 方法调用');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            _log('GestureDetector 检测到点击');
            _triggerCelebration();
          },
          child: widget.child,
        ),
        Positioned.fill(
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: -pi / 4, // 向右上方爆炸
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.05,
            shouldLoop: false,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.orange,
              Colors.purple,
              Colors.pink,
              Colors.yellow,
              Colors.cyan,
            ],
            createParticlePath: _createParticlePath,
          ),
        ),
      ],
    );
  }
}
