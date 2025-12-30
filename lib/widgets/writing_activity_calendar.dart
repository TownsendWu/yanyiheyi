import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/activity_data.dart';

/// 日历主题配置
class ActivityTheme {
  final List<Color> lightColors;
  final List<Color> darkColors;

  const ActivityTheme({
    required this.lightColors,
    required this.darkColors,
  });
}

/// 默认主题
const defaultTheme = ActivityTheme(
  lightColors: [
    Color(0xFFEEEEEE), // hsl(0, 0%, 94%)
    Color(0xFF53C68C), // 主绿色
  ],
  darkColors: [
    Color(0xFF2D333B), // hsl(220, 15%, 20%)
    Color(0xFF53C68C), // 主绿色
  ],
);

/// 写作活动日历组件
class WritingActivityCalendar extends StatefulWidget {
  final List<ActivityData> data;
  final ActivityTheme? theme;
  final String? totalCountLabel;

  const WritingActivityCalendar({
    super.key,
    required this.data,
    this.theme,
    this.totalCountLabel,
  });

  @override
  State<WritingActivityCalendar> createState() =>
      _WritingActivityCalendarState();
}

class _WritingActivityCalendarState extends State<WritingActivityCalendar> {
  final Map<String, ActivityData> _activityMap = {};

  @override
  void initState() {
    super.initState();
    for (final item in widget.data) {
      _activityMap[item.date] = item;
    }
  }

  @override
  void didUpdateWidget(WritingActivityCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _activityMap.clear();
      for (final item in widget.data) {
        _activityMap[item.date] = item;
      }
    }
  }

  ActivityData _getActivityForDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return _activityMap[dateStr] ??
        ActivityData(date: dateStr, count: 0, level: 0);
  }

  int _getTotalCount() {
    return widget.data.fold(0, (sum, item) => sum + item.count);
  }

  @override
  Widget build(BuildContext context) {
    // Cache theme access for performance
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 显示总数
        Padding(
          padding: const EdgeInsets.only(bottom: 1.0),
          child: Text(
            widget.totalCountLabel ??
                '${DateTime.now().year} 总共创作了 $_getTotalCount() 篇文章',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),

        // 日历网格
        _ActivityGrid(
          getActivityForDate: _getActivityForDate,
          theme: widget.theme,
        ),

        const SizedBox(height: 1),

        // 图例
        _Legend(theme: widget.theme),
      ],
    );
  }
}

/// 日历网格组件
class _ActivityGrid extends StatelessWidget {
  final ActivityData Function(DateTime date) getActivityForDate;
  final ActivityTheme? theme;

  const _ActivityGrid({
    required this.getActivityForDate,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);
    final weeks = _getWeeksInYear(startOfYear, endOfYear);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 星期标签（在左侧，带顶部间距以对齐月份标签）
            Padding(
              padding: const EdgeInsets.only(top: 16.0), // 月份标签高度(12) + 间距(4)
              child: _buildDayLabels(),
            ),
            const SizedBox(width: 4),
            // 月份标签和日期网格
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 月份标签行（水平滚动）
                _buildMonthLabels(weeks),
                const SizedBox(height: 4),
                // 日期网格（水平方向）
                _buildDateGrid(weeks),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthLabels(List<DateTime> weeks) {
    // 中文月份名称
    const monthNames = ['', '一', '二', '三', '四', '五', '六', '七', '八', '九', '十', '十一', '十二'];

    // 每周的宽度 = 方块宽度(10) + 左右padding(2) = 12px
    const weekWidth = 12.0;

    // 使用 Stack 来允许月份标签跨越多个列
    return SizedBox(
      width: weeks.length * weekWidth, // 设置明确的宽度
      height: 12,
      child: Stack(
        children: [
          for (var i = 0; i < weeks.length; i++)
            if (weeks[i].day <= 7)
              Positioned(
                left: i * weekWidth,
                child: Padding(
                  padding: const EdgeInsets.only(left: 2.0),
                  child: Text(
                    monthNames[weeks[i].month],
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildDayLabels() {
    // 中文星期标签（周一到周日，每隔一天显示）
    const dayLabels = ['周一', '', '周三', '', '周五', '', ''];

    return Column(
      children: List.generate(7, (index) {
        final label = dayLabels[index];
        return SizedBox(
          height: 12,
          child: label.isNotEmpty
              ? Text(
                  label,
                  style: const TextStyle(fontSize: 9),
                )
              : null,
        );
      }),
    );
  }

  Widget _buildDateGrid(List<DateTime> weeks) {
    return Row(
      children: weeks.map((weekStart) {
        return Column(
          children: List.generate(7, (dayIndex) {
            final date = weekStart.add(Duration(days: dayIndex));
            final activity = getActivityForDate(date);

            return Padding(
              padding: const EdgeInsets.all(1.0),
              child: _ActivitySquare(
                date: date,
                count: activity.count,
                level: activity.level,
                theme: theme,
              ),
            );
          }),
        );
      }).toList(),
    );
  }

  List<DateTime> _getWeeksInYear(DateTime start, DateTime end) {
    final weeks = <DateTime>[];
    var current = start;

    // 调整到第一个周一
    while (current.weekday != 1) {
      current = current.subtract(const Duration(days: 1));
    }

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      weeks.add(current);
      current = current.add(const Duration(days: 7));
    }

    return weeks;
  }
}

/// 活动方块组件
class _ActivitySquare extends StatelessWidget {
  final DateTime date;
  final int count;
  final int level;
  final ActivityTheme? theme;

  const _ActivitySquare({
    required this.date,
    required this.count,
    required this.level,
    this.theme,
  });

  Color _getActivityColor(BuildContext context, int count) {
    final effectiveTheme = theme ?? defaultTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? effectiveTheme.darkColors : effectiveTheme.lightColors;

    // 根据每天的文章数量返回对应等级的颜色
    // 0篇 = 灰色背景 (level 0)
    // 1篇 = 1级颜色 (30%透明度)
    // 2篇 = 2级颜色 (50%透明度)
    // 3篇 = 3级颜色 (70%透明度)
    // 4篇及以上 = 4级颜色 (100%不透明)
    if (count == 0) return colors[0];
    if (count == 1) return colors[1].withValues(alpha: 0.3);
    if (count == 2) return colors[1].withValues(alpha: 0.5);
    if (count == 3) return colors[1].withValues(alpha: 0.7);
    return colors[1]; // 4篇及以上
  }

  @override
  Widget build(BuildContext context) {
    final color = _getActivityColor(context, count);

    return GestureDetector(
      onTap: () {
        _showTooltip(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeInOut,
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  void _showTooltip(BuildContext context) {
    if (level == 0) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: double.maxFinite,
          child: Text(
            '${DateFormat('yyyy-MM-dd').format(date)} 文章数：$count',
            style: const TextStyle(fontFamily: 'monospace'),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// 图例组件
class _Legend extends StatelessWidget {
  final ActivityTheme? theme;

  const _Legend({this.theme});

  Color _getActivityColor(BuildContext context, int count) {
    final effectiveTheme = theme ?? defaultTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? effectiveTheme.darkColors : effectiveTheme.lightColors;

    // 根据每天的文章数量返回对应等级的颜色
    // 0篇 = 灰色背景 (level 0)
    // 1篇 = 1级颜色 (30%透明度)
    // 2篇 = 2级颜色 (50%透明度)
    // 3篇 = 3级颜色 (70%透明度)
    // 4篇及以上 = 4级颜色 (100%不透明)
    if (count == 0) return colors[0];
    if (count == 1) return colors[1].withValues(alpha: 0.3);
    if (count == 2) return colors[1].withValues(alpha: 0.5);
    if (count == 3) return colors[1].withValues(alpha: 0.7);
    return colors[1]; // 4篇及以上
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '较少',
          style: TextStyle(fontSize: 12),
        ),
        const SizedBox(width: 4),
        ...List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getActivityColor(context, index),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
        const SizedBox(width: 4),
        const Text(
          '较多',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
