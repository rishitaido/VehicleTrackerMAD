import 'package:sqflite/sqflite.dart';
import 'db.dart';
import 'models.dart';

class VehiclesRepo{
  final Database db = DB.instance.db;

  //Get Vehicles
  Future<List<Vehicle>> getAll() async{
    final maps = await db.query(
      'vehicles', 
      orderBy: 'updatedAT DESC', 
    ); 
    return maps.map((map) => Vehicle.fromMap(map)).toList(); 
  }

  Future<Vehicle?> getById(int id) async{
    final maps = await db.query(
      'vehicles', 
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null; 
    return Vehicle.fromMap(maps.first); 
  }

  Future<int> add(Vehicle vehicle) async{ 
    final id = await db.insert(
      'vehicles', 
      vehicle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    ); 
    print('Vehicle added: ${vehicle.nickname} (ID: $id)'); 
    return id;
  }

  Future<int> update(Vehicle vehicle) async{
    if(vehicle.id == null) {
      throw Exception('Cannot Update vehicle without ID');
    }

    final updatedVehicle = vehicle.copyWith(updatedAt: DateTime.now()); 
    final count = await db.update(
      'vehicles', 
      updatedVehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );

    return count; 
  }

   // Delete vehicle
  Future<int> delete(int id) async {
    final count = await db.delete(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
    );
    print('✅ Vehicle deleted (ID: $id)');
    return count;
  }
  
  // Get vehicle count
  Future<int> count() async {
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM vehicles');
    return Sqflite.firstIntValue(result) ?? 0;
  }
  
  // Search vehicles by nickname, make, or model
  Future<List<Vehicle>> search(String query) async {
    final searchQuery = '%$query%';
    final maps = await db.query(
      'vehicles',
      where: 'nickname LIKE ? OR make LIKE ? OR model LIKE ?',
      whereArgs: [searchQuery, searchQuery, searchQuery],
      orderBy: 'updatedAt DESC',
    );
    return maps.map((map) => Vehicle.fromMap(map)).toList();
  }
}

class MaintenanceRepo{
  final Database db = DB.instance.db; 

  Future<List<MaintenanceLog>> getForVehicle(int vehicleId) async{
    final maps = await db.query(
      'maintenance_logs',
      where:'vehicleId = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => MaintenanceLog.fromMap(map)).toList();
  }

  Future<int> add(MaintenanceLog log) async{
    return await db.insert('maintenance_logs', log.toMap());
  }

  Future<int> update(MaintenanceLog log) async{
    return await db.update(
      'maintenance_logs',
      log.toMap(),
      where: 'id=?',
      whereArgs: [log.id]
    );
  }
  
  Future<int> delete(int id) async{
    return await db.delete(
      'maintenance_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  //Get Total Maintenance Count for Vehicle
  Future<int> getCountForVehicle(int vehicleId) async{
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM maintenance_logs WHERE vehicleId = ?',
      [vehicleId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  //Get total cost for vehicle
  Future<double> getTotalCostForVehicle(int vehicleId) async{
    final result = await db.rawQuery(
      'SELECT sum(cost) as total FROM maintenance_logs WHERE vehicleId = ?',
      [vehicleId],
    );
    final value = result.first['total']; 
    if (value == null) return 0.0; 
    return (value as num).toDouble(); 
  }
}

class RemindersRepo{
  final Database db = DB.instance.db;

  Future<List<Reminder>> getActive() async{
    final maps = await db.query(
      'reminders',
      where: 'isCompleted = ?',
      whereArgs: [0],
      orderBy: 'dueDate ASC',
    );
    return maps.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<List<Reminder>> getForVehicle(int vehicleId) async{
    final maps = await db.query(
      'reminders',
      where: 'vehicleId = ? AND isCompleted = ?',
      whereArgs: [vehicleId, 0],
      orderBy: 'dueDate ASC', 
    );
    return maps.map((map) => Reminder.fromMap(map)).toList(); 
  }

  Future<int> add(Reminder reminder) async{
    return await db.insert('reminders', reminder.toMap());
  }

  Future<int> complete(int id) async{
    return await db.update(
      'reminders',
      {
        'isCompleted' : 1,
        'completedAt' : DateTime.now().toString(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async{
    return await db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}