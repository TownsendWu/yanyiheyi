import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import '../models/article.dart';
import '../models/activity_data.dart';
import '../../core/constants/app_constants.dart';
import '../../utils/level_calculator.dart';

/// Mock 数据生成服务
class MockDataService {
  MockDataService._();

  static List<Article>? _cachedArticles;

  /// 生成固定的活动数据
  static List<ActivityData> generateActivityData() {
    final now = DateTime.now();
    final data = <ActivityData>[];
    const random = AppConstants.mockDataSeed;

    // 先生成基础数据
    final tempData = <Map<String, int>>[];
    for (int i = 0; i < AppConstants.dataDays; i++) {
      if ((random + i * 4) % 10 < 7) {
        final baseCount = ((random + i) % 5);
        final count = baseCount == 0 ? 1 : baseCount;
        final level = LevelCalculator.calculateLevel(count);

        tempData.add({'dateIndex': i, 'count': count, 'level': level});
      } else {
        tempData.add({'dateIndex': i, 'count': 0, 'level': 0});
      }
    }

    // 计算当前总数并调整
    final currentTotal = tempData.fold<int>(0, (sum, item) => sum + item['count']!);

    if (currentTotal > 0) {
      final adjustmentFactor = AppConstants.totalArticles / currentTotal;

      // 第一轮调整
      for (var item in tempData) {
        if (item['count']! > 0) {
          final adjustedCount = (item['count']! * adjustmentFactor).round();
          item['count'] = adjustedCount > 0 ? adjustedCount : 1;
          item['level'] = LevelCalculator.calculateLevel(item['count']!);
        }
      }

      // 第二轮微调
      final newTotal = tempData.fold<int>(0, (sum, item) => sum + item['count']!);
      final remaining = AppConstants.totalArticles - newTotal;

      if (remaining != 0) {
        final activeDays = tempData.where((d) => d['level']! > 0).toList();
        if (activeDays.isNotEmpty) {
          final absRemaining = remaining.abs();
          final step = absRemaining ~/ activeDays.length;
          final remainder = absRemaining % activeDays.length;

          for (int i = 0; i < activeDays.length; i++) {
            final adjustment = step + (i < remainder ? 1 : 0);

            if (remaining > 0) {
              activeDays[i]['count'] = activeDays[i]['count']! + adjustment;
            } else if (remaining < 0 && activeDays[i]['count']! > adjustment) {
              activeDays[i]['count'] = activeDays[i]['count']! - adjustment;
            }

            activeDays[i]['level'] = LevelCalculator.calculateLevel(activeDays[i]['count']!);
          }
        }
      }
    }

    // 创建最终的 ActivityData 对象
    for (var item in tempData) {
      final date = now.subtract(Duration(days: item['dateIndex']!));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      data.add(ActivityData(
        date: dateStr,
        count: item['count']!,
        level: item['level']!,
      ));
    }

    return data;
  }

  /// 从 JSON 文件加载文章数据
  static Future<List<Article>> loadArticlesFromJson() async {
    // 如果已经加载过，直接返回缓存
    if (_cachedArticles != null) {
      return _cachedArticles!;
    }

    try {
      // 从 assets 加载 JSON 文件
      final jsonString = await rootBundle.loadString('assets/data/mock_articles.json');
      final jsonArray = jsonDecode(jsonString) as List;

      // 解析为 Article 对象列表
      _cachedArticles = jsonArray
          .map((json) => Article.fromJson(json as Map<String, dynamic>))
          .toList();

      return _cachedArticles!;
    } catch (e) {
      // 如果加载失败，返回空列表
      return [];
    }
  }

  /// 生成固定的文章数据（兼容旧接口）
  /// 注意：这个方法现在是异步的，需要使用 await
  static Future<List<Article>> generateArticleData() async {
    return await loadArticlesFromJson();
  }

  /// 从文章列表生成活动数据
  static List<ActivityData> generateActivityDataFromArticles(List<Article> articles) {
    final Map<String, int> dateCountMap = {};

    // 统计每个日期的文章数量
    for (final article in articles) {
      final dateStr = DateFormat('yyyy-MM-dd').format(article.date);
      dateCountMap[dateStr] = (dateCountMap[dateStr] ?? 0) + 1;
    }

    print('MockDataService: 统计到 ${dateCountMap.length} 个不同的日期有文章');
    dateCountMap.forEach((date, count) {
      print('  $date: $count 篇');
    });

    // 生成 ActivityData 列表
    final activityDataList = <ActivityData>[];
    final now = DateTime.now();

    // 生成过去一年的数据
    for (int i = 0; i < AppConstants.dataDays; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final count = dateCountMap[dateStr] ?? 0;
      final level = LevelCalculator.calculateLevel(count);

      activityDataList.add(ActivityData(
        date: dateStr,
        count: count,
        level: level,
      ));
    }

    // 统计有文章的天数
    final daysWithArticles = activityDataList.where((a) => a.count > 0).length;
    print('MockDataService: 在过去 ${AppConstants.dataDays} 天中有 $daysWithArticles 天有文章');

    return activityDataList;
  }

  /// 清除缓存
  static void clearCache() {
    _cachedArticles = null;
  }
}
