import 'package:sqflite/sqflite.dart';

class User {
  final int id;
  final String username;
  final String password;

  User({required this.id, required this.username, required this.password});

  Map<String, dynamic> toMap() {
    return {'id': id, 'username': username, 'password': password};
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
    );
  }
}

class DatabaseHelper {
  static const _databaseName = 'liveBoard.db';
  static const _databaseVersion = 1;

  static const _tableName = 'users';
  static const _columnId = 'id';
  static const _columnUsername = 'username';
  static const _columnPassword = 'password';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, _databaseName);
    return await openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        $_columnId INTEGER PRIMARY KEY,
        $_columnUsername TEXT NOT NULL,
        $_columnPassword TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertUser(User user) async {
    final db = await instance.database;
    return await db.insert(_tableName, user.toMap());
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await instance.database;
    final result = await db.query(
      _tableName,
      where: '$_columnUsername = ?',
      whereArgs: [username],
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }
}
