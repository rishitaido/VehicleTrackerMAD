import '/models.dart';
import '/repos.dart';

// Reminder engine for calculating due dates and creating reminders
class ReminderEngine {
  final _remindersRepo = RemindersRepo();
  
  // Service intervals in miles
  static const Map<ServiceType, int> mileageIntervals = {
    ServiceType.oilChange: 5000,
    ServiceType.tireRotation: 7500,
    ServiceType.brakeService: 30000,
    ServiceType.inspection: 12000,
    ServiceType.batteryReplacement: 50000,
    ServiceType.airFilter: 15000,
    ServiceType.other: 10000,
  };
  
  // Service intervals in months
  static const Map<ServiceType, int> timeIntervals = {
    ServiceType.oilChange: 6,
    ServiceType.tireRotation: 6,
    ServiceType.brakeService: 24,
    ServiceType.inspection: 12,
    ServiceType.batteryReplacement: 48,
    ServiceType.airFilter: 12,
    ServiceType.other: 12,
  };
  
  // Create reminder after maintenance
  Future<void> createReminderAfterMaintenance(
    MaintenanceLog log,
    Vehicle vehicle,
  ) async {
    final mileageInterval = mileageIntervals[log.type] ?? 10000;
    final timeInterval = timeIntervals[log.type] ?? 12;
    
    final dueMileage = log.mileage + mileageInterval;
    final dueDate = log.date.add(Duration(days: timeInterval * 30));
    
    final reminder = Reminder(
      vehicleId: log.vehicleId,
      type: log.type,
      dueMileage: dueMileage,
      dueDate: dueDate,
      isCompleted: false,
    );
    
    await _remindersRepo.add(reminder);
    
    print('Reminder created: ${log.type.label} due at $dueMileage miles or $dueDate');
  }
  
  // Check if reminder is due soon (within 500 miles or 30 days)
  static bool isDueSoon(Reminder reminder, Vehicle vehicle) {
    if (reminder.isCompleted) return false;
    
    // Check mileage
    if (reminder.dueMileage != null) {
      final mileageUntilDue = reminder.dueMileage! - vehicle.currentMileage;
      if (mileageUntilDue <= 500 && mileageUntilDue > 0) {
        return true;
      }
    }
    
    // Check date
    if (reminder.dueDate != null) {
      final now = DateTime.now();
      final daysUntilDue = reminder.dueDate!.difference(now).inDays;
      if (daysUntilDue <= 30 && daysUntilDue > 0) {
        return true;
      }
    }
    
    return false;
  }
  
  // Check if reminder is overdue
  static bool isOverdue(Reminder reminder, Vehicle vehicle) {
    if (reminder.isCompleted) return false;
    
    // Check mileage
    if (reminder.dueMileage != null) {
      if (vehicle.currentMileage >= reminder.dueMileage!) {
        return true;
      }
    }
    
    // Check date
    if (reminder.dueDate != null) {
      if (DateTime.now().isAfter(reminder.dueDate!)) {
        return true;
      }
    }
    
    return false;
  }
  
  // Get reminder status
  static ReminderStatus getStatus(Reminder reminder, Vehicle vehicle) {
    if (reminder.isCompleted) return ReminderStatus.completed;
    if (isOverdue(reminder, vehicle)) return ReminderStatus.overdue;
    if (isDueSoon(reminder, vehicle)) return ReminderStatus.dueSoon;
    return ReminderStatus.upcoming;
  }
  
  // Get days until due (negative if overdue)
  static int? getDaysUntilDue(Reminder reminder) {
    if (reminder.dueDate == null) return null;
    return reminder.dueDate!.difference(DateTime.now()).inDays;
  }
  
  // Get miles until due (negative if overdue)
  static int? getMilesUntilDue(Reminder reminder, Vehicle vehicle) {
    if (reminder.dueMileage == null) return null;
    return reminder.dueMileage! - vehicle.currentMileage;
  }
  
  // Mark reminder as complete and create new reminder
  Future<void> completeReminder(
    Reminder reminder,
    Vehicle vehicle,
  ) async {
    // Mark current reminder as complete
    await _remindersRepo.complete(reminder.id!);
    
    // Create new reminder for next service
    final mileageInterval = mileageIntervals[reminder.type] ?? 10000;
    final timeInterval = timeIntervals[reminder.type] ?? 12;
    
    final dueMileage = vehicle.currentMileage + mileageInterval;
    final dueDate = DateTime.now().add(Duration(days: timeInterval * 30));
    
    final newReminder = Reminder(
      vehicleId: reminder.vehicleId,
      type: reminder.type,
      dueMileage: dueMileage,
      dueDate: dueDate,
      isCompleted: false,
    );
    
    await _remindersRepo.add(newReminder);
    
    print('Reminder completed and new reminder created');
  }
}

// Reminder status enum
enum ReminderStatus {
  upcoming,
  dueSoon,
  overdue,
  completed;
  
  String get label {
    switch (this) {
      case ReminderStatus.upcoming:
        return 'Upcoming';
      case ReminderStatus.dueSoon:
        return 'Due Soon';
      case ReminderStatus.overdue:
        return 'Overdue';
      case ReminderStatus.completed:
        return 'Completed';
    }
  }
}