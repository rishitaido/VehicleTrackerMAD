import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utility/widgets.dart';
import '../repos.dart';
import '../models.dart';
import '../utility/notification_service.dart';
import '../utility/reminder_helper.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final _remindersRepo = RemindersRepo();
  final _vehiclesRepo = VehiclesRepo();
  final _reminderEngine = ReminderEngine();
  final _notificationService = NotificationService();
  
  bool _isLoading = false;
  List<Reminder> _reminders = [];
  Map<int, Vehicle> _vehicles = {}; // vehicleId -> Vehicle
  
  // Filtered lists
  List<Reminder> _overdueReminders = [];
  List<Reminder> _dueSoonReminders = [];
  List<Reminder> _upcomingReminders = [];
  
  @override
  void initState() {
    super.initState();
    _notificationService.requestPermissions();
    _loadReminders();
  }
  
  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    
    try {
      // Load all active reminders
      _reminders = await _remindersRepo.getActive();
      
      // Load vehicles for all reminders
      final vehicleIds = _reminders.map((r) => r.vehicleId).toSet();
      for (var vehicleId in vehicleIds) {
        final vehicle = await _vehiclesRepo.getById(vehicleId);
        if (vehicle != null) {
          _vehicles[vehicleId] = vehicle;
        }
      }
      
      // Categorize reminders
      _categorizeReminders();
    } catch (e) {
      print('Error loading reminders: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reminders: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _categorizeReminders() {
    _overdueReminders = [];
    _dueSoonReminders = [];
    _upcomingReminders = [];
    
    for (var reminder in _reminders) {
      final vehicle = _vehicles[reminder.vehicleId];
      if (vehicle == null) continue;
      
      final status = ReminderEngine.getStatus(reminder, vehicle);
      switch (status) {
        case ReminderStatus.overdue:
          _overdueReminders.add(reminder);
          break;
        case ReminderStatus.dueSoon:
          _dueSoonReminders.add(reminder);
          break;
        case ReminderStatus.upcoming:
          _upcomingReminders.add(reminder);
          break;
        case ReminderStatus.completed:
          // Skip completed
          break;
      }
    }
  }
  
  Future<void> _completeReminder(Reminder reminder) async {
    final vehicle = _vehicles[reminder.vehicleId];
    if (vehicle == null) return;
    
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Complete Reminder',
      message: 'Mark this ${reminder.type.label} reminder as complete and create a new reminder for the next service?',
      confirmLabel: 'Complete',
    );
    
    if (confirmed) {
      try {
        await _reminderEngine.completeReminder(reminder, vehicle);
        _loadReminders();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder completed! New reminder created.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error completing reminder: $e')),
          );
        }
      }
    }
  }
  
  Future<void> _deleteReminder(Reminder reminder) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Reminder',
      message: 'Delete this ${reminder.type.label} reminder?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    
      if (confirmed && reminder.id != null) {
        try {
          await _notificationService.cancelReminder(reminder.id!);
          await _remindersRepo.delete(reminder.id!);
        _loadReminders();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting reminder: $e')),
          );
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          if (_reminders.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_reminders.length} active',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_reminders.isEmpty) {
      return const EmptyState(
        icon: Icons.notifications_none,
        message: 'No Active Reminders',
        subtitle: 'Add maintenance logs to automatically create reminders',
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadReminders,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overdue section
          if (_overdueReminders.isNotEmpty) ...[
            _SectionHeader(
              title: 'Overdue',
              count: _overdueReminders.length,
              color: Colors.red,
            ),
            ..._overdueReminders.map((reminder) {
              return _ReminderCard(
                reminder: reminder,
                vehicle: _vehicles[reminder.vehicleId],
                status: ReminderStatus.overdue,
                onComplete: () => _completeReminder(reminder),
                onDelete: () => _deleteReminder(reminder),
              );
            }),
            const SizedBox(height: 24),
          ],
          
          // Due soon section
          if (_dueSoonReminders.isNotEmpty) ...[
            _SectionHeader(
              title: 'Due Soon',
              count: _dueSoonReminders.length,
              color: Colors.orange,
            ),
            ..._dueSoonReminders.map((reminder) {
              return _ReminderCard(
                reminder: reminder,
                vehicle: _vehicles[reminder.vehicleId],
                status: ReminderStatus.dueSoon,
                onComplete: () => _completeReminder(reminder),
                onDelete: () => _deleteReminder(reminder),
              );
            }),
            const SizedBox(height: 24),
          ],
          
          // Upcoming section
          if (_upcomingReminders.isNotEmpty) ...[
            _SectionHeader(
              title: 'Upcoming',
              count: _upcomingReminders.length,
              color: Colors.blue,
            ),
            ..._upcomingReminders.map((reminder) {
              return _ReminderCard(
                reminder: reminder,
                vehicle: _vehicles[reminder.vehicleId],
                status: ReminderStatus.upcoming,
                onComplete: () => _completeReminder(reminder),
                onDelete: () => _deleteReminder(reminder),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final Vehicle? vehicle;
  final ReminderStatus status;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  
  const _ReminderCard({
    required this.reminder,
    required this.vehicle,
    required this.status,
    required this.onComplete,
    required this.onDelete,
  });
  
  Color get _statusColor {
    switch (status) {
      case ReminderStatus.overdue:
        return Colors.red;
      case ReminderStatus.dueSoon:
        return Colors.orange;
      case ReminderStatus.upcoming:
        return Colors.blue;
      case ReminderStatus.completed:
        return Colors.green;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (vehicle == null) return const SizedBox.shrink();
    
    final dateFormat = DateFormat.yMMMd();
    final mileageFormat = NumberFormat('#,###');
    
    final daysUntilDue = ReminderEngine.getDaysUntilDue(reminder);
    final milesUntilDue = ReminderEngine.getMilesUntilDue(reminder, vehicle!);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    reminder.type.icon,
                    color: _statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.type.label,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        vehicle!.nickname,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'complete',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 20, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Mark Complete'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'complete') onComplete();
                    if (value == 'delete') onDelete();
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            
            // Due date info
            Row(
              children: [
                if (reminder.dueDate != null) ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              'Due Date',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(reminder.dueDate!),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (daysUntilDue != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            daysUntilDue < 0
                                ? '${-daysUntilDue} days overdue'
                                : 'in $daysUntilDue days',
                            style: TextStyle(
                              color: _statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (reminder.dueMileage != null) ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.speed, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              'Due Mileage',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${mileageFormat.format(reminder.dueMileage!)} mi',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (milesUntilDue != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            milesUntilDue < 0
                                ? '${mileageFormat.format(-milesUntilDue)} mi overdue'
                                : 'in ${mileageFormat.format(milesUntilDue)} mi',
                            style: TextStyle(
                              color: _statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
            
            // Complete button
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onComplete,
                icon: const Icon(Icons.check_circle),
                label: const Text('Mark Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}