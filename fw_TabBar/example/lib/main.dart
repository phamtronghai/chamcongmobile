import 'package:flutter/material.dart';
import 'package:fw_tab_bar/fw_tab_bar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Tab Bar Example')),
        body: Center(
          child: TabBarWidget(
            firstTab: 'Tab 1',
            secondTab: 'Tab 2',
            onTabChanged: (int index) {
              debugPrint('Selected tab: $index');
            },
            selectedTabDecoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(50)),
              border: Border.fromBorderSide(BorderSide(color: Color(0xFFD9D9D9))),
              color: Color(0xFFFFFFFF),
            ),
            backgroundBoxDecoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(50)),
              color: Color(0xFF2F2F2F),
            ),
            selectedTabTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFFFFF),
              fontSize: 16,
            ),
            unselectedTabTextStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Color(0xFF2F2F2F),
              fontSize: 16,
            ),
          )

        ),
      ),
    );
  }
}
