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
    String path = join(await getDatabasesPath(), 'record_database.db');
    print('Database Path: $path');
    return await openDatabase(path,
        version: 6, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pet_id INTEGER,
        date TEXT,
        height REAL,
        weight REAL,
        memo TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 6) {}
  }

  Future<int> insertData(
      int petId, String date, double height, double weight, String memo) async {
    Database db = await instance.database;
    return await db.insert('records', {
      'pet_id': petId,
      'date': date,
      'height': height,
      'weight': weight,
      'memo': memo,
    });
  }

  Future<List<Map<String, dynamic>>> retrieveData(
      int petId, String date) async {
    Database db = await instance.database;
    print('Retrieve Date: $date');
    return await db.query('records',
        where: 'pet_id = ? AND date = ?', whereArgs: [petId, date]);
  }

  Future<int> updateData(
      int id, double height, double weight, String memo) async {
    Database db = await instance.database;
    return await db.update(
        'records',
        {
          'height': height,
          'weight': weight,
          'memo': memo,
        },
        where: 'id = ?',
        whereArgs: [id]);
  }

  Future<int> deleteData(int id) async {
    Database db = await instance.database;
    return await db.delete('records', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> retrieveMonthlyDataForGraph(
      int petId, String yearMonth) async {
    Database db = await instance.database;

    // データベースから指定された年月のデータを取得
    List<Map<String, dynamic>> data = await db.query(
      'records',
      where: 'pet_id = ? AND strftime(\'%Y-%m\', date) = ?',
      whereArgs: [petId, yearMonth],
      orderBy: 'date ASC',
    );

    print('Retrieved Graph Data for $yearMonth: $data');

    return data;
  }
}
