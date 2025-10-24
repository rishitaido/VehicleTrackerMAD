import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';

class DB{
  static final DB instance = DB._(); 
  DB._(); 

  Database? _db; 

  Future<void> init() async{
    if(_db != null) return; 

    final databasesPath = await getDatabasesPath(); 
    final path = join(databasesPath, 'vehicle_tracker.db'); 
    _db = await openDatabase(
      path,
      version: 1, 
      onCreate: _createSchema, 
      onConfigure: (db) async{
        await db.execute('PRAGMA foreign_keys = ON'); 
      },
    );

    debugPrint('DB initailized at: $path');
  }

  Future<void> _createSchema(Database db, int version) async{
    await db.execute(''' 
      CREATE TABLE vehicle( 
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        nickname TEXT NOT NULL, 
        make TEXT NOT NULL, 
        model TEXT NOT NULL, 
        year INTEGER NOT NULL, 
        currentMilage INTEGER NOT NULL, 
        vin TEXT, 
        licensePlate TEXT,
        imagePath TEXT, 
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
      ''');

    await db.execute('''
        CREATE TABLE maintenance_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId INTEGER NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL, 
        mileage INTEGER NOT NULL, 
        cost REAL NOT NULL, 
        notes TEXT,
        receiptImagePath TEXT, 
        createdAt TEXT NOT NULL, 
        FOREIGN KEY (vehicleId) REFERENCES vehicles(id) ON DELETE CASCADE
        )
      ''');

    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId INTEGER NOT NULL,
        type TEXT NOT NULL,
        dueDate TEXT,
        dueMileage INTEGER,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        completedAt TEXT,
        FOREIGN KEY (vehicleId) REFERENCES vehicles(id) ON DELETE CASCADE
      )
    ''');

    debugPrint('✅ Database schema created (v$version)');
  }
  //get DB instance
  Database get db{
    if(_db == null){
      throw Exception('Database not initialized. Call init() first.'); 
    }
    return _db!;
  }

  Future<void> close() async{
    await _db?.close(); 
    _db = null;
  }

  Future<void> deleteDatabase() async{ 
    final databasesPath = await getDatabasesPath(); 
    final path = join(databasesPath, 'vehicle_tracker.db'); 
    await databaseFactory.deleteDatabase(path); 
    _db = null; 
    debugPrint('DB Deleted');
  }


import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'model.dart';

class DB{
  static final DB instance = DB._(); 
  DB._(); 

  Database? _db; 

  Future<void> init() async{
    if(_db != null) return; 

    final databasesPath = await getDatabasesPath(); 
    final path = join(databasesPath, 'vehicle_tracker.db'); 
    _db = await openDatabase(
      path,
      version: 1, 
      onCreate: _createSchema, 
      onConfigure: (db) async{
        await db.execute('PRAGMA foreign_keys = ON'); 
      },
    );

    debugPrint('DB initailized at: $path');
  }

  Future<void> _createSchema(Database db, int version) async{
    await db.execute(''' 
      CREATE TABLE vehicle( 
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        nickname TEXT NOT NULL, 
        make TEXT NOT NULL, 
        model TEXT NOT NULL, 
        year INTEGER NOT NULL, 
        currentMilage INTEGER NOT NULL, 
        vin TEXT, 
        licensePlate TEXT,
        imagePath TEXT, 
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
      ''');

    await db.execute('''
        CREATE TABLE maintenance_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId INTEGER NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL, 
        mileage INTEGER NOT NULL, 
        cost REAL NOT NULL, 
        notes TEXT,
        receiptImagePath TEXT, 
        createdAt TEXT NOT NULL, 
        FOREGIN KEY (vehicleId) REFERENCES vehicles(id) ON DELETE CASCASE
        )
      ''');

    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId INTEGER NOT NULL,
        type TEXT NOT NULL,
        dueDate TEXT,
        dueMileage INTEGER,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        completedAt TEXT,
        FOREIGN KEY (vehicleId) REFERENCES vehicles(id) ON DELETE CASCADE
      )
    ''');

    debugPrint('✅ Database schema created (v$version)');
  }
  //get DB instance
  Database get db{
    if(_db == null){
      throw Exception('Database not initialized. Call init() first.'); 
    }
    return _db!;
  }

  Future<void> close() async{
    await _db?.close(); 
    _db = null;
  }

  Future<void> deleteDatabase() async{ 
    final databasesPath = await getDatabasesPath(); 
    final path = join(databasesPath, 'vehicle_tracker.db'); 
    await databaseFactory.deleteDatabase(path); 
    _db = null; 
    debugPrint('DB Deleted');
  }


}