import 'package:flutter/material.dart';
import 'package:growthrecord/graph_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:growthrecord/database_helper.dart' as DBHelper;
import 'package:growthrecord/select_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.petId, required this.selectedPet})
      : super(key: key);
  final int petId;
  final String selectedPet;

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _memoController;
  late DBHelper.DatabaseHelper _databaseHelper;
  late DateTime _selectedDate;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _showForm = false;
  bool _dataExists = false;
  List<Map<String, dynamic>> _dailyData = [];

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _memoController = TextEditingController();
    _databaseHelper = DBHelper.DatabaseHelper.instance;
    _selectedDate = DateTime.now();
    _fetchDailyData(_selectedDate);
  }

  Future<void> _fetchDailyData(DateTime date) async {
    final formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final data =
        await _databaseHelper.retrieveData(widget.petId, formattedDate);
    setState(() {
      _dailyData = data;
      _dataExists = data.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('${widget.selectedPet}の成長記録'),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'ja_JP',
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _selectedDate,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            startingDayOfWeek: StartingDayOfWeek.monday,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
                _showForm = false;
                _fetchDailyData(_selectedDate);
              });
            },
            selectedDayPredicate: (DateTime date) {
              return isSameDay(_selectedDate, date);
            },
          ),
          ElevatedButton(
            onPressed: () {
              _updateData();
              _showFormAlertDialog(context);
            },
            child: Text(_dataExists ? '更新する' : '入力する'),
          ),
          if (_showForm)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '全長（cm）'),
                  ),
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '体重（g）'),
                  ),
                  TextField(
                    controller: _memoController,
                    decoration: const InputDecoration(labelText: 'メモ'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _saveData();
                      Navigator.of(context).pop();
                    },
                    child: const Text('保存'),
                  ),
                ],
              ),
            ),
          if (_dailyData.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _dailyData.length,
                itemBuilder: (context, index) {
                  final data = _dailyData[index];
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('全長: ${data['height']}cm'),
                        Text('体重: ${data['weight']}g'),
                        Text(
                            'メモ: ${data['memo'].isEmpty ? 'なし' : data['memo']}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _showDeleteConfirmationDialog(data['id']);
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'ペット選択',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: '記録',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'グラフ',
          ),
        ],
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SelectPage(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GraphPage(
                    petId: widget.petId, selectedPet: widget.selectedPet),
              ),
            );
          }
        },
      ),
    );
  }

  void _saveData() async {
    String formattedDate =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    double height = double.tryParse(_heightController.text) ?? 0.0;
    double weight = double.tryParse(_weightController.text) ?? 0.0;
    String memo = _memoController.text;

    int petId = widget.petId;

    if (_dataExists) {
      await _databaseHelper.updateData(
          _dailyData[0]['id'], height, weight, memo);
    } else {
      await _databaseHelper.insertData(
          petId, formattedDate, height, weight, memo);
    }

    _heightController.clear();
    _weightController.clear();
    _memoController.clear();

    setState(() {
      _fetchDailyData(_selectedDate);
    });
  }

  void _showFormAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('データ入力'),
          contentPadding: EdgeInsets.zero,
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '全長（cm）'),
                ),
                TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '体重（g）'),
                ),
                TextField(
                  controller: _memoController,
                  decoration: const InputDecoration(labelText: 'メモ'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveData();
                Navigator.of(context).pop();
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

// 変更ボタンが押された時の処理
  void _updateData() {
    // すでに入力されているデータが存在するか確認
    if (_dailyData.isNotEmpty) {
      // 入力フォームに既存のデータをセット
      _heightController.text = _dailyData[0]['height'].toString();
      _weightController.text = _dailyData[0]['weight'].toString();
      _memoController.text = _dailyData[0]['memo'];
    }
  }

  void _showDeleteConfirmationDialog(int dataId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('削除の確認'),
          content: const Text('このデータを削除しますか？'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteData(dataId);
                Navigator.of(context).pop();
              },
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }

  void _deleteData(int id) async {
    await _databaseHelper.deleteData(id);
    _fetchDailyData(_selectedDate);
  }
}
