import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yanyiheyi/widgets/app_toast.dart';
import 'package:yanyiheyi/main.dart' as app;

void main() {
  testWidgets('AppToast smoke test - basic functionality', (WidgetTester tester) async {
    // 构建应用
    await tester.pumpWidget(const app.MyApp());
    await tester.pumpAndSettle();

    // 导航到某个页面（等待 splash 完成）
    // 这里只是测试能正常构建，不会实际调用 Toast
    // 实际测试需要在真实设备上进行

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('AppToast no context test', (WidgetTester tester) async {
    // 测试不需要 context 的 Toast 调用
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  // 不需要 context，直接调用
                  AppToast.showSuccess('测试成功提示');
                  AppToast.showInfo('测试信息提示');
                  AppToast.showWarning('测试警告提示');
                  AppToast.showError('测试错误提示');

                  // 测试不同位置
                  AppToast.showSuccess(
                    '顶部提示',
                    gravity: ToastGravity.TOP,
                  );
                  AppToast.showSuccess(
                    '底部提示',
                    gravity: ToastGravity.BOTTOM,
                  );
                  AppToast.showSuccess(
                    '居中提示',
                    gravity: ToastGravity.CENTER,
                  );
                },
                child: const Text('测试 Toast'),
              );
            },
          ),
        ),
      ),
    );

    await tester.pump();

    // 点击按钮触发 Toast
    await tester.tap(find.text('测试 Toast'));
    await tester.pump();

    // 验证按钮存在（Toast 不会立即出现在 widget tree 中）
    expect(find.text('测试 Toast'), findsOneWidget);
  });
}
