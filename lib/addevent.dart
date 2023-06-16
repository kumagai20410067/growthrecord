import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputPage extends StatefulWidget {
  const InputPage({Key? key}) : super(key: key);

  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  SharedPreferences? _preferences;
   @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _preferences = await SharedPreferences.getInstance();
    _loadSavedData();
  }

  void _loadSavedData() {
    setState(() {
      _heightController.text = _preferences?.getString('height') ?? '';
      _weightController.text = _preferences?.getString('weight') ?? '';
      _memoController.text = _preferences?.getString('memo') ?? '';
    });
  }

  void _saveGrowthRecord() {
    String height = _heightController.text;
    String weight = _weightController.text;
    String memo = _memoController.text;
    if (height.isEmpty || weight.isEmpty || memo.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('入力エラー'),
            content: const Text('すべてのフィールドを入力してください。'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    _preferences?.setString('height', height);
    _preferences?.setString('weight', weight);
    _preferences?.setString('memo', memo);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('保存完了'),
          content: const Text('成長記録が保存されました。'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _clearFields(){
    _heightController.clear();
    _weightController.clear();
    _memoController.clear();
  }

  @override
  void dispose(){
    super.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _memoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('成長記録を入力する'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '体長（cm）',
              ),
            ),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '体重（kg）',
              ),
            ),
            TextField(
              controller: _memoController,
              decoration: const InputDecoration(
                labelText: 'メモ',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
              onPressed: _saveGrowthRecord,
              child: const Text('保存'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _clearFields,
              child: const Text('クリア'),
              ),
              ],
            )
            
          ],
        ),
      ),
    );
  }
}
