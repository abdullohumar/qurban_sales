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

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // Membuat table saat aplikasi pertama kali dijalankan
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT'; // New nullable type for weight & gender

    await db.execute('''
      CREATE TABLE sales (
        id $idType,
        nomor $textType,
        nama $textType,
        noHp $textType,
        alamat $textType,
        createdAt $textType,
        type $textType,
        price INTEGER NOT NULL DEFAULT 2500000,
        weight $textNullable,
        gender $textNullable
      )
''');
  }

  // Migration logic
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE sales ADD COLUMN type TEXT DEFAULT 'Akad Salam'",
      );
      await db.execute(
        "ALTER TABLE sales ADD COLUMN price INTEGER DEFAULT 2500000",
      );
    }
    if (oldVersion < 3) {
      await db.execute("ALTER TABLE sales ADD COLUMN weight TEXT");
    }
    if (oldVersion < 4) {
      await db.execute("ALTER TABLE sales ADD COLUMN gender TEXT");
    }
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
    return await db.delete('sales', where: 'id = ?', whereArgs: [id]);
  }
}
