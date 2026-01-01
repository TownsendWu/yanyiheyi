import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'core/theme/app_theme.dart';
import 'core/services/local_storage_service.dart';
import 'data/services/api/api_service_interface.dart';
import 'data/services/article_storage_service.dart';

// Providers
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'providers/activity_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/membership_provider.dart';

import 'pages/splash_page.dart';

// 全局 Navigator Key，用于 FToast
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化核心服务
  final prefs = await SharedPreferences.getInstance();
  final storage = await LocalStorageService.getInstance();

  // 初始化文章存储服务
  final articleStorage = ArticleStorageService.getInstance(storage);
  await articleStorage.initializeArticles();

  // 设置文章存储服务到 API 工厂
  ApiServiceFactory.setArticleStorage(articleStorage);

  final apiService = ApiServiceFactory.getInstance();

  runApp(
    MultiProvider(
      providers: [
        // 核心服务
        Provider<LocalStorageService>.value(value: storage),
        Provider<ApiService>.value(value: apiService),

        // 认证和会员（依赖核心服务）
        ChangeNotifierProxyProvider2<
          LocalStorageService,
          ApiService,
          AuthProvider
        >(
          create: (_) => AuthProvider(storage: storage, apiService: apiService),
          update: (_, storage, apiService, auth) =>
              auth ?? AuthProvider(storage: storage, apiService: apiService),
        ),

        ChangeNotifierProxyProvider2<
          LocalStorageService,
          ApiService,
          MembershipProvider
        >(
          create: (_) =>
              MembershipProvider(storage: storage, apiService: apiService),
          update: (_, storage, apiService, membership) =>
              membership ??
              MembershipProvider(storage: storage, apiService: apiService),
        ),

        // 现有 Providers（保持兼容）
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs: prefs)),
        ChangeNotifierProvider(create: (_) => UserProvider(prefs: prefs)),
        ChangeNotifierProvider(
          create: (_) =>
              ActivityProvider(apiService: apiService, delayInit: true),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: '言意合一',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
      builder: FToastBuilder(),
      // 1. 设置支持的语言
      supportedLocales: const [
        Locale('zh', 'CN'), // 中文
        Locale('en', 'US'), // 英文
      ],
      navigatorKey: navigatorKey,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
    );
  }
}
