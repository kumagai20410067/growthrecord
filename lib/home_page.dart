import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:growthrecord/memo.dart';
import 'package:table_calendar/table_calendar.dart';//カレンダー表示用
import 'package:shared_preferences/shared_preferences.dart';

class Record{
  final String name;
  final double height;
  final double weight;
  final String memo;

  Record({
    required this.name,
    required this.height,
    required this.weight,
    required this.memo});

factory Record.fromJson(Map<String,dynamic>json){
  return Record(
    name: json['name'],
    height: json['height'],
    weight: json['weight'],
    memo: json['memo'],
  );
}

Map<String,dynamic> toJson()
{
  return{
    'name':name,
    'height':height,
    'weight':weight,
    'memo':memo,
  };
}
}
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

   late SharedPreferences _prefs;

   Map<DateTime,List<Record>> _events = {};
   Map<DateTime,bool> _recordExistenceMap = {};

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  List<Record> _selectedEvents = [];
  bool _isRecordExisting= false;
  
@override
void initState(){
  super.initState();
  initializeSharedPreferences();

    //アプリを開いたタイミングで開いた日付を選択した状態にする
    _focused = DateTime.now();
    _selected = DateTime.now();
}

void initializeSharedPreferences()async{
  _prefs = await SharedPreferences.getInstance();
  loadEvents();
}
//成長記録の読み込み
void loadEvents(){
  setState((){
final saveEvents = _prefs.getString('events');
  if(saveEvents !=null){
final decodedEvents = jsonDecode(saveEvents);
_events = Map<DateTime,List<Record>>.from(
  decodedEvents.map(
    (key,value) => MapEntry(
      DateTime.parse(key),
      List<Record>.from(value.map((x) => Record.fromJson(x))),
    ),
  ),
);
_recordExistenceMap = Map<DateTime,bool>.from(
  _events.map((key,value) => MapEntry(key,value.isNotEmpty)),
);
}
});
}
//成長記録の記録
void saveEvents(){
  final encodedEvents = jsonEncode(
    _events.map((key, value) => MapEntry(
      key.toString(),
       value.map((x) => x.toJson()).toList(),
       ),
       ),
  );
  _prefs.setString('events',encodedEvents);
}
//記録の追加
void addRecord(DateTime date,Record record){
  setState((){
    if(_events[date] != null){
      _events[date] !.add(record);
    }else{
      _events[date] = [record];
    }
    _selectedEvents = _events[date]!;
    _recordExistenceMap[date] = true;
  });
}
//記録の消去
void deleteRecord(DateTime date,Record record){
  setState((){
    _events[date]?.remove(record);
    _selectedEvents = _events[date] ?? [];
    if(_events[date]?.isEmpty ?? true){
      _recordExistenceMap[date] = false;
    }
    saveEvents();
  });
}

Widget _buildRecordList(){
  if(_selectedEvents.isEmpty){
    return const SizedBox();
  }
return ListView.builder(
  shrinkWrap: true,//ListViewの高さをlistview内で表示している要素をすべて表示したときの高さにする
  physics: const NeverScrollableScrollPhysics(),//スクロール不可設定
  itemCount: _selectedEvents.length,
  itemBuilder: (BuildContext context,int index){
    Record record = _selectedEvents[index];
    return ListTile(
      title: Text('名前： ${record.name}\n体長： ${record.height}cm\n体重：${record.weight}g\nメモ：${record.memo}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed:(){
          showDialog(
            context: context,
             builder:(BuildContext context) {
               return AlertDialog(
                title: const Text('成長記録を削除'),
                content: const Text('この成長記録を削除しますか？'),
                actions: [
                  TextButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    child: const Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: (){
                        deleteRecord(_selected!, record);
                        Navigator.of(context).pop();
                      }, 
                      child: const Text('削除'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
}


  @override
  Widget build(BuildContext context) {
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
                    "一覧",
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
                title: const Text("仮"),
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
        ])),
          //ハンバーガーメニュー

           //カレンダーを表示
        body: Column(children: [
          TableCalendar(
            locale: 'ja_JP',//カレンダーの日本語対応
            firstDay: DateTime.utc(2010, 4, 1),
            lastDay: DateTime.utc(2030, 12, 31),
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
                 _selectedEvents =_events[selectedDay] ?? [];
                 _isRecordExisting= _recordExistenceMap[selectedDay] ?? false;
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
        ElevatedButton(
          onPressed: (){
          showDialog(
            context: context,
           builder: (BuildContext context){
            return AlertDialog(
              title:  _isRecordExisting ? const Text('成長記録を更新する') : const Text('成長記録を入力する'),
              content:SingleChildScrollView(
                child:Column(mainAxisSize: MainAxisSize.min,//余りのスペースをなくす
                children: [
                  //ここから
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '名前',
                    ),
                  ),
                   //ここで入力欄一つ
                  TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,//キーボード入力を数字入力に変更
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],//数字のみ入力可能に
                    decoration: const InputDecoration(
                      labelText: '体長（cm）',
                    ),   
                  ),
                 
                  TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,//キーボード入力を数字入力に変更
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],//数字のみ入力可能に
                    decoration: const InputDecoration(
                      labelText: '体重（g）',
                    ),   
                  ),
                  TextFormField(
                    controller: _memoController,
                    decoration: const InputDecoration(
                      labelText: 'メモ',
                    ),
                  ),
                ],
                ),
                ),
                actions: [
                  TextButton(
                    onPressed: (){
                    Navigator.of(context).pop();
                  }, 
                  child: const Text('キャンセル'),
                  ),
                  TextButton(
                    child: _isRecordExisting ? const Text('更新'): const Text('保存'),
                    onPressed: (){
                    if(_heightController.text.isNotEmpty&&
                       _weightController.text.isNotEmpty
                   )
                   {
                    Record record = Record(
                      name: _nameController.text,
                      height: double.tryParse(_heightController.text)?? 0.0,
                      weight:double.tryParse(_weightController.text)?? 0.0,
                      memo: _memoController.text.isNotEmpty ? _memoController.text : 'なし',
                      );
                      if(_isRecordExisting){
                        deleteRecord(_selected!,_selectedEvents[0]);
                      }
                      addRecord(_selected!, record);
                   }
                   Navigator.of(context).pop();
                  },
                  ),
                ],
            );
           },
           );
        }, 
        child: _isRecordExisting ? const Text('成長記録を更新する'): const Text('成長記録を入力する'),
        ),
      Expanded(
        child: SingleChildScrollView(
          child: _buildRecordList(),
          ),
          ),
        ],
        ),
        );
  }
}