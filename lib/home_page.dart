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
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _memoController;
  late DBHelper.DatabaseHelper _databaseHelper;
  late DateTime _selectedDate;
  bool _showForm = false;
  List<Map<String, dynamic>> _dailyData = [];

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
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
                _showForm = true;
                _fetchDailyData(_selectedDate);
              });
            },
            selectedDayPredicate: (DateTime date) {
              return isSameDay(_selectedDate, date);
            },
          ),
          if (_showForm)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: '体重（kg）'),
                  ),
                  TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: '体長（cm）'),
                  ),
                  TextField(
                    controller: _memoController,
                    decoration: InputDecoration(labelText: 'メモ'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _saveData();
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
                    title: Text(
                        '体重: ${data['weight']}kg, 体長: ${data['height']}cm, メモ: ${data['memo']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editData(data);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteData(data['id']);
                          },
                        ),
                      ],
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
          // else if (index == 2) {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => GraphPage(),
          //     ),
          //   );
          // }
        },
      ),
    );
  }

  void _saveData() async {
    String formattedDate =
        "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}";
    double weight = double.tryParse(_weightController.text) ?? 0.0;
    double height = double.tryParse(_heightController.text) ?? 0.0;
    String memo = _memoController.text;

    int petId = widget.petId;

    await _databaseHelper.insertData(
        petId, formattedDate, weight, height, memo);

    _weightController.clear();
    _heightController.clear();
    _memoController.clear();

    setState(() {
      _showForm = false;
      _fetchDailyData(_selectedDate);
    });
  }

  void _editData(Map<String, dynamic> data) {
    setState(() {
      _showForm = true;
      _selectedDate = DateTime.parse(data['date']);
      _weightController.text = data['weight'].toString();
      _heightController.text = data['height'].toString();
      _memoController.text = data['memo'];
    });
  }

  void _deleteData(int id) async {
    await _databaseHelper.deleteData(id);
    _fetchDailyData(_selectedDate);
  }
}
