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
