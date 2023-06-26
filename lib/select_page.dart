import 'package:flutter/material.dart';
import 'package:growthrecord/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});

  @override
   State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  late SharedPreferences _prefs;
  List<String> _petList = [];
  final TextEditingController _petNameController = TextEditingController();
  bool _isAddingPet = false;

  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
  }

  void initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    loadPetList();
  }

  void loadPetList() {
    setState(() {
      _petList = _prefs.getStringList('petList') ?? [];
    });
  }

  void savePetList() {
    _prefs.setStringList('petList', _petList);
  }

  void addPet(String petName) {
    setState(() {
      _petList.add(petName);
      savePetList();
      _isAddingPet = false;
    });
  }

  void updatePetName(String newName, int index) {
    setState(() {
      _petList[index] = newName;
      savePetList();
    });
  }

  void deletePet(int index) {
    setState(() {
      _petList.removeAt(index);
      savePetList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('ペットを選択してください'),
        actions: [
          if (!_isAddingPet)
            TextButton(
              onPressed: () {
                setState(() {
                  _isAddingPet = true;
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: const Text('ペットを追加'),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isAddingPet)
            Column(
              children: [
                TextField(
                  controller: _petNameController,
                  decoration: const InputDecoration(
                    labelText: 'ペットの名前',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    String petName = _petNameController.text.trim();
                    if (petName.isNotEmpty) {
                      addPet(petName);
                      _petNameController.clear();
                    }
                  },
                  child: const Text('追加'),
                ),
              ],
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _petList.length,
              itemBuilder: (BuildContext context, int index) {
                String petName = _petList[index];
                return ListTile(
                  title: Text(petName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditDialog(context, petName, index);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteDialog(context, index);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    navigateToHomePage(context, petName);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void navigateToHomePage(BuildContext context, String selectedPet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(
          // title: '$selectedPetの成長記録',
          selectedPet: selectedPet,
        ),
      ),
    );
  }

void _showEditDialog(BuildContext context, String currentName, int index) {
  String newName = currentName;
  TextEditingController editNameController =
      TextEditingController(text: currentName);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('名前の変更'),
        content: TextField(
          controller: editNameController,
          onChanged: (value) {
            newName = value;
          },
          decoration: const InputDecoration(
            labelText: '名前を変更してください',
          ),
        ),
        actions: [
          TextButton(
            child: const Text('キャンセル'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('保存'),
            onPressed: () {
              updatePetName(newName, index);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('削除の確認'),
          content: const Text('本当に削除しますか？'),
          actions: [            
            TextButton(
              child: const Text('削除'),
              onPressed: () {
                deletePet(index);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
