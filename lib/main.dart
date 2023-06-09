import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:growthrecord/select_page.dart';

void main() {
  initializeDateFormatting('ja').then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GROWTH RECORD',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'NotoSansJP',
      ),
      home: const SelectPage(),
    );
  }
}
