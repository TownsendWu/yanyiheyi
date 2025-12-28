import 'package:flutter/material.dart';
import '../data/models/activity_data.dart';
import '../data/models/article.dart';
import '../data/services/mock_data_service.dart';

/// 活动数据状态管理 Provider
class ActivityProvider extends ChangeNotifier {
  List<ActivityData> _activities = [];
  List<Article> _articles = [];
  bool _isLoading = true;

  ActivityProvider({bool syncInit = false, bool delayInit = false}) {
    if (!delayInit) {
      if (syncInit) {
        _initializeDataSync();
      } else {
        _initializeData();
      }
    }
  }

  List<ActivityData> get activities => _activities;
  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;

  /// 获取总文章数
  int get totalCount {
    return _activities.fold(0, (sum, item) => sum + item.count);
  }

  /// 获取某年总文章数
  int getTotalCountByYear(int year) {
    return _activities
        .where((activity) => activity.dateTime.year == year)
        .fold(0, (sum, item) => sum + item.count);
  }

  /// 初始化数据
  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();

    // 模拟异步加载
    await Future.delayed(const Duration(milliseconds: 100));

    _activities = MockDataService.generateActivityData();
    _articles = MockDataService.generateArticleData();

    _isLoading = false;
    notifyListeners();
  }

  /// 同步初始化数据 (用于测试)
  void _initializeDataSync() {
    _activities = MockDataService.generateActivityData();
    _articles = MockDataService.generateArticleData();
    _isLoading = false;
  }

  /// 刷新数据
  Future<void> refresh() async {
    await _initializeData();
  }

  /// 预加载数据（供 SplashPage 使用）
  Future<void> preload() async {
    await _initializeData();
  }
}
