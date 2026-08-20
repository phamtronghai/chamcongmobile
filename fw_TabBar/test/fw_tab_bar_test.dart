import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fw_tab_bar/fw_tab_bar.dart';

void main() {
  testWidgets('FwTabBar switches tab on tap', (tester) async {
    final controller = TabController(length: 2, vsync: const TestVSync());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FwTabBar(
            controller: controller,
            width: 240,
            tabWidth: 110,
            tabs: const [
              Tab(text: 'One'),
              Tab(text: 'Two'),
            ],
          ),
        ),
      ),
    );

    expect(controller.index, 0);
    await tester.tap(find.text('Two'));
    await tester.pumpAndSettle();
    expect(controller.index, 1);
  });
}
