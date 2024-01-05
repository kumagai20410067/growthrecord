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
    print('Database Path: $path'); // データベースファイルのパスを出力
    return await openDatabase(path,
        version: 4, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pet_id INTEGER,
        date TEXT,
        weight REAL,
        height REAL,
        memo TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // 既存のテーブルを削除
      await db.execute('DROP TABLE IF EXISTS records');
      // 新しいテーブルを作成
      await _onCreate(db, newVersion);
    }
  }

  Future<int> insertData(
      int petId, String date, double weight, double height, String memo) async {
    Database db = await instance.database;
    return await db.insert('records', {
      'pet_id': petId,
      'date': date,
      'weight': weight,
      'height': height,
      'memo': memo,
    });
  }

  Future<List<Map<String, dynamic>>> retrieveData(
      int petId, String date) async {
    Database db = await instance.database;
    print('Retrieve Date: $date'); // 追加
    return await db.query('records',
        where: 'pet_id = ? AND date = ?', whereArgs: [petId, date]);
  }

  Future<int> updateData(
      int id, double weight, double height, String memo) async {
    Database db = await instance.database;
    return await db.update(
        'records',
        {
          'weight': weight,
          'height': height,
          'memo': memo,
        },
        where: 'id = ?',
        whereArgs: [id]);
  }

  Future<int> deleteData(int id) async {
    Database db = await instance.database;
    return await db.delete('records', where: 'id = ?', whereArgs: [id]);
  }
}
