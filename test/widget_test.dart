// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:yanyiheyi/main.dart';
import 'package:yanyiheyi/providers/theme_provider.dart';
import 'package:yanyiheyi/providers/activity_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(prefs: prefs)),
          ChangeNotifierProvider(create: (_) => ActivityProvider(syncInit: true)),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the app title is present
    expect(find.text('扭动的妖怪蝙蝠'), findsOneWidget);
  });
}
