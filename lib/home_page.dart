import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:growthrecord/memo.dart';
import 'package:table_calendar/table_calendar.dart';//カレンダー表示用
import 'package:shared_preferences/shared_preferences.dart';//データ保存用
import 'addevent.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

   DateTime _focused = DateTime.now();
   DateTime? _selected;
   CalendarFormat _calendarFormat = CalendarFormat.month;
  //  Map<DateTime, List> _eventsList = {};

// //イベントの追加（仮）
//   int getHashCode(DateTime key) {
//     return key.day * 1000000 + key.month * 10000 + key.year;
//   }

//   @override
//   void initState() {
//     super.initState();

//     _selected = _focused;
//     _eventsList = {
//       DateTime.now().subtract(const Duration(days: 10)): ['Test A', 'Test B'],
//       DateTime.now(): ['Test C', 'Test D', 'Test E', 'Test F'],
//     };
//   }

  @override
  Widget build(BuildContext context) {
    // final _events = LinkedHashMap<DateTime, List>(
    //   equals: isSameDay,
    //   hashCode: getHashCode,
    // )..addAll(_eventsList);

    // List getEvent(DateTime day) {
    //   return _events[day] ?? [];
    // }
//イベントの追加（仮）

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),

        //ハンバーガーメニュー
        drawer: Drawer(
          child: ListView(
          children:<Widget>[
          Container(
                height: 120,
                child: const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.purple),
                  child: Text(
                    "Header",
                    style: TextStyle(fontSize: 25,color: Colors.white),
                  ),
                )),

                Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey),
                ),
              ),
              child: ListTile(
                title: const Text("item1"),
                trailing: const Icon(Icons.arrow_forward),
               onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemoPage(),
                ),
              );
            },
              ),
            ),

            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey),
                ),
              ),
              child: ListTile(
                title: const Text("仮置き"),
                trailing: const Icon(Icons.arrow_forward),
               onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InputPage(),
                ),
              );
            },
              ),
            ),
        ])),
          //ハンバーガーメニュー

           //カレンダーを表示
        body: Column(children: [
          TableCalendar(
            locale: 'ja_JP',//日本語対応
            firstDay: DateTime.utc(2010, 4, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            // eventLoader: getEvent, ////イベント表示
            focusedDay:_focused,

            //日付を選択可能に
            selectedDayPredicate: (day) {
              return isSameDay(_selected, day);
            },
            onDaySelected: (selectedDay, focused) {
              if (!isSameDay(_selected, selectedDay)) {
                setState(() {
                  _selected = selectedDay;
                  _focused = focused;
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

          // //イベントを日付ごとに表示
          //  ListView(
          //   shrinkWrap: true,
          //   children: getEvent(_selected!)
          //       .map((event) => ListTile(
          //             title: Text(event.toString()),
          //           ))
          //       .toList(),
          // )
          
        ]));
  }
}