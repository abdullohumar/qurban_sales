import 'package:path/path.dart';
import 'package:qurban_sales/models/sale.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Membuat instance singleton (agar koneksi database hanya satu dari seluruh aplikasi)
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kambing.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Membuat table saat aplikasi pertama kali dijalankan
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE sales (
        id $idType,
        nomor $textType,
        nama $textType,
        noHp $textType,
        alamat $textType,
        createdAt $textType
      )
''');
  }

  // Create
  Future<int> create(Sale sale) async {
    final db = await instance.database;
    return await db.insert('sales', sale.toMap());
  }

  // Read (ALl Data)
  Future<List<Sale>> realAllSales() async {
    final db = await instance.database;
    final orderBy = 'createdAt DESC';
    final result = await db.query('sales', orderBy: orderBy);

    return result.map((json) => Sale.fromMap(json)).toList();
  }

  // Update
  Future<int> update(Sale sale) async {
    final db = await instance.database;
    return db.update(
      'sales',
      sale.toMap(),
      where: 'id = ?',
      whereArgs: [sale.id],
    );
  }

  // Delete
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'sales', 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }
}
