import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:growthrecord/database_helper.dart' as DBHelper;
import 'package:growthrecord/select_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.petId, required this.selectedPet})
      : super(key: key);

  final int petId;
  final String selectedPet;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _memoController;
  late DBHelper.DatabaseHelper _databaseHelper;
  late DateTime _selectedDate;
  bool _showForm = false;
  bool _dataExists = false; // 新規追加か更新かのフラグ
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
        "${date.year}-${date.month}-${date.day}".padLeft(10, '0');
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
        title: Text('${widget.selectedPet}の記録'),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'ja_JP',
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2023, 12, 31),
            focusedDay: _selectedDate,
            calendarFormat: CalendarFormat.month,
            onFormatChanged: (format) {},
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
                    decoration: InputDecoration(labelText: '体長（cm）'),
                  ),
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: '体重（g）'),
                  ),
                  TextField(
                    controller: _memoController,
                    decoration: InputDecoration(labelText: 'メモ'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _saveData();
                      Navigator.of(context).pop(); // ダイアログを閉じる
                    },
                    child: Text('保存'),
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
                        Text('体長: ${data['height']}cm'),
                        Text('体重: ${data['weight']}g'),
                        Text(
                            'メモ: ${data['memo'].isEmpty ? 'なし' : data['memo']}'),
                        if (_dailyData.length > 1 && index > 0) // 差分表示
                          _buildDifferenceText(data, _dailyData[index - 1]),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
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
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'ペット選択',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'グラフ',
          ),
        ],
        currentIndex: 1, // 初期表示はホーム
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelectPage(),
              ),
            );
          }
        },
      ),
    );
  }

  void _saveData() async {
    String formattedDate =
        "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}";
    double height = double.tryParse(_heightController.text) ?? 0.0;
    double weight = double.tryParse(_weightController.text) ?? 0.0;
    String memo = _memoController.text;

    int petId = widget.petId;

    if (_dataExists) {
      // 既存データがある場合は更新
      await _databaseHelper.updateData(
          _dailyData[0]['id'], height, weight, memo);
    } else {
      // 既存データがない場合は新規追加
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
          title: Text('データ入力'),
          contentPadding: EdgeInsets.zero, // 余白を無効にする
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: '体長（cm）'),
                ),
                TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: '体重（g）'),
                ),
                TextField(
                  controller: _memoController,
                  decoration: InputDecoration(labelText: 'メモ'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveData();
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: Text('保存'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int dataId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('削除の確認'),
          content: Text('このデータを削除しますか？'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteData(dataId);
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: Text('削除'),
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

  Widget _buildDifferenceText(
      Map<String, dynamic> currentData, Map<String, dynamic> previousData) {
    final heightDifference = currentData['height'] - previousData['height'];
    final weightDifference = currentData['weight'] - previousData['weight'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('前回からの差分:'),
        if (heightDifference != 0)
          Text('  体長: ${heightDifference > 0 ? '+' : ''}$heightDifference cm'),
        if (weightDifference != 0)
          Text('  体重: ${weightDifference > 0 ? '+' : ''}$weightDifference g'),
      ],
    );
  }
}
