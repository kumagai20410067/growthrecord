import 'package:flutter/material.dart';
import 'package:growthrecord/home_page.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pets_database.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      )
    ''');
  }

  Future<int> insertPet(String name) async {
    Database db = await instance.database;
    return await db.insert('pets', {'name': name});
  }

  Future<List<Map<String, dynamic>>> retrievePets() async {
    Database db = await instance.database;
    return await db.query('pets');
  }

  Future<int> updatePet(int id, String name) async {
    Database db = await instance.database;
    return await db.update('pets', {'name': name},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePet(int id) async {
    Database db = await instance.database;
    return await db.delete('pets', where: 'id = ?', whereArgs: [id]);
  }
}

class SelectPage extends StatefulWidget {
  const SelectPage({Key? key}) : super(key: key);

  @override
  _SelectPageState createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  late DatabaseHelper _databaseHelper;
  List<Map<String, dynamic>> _petList = [];
  final TextEditingController _petNameController = TextEditingController();
  bool _isAddingPet = false;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper.instance;
    loadPetList();
  }

  void loadPetList() async {
    List<Map<String, dynamic>> pets = await _databaseHelper.retrievePets();
    setState(() {
      _petList = pets;
    });
  }

  void addPet(String petName) async {
    await _databaseHelper.insertPet(petName);
    loadPetList();
    setState(() {
      _isAddingPet = false;
    });
  }

  void updatePetName(int id, String newName) async {
    await _databaseHelper.updatePet(id, newName);
    loadPetList();
  }

  void deletePet(int id) async {
    await _databaseHelper.deletePet(id);
    loadPetList();
  }

  void navigateToHomePage(BuildContext context, int petId, String selectedPet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(petId: petId, selectedPet: selectedPet),
      ),
    );
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
              itemCount: _petList.length * 2,
              itemBuilder: (BuildContext context, int index) {
                if (index.isOdd) {
                  return const Divider(
                    color: Colors.grey,
                    height: 20,
                    thickness: 1,
                  );
                }
                int petIndex = index ~/ 2;
                int petId = _petList[petIndex]['id'];
                String petName = _petList[petIndex]['name'];
                return ListTile(
                  title: Text(petName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditDialog(context, petId, petName);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteDialog(context, petId);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    navigateToHomePage(context, petId, petName);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, int petId, String currentName) {
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
                updatePetName(petId, newName);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, int petId) {
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
                deletePet(petId);
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
