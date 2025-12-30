import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/activity_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/page_container.dart';
import '../../widgets/writing_activity_calendar.dart';
import '../../widgets/expandable_fab.dart';
import '../../widgets/article_list.dart';
import '../../widgets/menu_content.dart';
import '../../widgets/draggable_side_sheet.dart';

/// 首页
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _lastPressedAt;

  void _showMenu() {
    DraggableSideSheet.right(
      context: context,
      width: MediaQuery.of(context).size.width * 0.8,
      body: const MenuContent(),
    );
  }

  Future<bool> _onWillPop() async {
    if (_lastPressedAt == null ||
        DateTime.now().difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      _lastPressedAt = DateTime.now();
      Fluttertoast.showToast(
        msg: '再按一次退出应用',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16,
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          themeController: context.watch<ThemeProvider>(),
          onMenuPressed: _showMenu,
        ),
        body: SafeArea(
          child: Consumer<ActivityProvider>(
            builder: (context, activityProvider, child) {
              final mockData = activityProvider.activities;
              final articles = activityProvider.articles;

              // 调试信息
              print('HomePage: activities.length = ${mockData.length}');
              print('HomePage: articles.length = ${articles.length}');
              print('HomePage: isLoading = ${activityProvider.isLoading}');
              if (mockData.isNotEmpty) {
                print('HomePage: first activity date = ${mockData.first.date}, count = ${mockData.first.count}');
              }

              return SingleChildScrollView(
                child: PageContainer(
                  extraPadding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '写作活动统计',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      WritingActivityCalendar(
                        data: mockData,
                        totalCountLabel: '2025 年总共创作了 ${activityProvider.getTotalCountByYear(2025)} 篇章',
                      ),
                      const SizedBox(height: 20),
                      ArticleList(articles: articles),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return ExpandableFAB(
              offsetFromBottom: -60,
              buttonSize: 48,
              expandedButtonSize: 48,
              spacing: 12,
              offsetFromRight: 18,
              items: [
                FABItem(
                  icon: Icons.edit,
                  onPressed: () => print('新建文章'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  iconColor: Colors.white,
                ),
                FABItem(
                  icon: Icons.photo_camera,
                  onPressed: () => print('拍照记录'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  iconColor: Colors.white,
                ),
                FABItem(
                  icon: Icons.mic,
                  onPressed: () => print('语音记录'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  iconColor: Colors.white,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
