import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/services/local_storage_service.dart';
import 'data/services/api/api_service_interface.dart';

// Providers
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'providers/activity_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/membership_provider.dart';

import 'presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化核心服务
  final prefs = await SharedPreferences.getInstance();
  final storage = await LocalStorageService.getInstance();
  final apiService = ApiServiceFactory.getInstance();

  runApp(
    MultiProvider(
      providers: [
        // 核心服务
        Provider<LocalStorageService>.value(value: storage),
        Provider<ApiService>.value(value: apiService),

        // 认证和会员（依赖核心服务）
        ChangeNotifierProxyProvider2<LocalStorageService, ApiService, AuthProvider>(
          create: (_) => AuthProvider(
            storage: storage,
            apiService: apiService,
          ),
          update: (_, storage, apiService, auth) => auth ?? AuthProvider(
            storage: storage,
            apiService: apiService,
          ),
        ),

        ChangeNotifierProxyProvider2<LocalStorageService, ApiService, MembershipProvider>(
          create: (_) => MembershipProvider(
            storage: storage,
            apiService: apiService,
          ),
          update: (_, storage, apiService, membership) => membership ?? MembershipProvider(
            storage: storage,
            apiService: apiService,
          ),
        ),

        // 现有 Providers（保持兼容）
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs: prefs)),
        ChangeNotifierProvider(create: (_) => UserProvider(prefs: prefs)),
        ChangeNotifierProvider(create: (_) => ActivityProvider(delayInit: true)),
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
    );
  }
}
