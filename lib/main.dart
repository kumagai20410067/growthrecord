import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'memo.dart';





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

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

   DateTime _focusedDay = DateTime.now();
   DateTime? _selectedDay;
   CalendarFormat _calendarFormat = CalendarFormat.month;
   Map<DateTime, List> _eventsList = {};
  DateTime? _selected;
   DateTime _focused = DateTime.now();

//イベントの追加
  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }
  @override
  void initState() {
    super.initState();

    _selected = _focused;
    _eventsList = {
      DateTime.now().subtract(Duration(days: 2)): ['Test A', 'Test B'],
      DateTime.now(): ['Test C', 'Test D', 'Test E', 'Test F'],
    };
  }
//イベントの追加

  @override
  Widget build(BuildContext context) {
//イベントの追加
    final _events = LinkedHashMap<DateTime, List>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_eventsList);

    List getEvent(DateTime day) {
      return _events[day] ?? [];
    }
//イベントの追加
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        //ハンバーガーメニュー
        //endDrawerで右側になる
        drawer: Drawer(
          child: ListView(
          children:<Widget>[
          Container(
                child: DrawerHeader(
                  child: Text(
                    "Header",
                    style: TextStyle(fontSize: 25),
                  ),
                  decoration: BoxDecoration(color: Colors.blue),
                ),
                height: 120),

                Container(
              child: ListTile(
                title: Text("item1"),
                trailing: Icon(Icons.arrow_forward),
               onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemoPage(),
                ),
              );
            },
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey),
                ),
              ),
            ),
        ])),
          //ハンバーガーメニュー
           
        body: Column(children: [
          //カレンダーを表示
           TableCalendar(
            locale: 'ja_JP',
            firstDay: DateTime.utc(2010, 4, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            eventLoader: getEvent,
            focusedDay: _focusedDay,

            //日付を選択可能に
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focused) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focused;
                });
              }
            },
            
            // 「月」「週」変更
            calendarFormat: _calendarFormat,

           onFormatChanged: (format) {  
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
          ),
           ListView(
            shrinkWrap: true,
            children: getEvent(_selected!)
                .map((event) => ListTile(
                      title: Text(event.toString()),
                    ))
                .toList(),
          )
        ]));
  }
}