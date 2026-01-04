import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/activity_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/page_container.dart';
import '../widgets/writing_activity_calendar.dart';
import '../widgets/expandable_fab.dart';
import '../widgets/article_list.dart';
import '../widgets/article_selection_menu.dart';
import '../widgets/menu_content.dart';
import '../widgets/draggable_side_sheet.dart';
import '../data/models/article.dart';
import 'article_detail_page.dart';

/// 首页
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _lastPressedAt;
  bool _isSelectionMode = false;
  int _selectedCount = 0;
  VoidCallback? _handlePin;
  VoidCallback? _handleDelete;
  VoidCallback? _handleCancel;
  VoidCallback? _handleSelectAll;

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

  /// 处理文章更新
  void _handleArticlesUpdated(List<Article> updatedArticles) {
    final activityProvider = context.read<ActivityProvider>();
    for (final article in updatedArticles) {
      activityProvider.updateArticlePinnedStatus(article.id, article.isPinned);
    }
  }

  /// 处理文章删除
  void _handleArticlesDeleted(List<String> articleIds) {
    final activityProvider = context.read<ActivityProvider>();
    activityProvider.deleteArticles(articleIds);
  }

  /// 处理多选模式状态变化
  void _handleSelectionModeChanged(
    bool isSelectionMode,
    int selectedCount,
    VoidCallback handlePin,
    VoidCallback handleDelete,
    VoidCallback handleCancel,
    VoidCallback handleSelectAll,
  ) {
    setState(() {
      _isSelectionMode = isSelectionMode;
      _selectedCount = selectedCount;
      _handlePin = handlePin;
      _handleDelete = handleDelete;
      _handleCancel = handleCancel;
      _handleSelectAll = handleSelectAll;
    });
  }

  /// 创建新文章
  Future<void> _createNewArticle() async {
    // 创建一个临时文章对象，不保存到数据库
    final now = DateTime.now();
    final tempArticle = Article(
      id: '', // 空ID表示这是临时文章
      title: '',
      date: now,
      updatedAt: now,
      content: null,
    );

    // 导航到文章详情页
    if (mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ArticleDetailPage(article: tempArticle),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 0.05);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    }
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
        body: Stack(
          children: [
            SafeArea(
              child: Consumer<ActivityProvider>(
                builder: (context, activityProvider, child) {
                  final mockData = activityProvider.activities;
                  final articles = activityProvider.articles;
                  return SingleChildScrollView(
                    child: PageContainer(
                      extraPadding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          WritingActivityCalendar(
                            data: mockData,
                            totalCountLabel: '${DateTime.now().year} 年总共创作了 ${activityProvider.getTotalCountByYear(DateTime.now().year)} 篇章',
                          ),
                          const SizedBox(height: 20),
                          ArticleList(
                            articles: articles,
                            onArticlesUpdated: _handleArticlesUpdated,
                            onArticlesDeleted: _handleArticlesDeleted,
                            onSelectionModeChanged: _handleSelectionModeChanged,
                          ),
                          // 为底部菜单留出空间
                          if (_isSelectionMode) const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // 底部多选菜单
            if (_isSelectionMode && _handlePin != null && _handleDelete != null && _handleCancel != null && _handleSelectAll != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Consumer<ActivityProvider>(
                  builder: (context, activityProvider, child) {
                    return ArticleSelectionMenu(
                      selectedCount: _selectedCount,
                      totalCount: activityProvider.articles.length,
                      onPin: _handlePin!,
                      onDelete: _handleDelete!,
                      onCancel: _handleCancel!,
                      onSelectAll: _handleSelectAll!,
                    );
                  },
                ),
              ),
          ],
        ),
        floatingActionButton: IgnorePointer(
          ignoring: _isSelectionMode,
          child: AnimatedSlide(
            offset: _isSelectionMode ? const Offset(0, 2) : Offset.zero,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: _isSelectionMode ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Builder(
                builder: (context) {
                  return ExpandableFAB(
                    offsetFromBottom: -60,
                    buttonSize: 48,
                    expandedButtonSize: 48,
                    spacing: 12,
                    offsetFromRight: 18,
                    onMainButtonPressed: _createNewArticle,
                    items: [
                      FABItem(
                        icon: Icons.edit_note,
                        onPressed: () => print('辅助模式'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        iconColor: Colors.white,
                      ),
                      FABItem(
                        icon: Icons.psychology,
                        onPressed: () => print('深度模式'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        iconColor: Colors.white,
                      ),
                      FABItem(
                        icon: Icons.edit,
                        onPressed: () => print('纯净模式'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        iconColor: Colors.white,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
