import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "AutomicHabitDB.db";
  static const _databaseVersion = 3;

  static const frequencyTable = 'frequency_table';
  static const habitsTable = 'habits_table';

  // Frequency Table - _id/frequency
  // Habits Table - _id/habit/priority/date/frequency

  static const columnId = '_id';
  static const columnHabit = 'habit';
  static const columnPriority = 'priority';
  static const columnDate = 'date';
  static const columnFrequency = 'frequency';

  late Database _db;

    Future<void> init() async {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, _databaseName);
      _db = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }

  Future _onCreate(Database database, int version) async {

    await database.execute('''
          CREATE TABLE $frequencyTable (
            $columnId INTEGER PRIMARY KEY,
            $columnFrequency TEXT
          )
          ''');

    await database.execute('''
          CREATE TABLE $habitsTable (
            $columnId INTEGER PRIMARY KEY,
            $columnHabit TEXT,
            $columnPriority TEXT,  
            $columnDate TEXT,
            $columnFrequency TEXT
          )
          ''');
  }

  _onUpgrade(Database database, int oldVersion, int newVersion) async{
    await database.execute('drop table $frequencyTable');
    await database.execute('drop table $habitsTable');
    _onCreate(database, newVersion);
  }

  Future<int> insert(Map<String, dynamic> row, String tableName) async {
    return await _db.insert(tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String tableName) async {
    return await _db.query(tableName);
  }

  Future<int> queryRowCount(String tableName) async {
    final results = await _db.rawQuery('SELECT COUNT(*) FROM $tableName');
    return Sqflite.firstIntValue(results) ?? 0;
  }

  Future<int> update(Map<String, dynamic> row, String tableName) async {
    int id = row[columnId];
    return await _db.update(
      tableName,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id, String tableName) async {
    return await _db.delete(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  readDataById(table, itemId) async{
    return await _db.query(table, where: "_id =? ",whereArgs: [itemId]);
  }

  // Read data from table by column name
  readDataByColumnName(table, columnName, columnValue) async{
    return await _db?.query(table, where: '$columnName =? ', whereArgs: [columnValue]);
  }
}