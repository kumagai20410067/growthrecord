import 'package:flutter/material.dart';
import 'package:growthrecord/home_page.dart';
import 'package:intl/date_symbol_data_local.dart';



void main() {
  //runApp(const MyApp());
initializeDateFormatting('ja').then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GROWTH RECORD',
      theme: ThemeData(
        primarySwatch: Colors.purple,fontFamily: 'NotoSansJP'
      ),
      home: const MyHomePage(title: 'GROWTH RECORD'),
    );
  }
}

