import 'package:flutter/material.dart';

// Service types for maintenance
enum ServiceType {
  oilChange,
  tireRotation,
  brakeService,
  inspection,
  batteryReplacement,
  airFilter,
  other;

  String get label {
    switch (this) {
      case ServiceType.oilChange:
        return 'Oil Change';
      case ServiceType.tireRotation:
        return 'Tire Rotation';
      case ServiceType.brakeService:
        return 'Brake Service';
      case ServiceType.inspection:
        return 'Inspection';
      case ServiceType.batteryReplacement:
        return 'Battery Replacement';
      case ServiceType.airFilter:
        return 'Air Filter';
      case ServiceType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ServiceType.oilChange:
        return Icons.opacity;
      case ServiceType.tireRotation:
        return Icons.tire_repair;
      case ServiceType.brakeService:
        return Icons.front_hand;
      case ServiceType.inspection:
        return Icons.search;
      case ServiceType.batteryReplacement:
        return Icons.battery_charging_full;
      case ServiceType.airFilter:
        return Icons.air;
      case ServiceType.other:
        return Icons.build;
    }
  }
}

// Vehicle model
class Vehicle {
  final int? id;
  final String nickname;
  final String make;
  final String model;
  final int year;
  final int currentMileage;
  final String? vin;
  final String? licensePlate;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    this.id,
    required this.nickname,
    required this.make,
    required this.model,
    required this.year,
    required this.currentMileage,
    this.vin,
    this.licensePlate,
    this.imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert to map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'make': make,
      'model': model,
      'year': year,
      'currentMileage': currentMileage,
      'vin': vin,
      'licensePlate': licensePlate,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from database map
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as int?,
      nickname: map['nickname'] as String,
      make: map['make'] as String,
      model: map['model'] as String,
      year: map['year'] as int,
      currentMileage: map['currentMileage'] as int,
      vin: map['vin'] as String?,
      licensePlate: map['licensePlate'] as String?,
      imagePath: map['imagePath'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  // Create a copy with updated fields
  Vehicle copyWith({
    int? id,
    String? nickname,
    String? make,
    String? model,
    int? year,
    int? currentMileage,
    String? vin,
    String? licensePlate,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      currentMileage: currentMileage ?? this.currentMileage,
      vin: vin ?? this.vin,
      licensePlate: licensePlate ?? this.licensePlate,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Vehicle(id: $id, nickname: $nickname, $year $make $model)';
  }
}

// Maintenance log model
class MaintenanceLog {
  final int? id;
  final int vehicleId;
  final ServiceType type;
  final DateTime date;
  final int mileage;
  final double cost;
  final String? notes;
  final String? receiptImagePath;
  final DateTime createdAt;

  MaintenanceLog({
    this.id,
    required this.vehicleId,
    required this.type,
    required this.date,
    required this.mileage,
    required this.cost,
    this.notes,
    this.receiptImagePath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'type': type.name,
      'date': date.toIso8601String(),
      'mileage': mileage,
      'cost': cost,
      'notes': notes,
      'receiptImagePath': receiptImagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from database map
  factory MaintenanceLog.fromMap(Map<String, dynamic> map) {
    return MaintenanceLog(
      id: map['id'] as int?,
      vehicleId: map['vehicleId'] as int,
      type: ServiceType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ServiceType.other,
      ),
      date: DateTime.parse(map['date'] as String),
      mileage: map['mileage'] as int,
      cost: map['cost'] as double,
      notes: map['notes'] as String?,
      receiptImagePath: map['receiptImagePath'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // Create a copy with updated fields
  MaintenanceLog copyWith({
    int? id,
    int? vehicleId,
    ServiceType? type,
    DateTime? date,
    int? mileage,
    double? cost,
    String? notes,
    String? receiptImagePath,
    DateTime? createdAt,
  }) {
    return MaintenanceLog(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      date: date ?? this.date,
      mileage: mileage ?? this.mileage,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'MaintenanceLog(id: $id, type: ${type.label}, date: $date, cost: \$$cost)';
  }
}

// Reminder model
class Reminder {
  final int? id;
  final int vehicleId;
  final ServiceType type;
  final DateTime? dueDate;
  final int? dueMileage;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  Reminder({
    this.id,
    required this.vehicleId,
    required this.type,
    this.dueDate,
    this.dueMileage,
    this.isCompleted = false,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'type': type.name,
      'dueDate': dueDate?.toIso8601String(),
      'dueMileage': dueMileage,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  // Create from database map
  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int?,
      vehicleId: map['vehicleId'] as int,
      type: ServiceType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ServiceType.other,
      ),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
      dueMileage: map['dueMileage'] as int?,
      isCompleted: (map['isCompleted'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt'] as String) : null,
    );
  }

  // Create a copy with updated fields
  Reminder copyWith({
    int? id,
    int? vehicleId,
    ServiceType? type,
    DateTime? dueDate,
    int? dueMileage,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      dueMileage: dueMileage ?? this.dueMileage,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() {
    return 'Reminder(id: $id, type: ${type.label}, dueDate: $dueDate, completed: $isCompleted)';
  }
}