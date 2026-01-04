import 'package:flutter/material.dart';

/// AI 面板组件
class AIPanel extends StatelessWidget {
  final double height;
  final VoidCallback? onContinue;
  final VoidCallback? onSummarize;
  final VoidCallback? onTranslate;
  final VoidCallback? onPolish;
  final VoidCallback? onExpand;
  final VoidCallback? onContract;

  const AIPanel({
    super.key,
    required this.height,
    this.onContinue,
    this.onSummarize,
    this.onTranslate,
    this.onPolish,
    this.onExpand,
    this.onContract,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 20,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 8),
              Text(
                'AI 写作助手',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 功能按钮网格
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                AIActionButton(
                  icon: Icons.edit_note,
                  label: '续写',
                  description: '继续书写内容',
                  onTap: onContinue ?? () => _showNotImplemented(context, '续写'),
                ),
                AIActionButton(
                  icon: Icons.summarize,
                  label: '总结',
                  description: '总结文章要点',
                  onTap: onSummarize ?? () => _showNotImplemented(context, '总结'),
                ),
                AIActionButton(
                  icon: Icons.translate,
                  label: '翻译',
                  description: '翻译选中文本',
                  onTap: onTranslate ?? () => _showNotImplemented(context, '翻译'),
                ),
                AIActionButton(
                  icon: Icons.psychology,
                  label: '润色',
                  description: '优化文字表达',
                  onTap: onPolish ?? () => _showNotImplemented(context, '润色'),
                ),
                AIActionButton(
                  icon: Icons.expand,
                  label: '扩写',
                  description: '丰富文章内容',
                  onTap: onExpand ?? () => _showNotImplemented(context, '扩写'),
                ),
                AIActionButton(
                  icon: Icons.compress,
                  label: '缩写',
                  description: '精简文章内容',
                  onTap: onContract ?? () => _showNotImplemented(context, '缩写'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotImplemented(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('AI $feature 功能待实现')),
    );
  }
}

/// AI 功能按钮组件（用于工具栏）
class AIFeatureButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const AIFeatureButton({
    super.key,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        margin: const EdgeInsets.only(left: 12, right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 16,
              color: isSelected ? Colors.blue[700] : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              '这里写"xxxx"表达会更清晰哦',
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.blue[700] : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
  final String description;
  final VoidCallback onTap;

  const AIActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.blue[700],
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
