import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

DateTime _focused = DateTime.now();
DateTime? _selected;

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
        primarySwatch: Colors.blue,fontFamily: 'NotoSansJP'
      ),
      home: const MyHomePage(title: 'GROWTH RECORD'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        endDrawer: Drawer(
          child: ListView(
            children: const[
              DrawerHeader(
                decoration:BoxDecoration(color:Colors.yellow
                ),
                child: Text("My Home Page")),
                //仮置き
              ListTile(title: Text("data")),
              ListTile(title: Text("data2")),
              ListTile(title: Text("data3"))
                //仮置き
            ],
          ),
        ),
        body: Center(
          child: TableCalendar(
            locale: 'ja_JP',
            firstDay: DateTime.utc(2023, 4, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            selectedDayPredicate: (day) {
              return isSameDay(_selected, day);
            },
            onDaySelected: (selected, focused) {
              if (!isSameDay(_selected, selected)) {
                setState(() {
                  _selected = selected;
                  _focused = focused;
                });
              }
            },
            focusedDay: _focused,
          ),
        ));
  }
}