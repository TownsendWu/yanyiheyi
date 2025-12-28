import 'package:intl/intl.dart';
import '../models/activity_data.dart';
import '../models/article.dart';
import '../../core/constants/app_constants.dart';
import '../../utils/level_calculator.dart';

/// Mock 数据生成服务
class MockDataService {
  MockDataService._();

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

  /// 生成固定的文章数据
  static List<Article> generateArticleData() {
    final now = DateTime.now();
    final articles = <Article>[];

    final titles = [
      '春日迟迟,草木蔓发',
      '夜雨寄北:写给远方的你',
      '读《红楼梦》有感',
      '江南烟雨,一梦千年',
      '时间的褶皱',
      '月光下的独白',
      '故乡的秋天',
      '诗意地栖居',
      '风起时的思念',
      '岁月的馈赠',
      '晨露未晞',
      '远山淡影',
      '暮色四合',
      '流年似水',
      '人间有味是清欢',
    ];

    for (int i = 0; i < 40; i++) {
      final daysAgo = i * 2;
      final date = now.subtract(Duration(days: daysAgo));

      articles.add(Article(
        id: 'article_$i',
        title: titles[i % titles.length],
        date: date,
        content: '这是第 ${i + 1} 篇文章的内容...',
      ));
    }

    return articles;
  }
}
