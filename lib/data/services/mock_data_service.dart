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

    final contents = [
      '''春日迟迟,卉木萋萋。仓庚喈喈,采蘩祁祁。

走在春天的田野上,我感受着微风拂过面颊的温柔。那些刚刚从泥土中探出头来的嫩芽,像是大地写给天空的诗句。每一朵花都在诉说着生命的故事,每一片叶子都在演绎着春天的奇迹。

我喜欢这样的季节,喜欢万物复苏的活力。在这个充满希望的时刻,我仿佛看到了自己内心深处的那个梦,正在悄悄发芽,期待着绽放的那一天。''',

      '''君问归期未有期,巴山夜雨涨秋池。
何当共剪西窗烛,却话巴山夜雨时。

夜深了,窗外的雨还在下着。我坐在灯下,思绪飘向了远方的你。不知你是否也在听雨,是否也在想念着这边的我们。

距离从来都不是阻碍,它只是让思念变得更加深刻。就像这夜雨,虽然打湿了大地,却也滋润了万物。我们的感情也是如此,经历了时间和距离的考验,反而变得更加纯粹和坚定。''',

      '''满纸荒唐言,一把辛酸泪。
都云作者痴,谁解其中味?

重读《红楼梦》,又是另一番滋味。年少时只看大观园的热闹,如今才读懂了其中的悲凉。

贾宝玉的痴,林黛玉的愁,薛宝钗的忍,每一个人物都是如此鲜活,如此令人唏嘘。曹雪芹用他细腻的笔触,为我们描绘了一个大观园,也描绘了一个微缩的社会。

人生如梦,富贵如云。那些看似美好的一切,终究会随风而逝。唯有真情,唯有那些刻骨铭心的经历,才是我们真正拥有的财富。''',

      '''江南好,风景旧曾谙。
日出江花红胜火,春来江水绿如蓝。
能不忆江南?

江南的雨,总是带着一种诗意。细雨蒙蒙中,青石板路上的行人撑着油纸伞,缓缓走过古桥,消失在烟雨朦胧的巷口。

我站在桥头,看着流水潺潺,听着远处传来的古筝声。这一刻,仿佛穿越了千年的时光,回到了那个诗意盎然的年代。

江南不仅是一方水土,更是一种情怀,一种文化的传承。在这里,每一处风景都有一个故事,每一条河流都承载着历史的记忆。''',

      '''时间是一条看不见的河,它静静地流淌,在我们的生命中留下深深的痕迹。

有时候,我觉得时间就像一本书的页码,翻过去就无法回头。那些曾经以为永远不会忘记的人和事,在岁月的冲刷下,渐渐变得模糊。

但是,时间也是公平的。它带走了我们的青春,却也给我们留下了智慧和回忆。那些曾经的挫折和痛苦,如今回想起来,都成了人生路上珍贵的财富。

珍惜当下的每一刻,因为这一刻终将成为历史。让我们的生命在时间的长河中,留下最美的印记。''',

      '''月光如水,静静流淌在我的窗前。

这是一个人的夜晚,安静得可以听到自己的呼吸。我喜欢这样的时刻,可以卸下所有的伪装,与内心深处那个真实的自己对话。

在月光下,我想起了很多人,很多事。那些快乐的、悲伤的、激动的、遗憾的回忆,此刻都变得格外清晰。

人生就像一场漫长的旅行,我们会遇到各种各样的人,经历各种各样的事。有些人在我们的生命中停留很久,有些人只是匆匆而过。但是,无论停留多久,他们都在我们的生命中留下了痕迹。

月光依旧,而我已经不再是当年的那个我。成长,就是不断地告别,不断地遇见,不断地成为更好的自己。''',

      '''秋风起兮白云飞,草木黄落兮雁南归。

故乡的秋天,总是带着一丝淡淡的愁绪。走在乡间的小路上,脚下的落叶发出沙沙的声响,像是大地在低语。

田野里,金黄的稻穗沉甸甸地垂着头,等待着收获。远处,农人们忙碌的身影在夕阳下显得格外温暖。这是一幅美丽的画卷,也是我记忆中最珍贵的画面。

故乡是一个很神奇的地方,即使离开再久,只要一回到那里,所有的陌生和不安都会消失。那些熟悉的山水、房屋、街道,都在告诉我们:这里是家,是心灵的港湾。''',

      '''人诗意地栖居在大地上。

这是荷尔德林的诗句,也是我一直向往的生活状态。诗意并不是要去远方寻找,它就在我们的日常生活中,只要我们有一双发现美的眼睛。

清晨,当第一缕阳光照进窗户,我在阳台上浇花,看着那些嫩绿的叶子上的露珠,闪闪发光。这就是诗意。

傍晚,我走在公园的小径上,听着鸟儿归巢的鸣叫,看着夕阳慢慢沉入地平线,把天空染成绚烂的红色。这也是诗意。

生活中处处都有诗意,只要我们慢下来,用心去感受,去体会。诗意的生活,就是一种用心生活的方式。''',

      '''风起了,吹乱了我的头发,也吹乱了我的思绪。

站在山坡上,我望着远方,思念着那个不在身边的人。风,成了我们的信使,把我的思念带给你,把你的思念带给我。

记得那年春天,我们也是在这样的风中漫步。你告诉我,风会带给人好消息。我笑着说,那我就每天等风来。

如今,风依旧在吹,而我们却已天各一方。但是我相信,无论距离多远,我们的心依然在一起。因为我们拥有共同的记忆,拥有彼此的思念。

风起时,请记得,有人在想念着你。''',

      '''岁月是一位慷慨的馈赠者。

它给了我们青春的活力,也给了我们中年的沉稳;它给了我们挫折的考验,也给了我们成长的机会。

回首往事,我深深地感谢岁月给予我的一切。那些快乐的时光让我感受到生命的美好,那些痛苦的经历让我变得更加坚强。

岁月的馈赠,不仅仅是年龄的增长,更是心智的成熟。它教会了我们如何去爱,如何去原谅,如何去感恩。

在未来的日子里,我会继续珍惜岁月的每一份馈赠,让生命在岁月的洗礼中,变得更加丰盈和厚重。'''
    ];

    // 所有标签池
    final allTags = [
      '生活随笔', '读书笔记', '散文', '诗歌', '情感',
      '故乡', '春天', '秋天', '思念', '时光',
      '哲学', '文学', '红楼梦', '江南', '诗意'
    ];

    // 封面图片 URL (使用 Unsplash)
    final coverImages = [
      'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=800&q=80',
      'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&q=80',
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
      'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800&q=80',
      'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=800&q=80',
      'https://images.unsplash.com/photo-1475924156734-496f6cac6ec1?w=800&q=80',
      'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&q=80',
      'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=800&q=80',
      'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=800&q=80',
      'https://images.unsplash.com/photo-1418065460487-3e41a6c84dc5?w=800&q=80',
    ];

    for (int i = 0; i < 40; i++) {
      final daysAgo = i * 2;
      // 精确到分钟的日期
      final date = now.subtract(Duration(
        days: daysAgo,
        hours: (i * 2) % 24,
        minutes: (i * 15) % 60,
      ));

      // 为每个文章随机分配 2-4 个标签
      final articleTags = <String>[];
      final tagCount = 2 + (i % 3); // 2-4 个标签
      final startIndex = i % (allTags.length - tagCount);
      for (int j = 0; j < tagCount; j++) {
        articleTags.add(allTags[(startIndex + j) % allTags.length]);
      }

      articles.add(Article(
        id: 'article_$i',
        title: titles[i % titles.length],
        date: date,
        content: contents[i % contents.length],
        coverImage: i % 3 == 0 ? coverImages[i % coverImages.length] : null, // 1/3 的文章有封面
        tags: articleTags,
      ));
    }

    return articles;
  }
}
