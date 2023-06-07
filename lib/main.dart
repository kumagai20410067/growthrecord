import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'memo.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
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
        ]
 )
          ),
            
          
          

        
        body: Center(
          child: TableCalendar(
            locale: 'ja_JP',
            firstDay: DateTime.utc(2023, 4, 1),
            lastDay: DateTime.utc(2030, 12, 31),
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