import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets.dart';
import '../repos.dart';
import '../models.dart';

class MaintenanceListScreen extends StatefulWidget {
  const MaintenanceListScreen({super.key});

  @override
  State<MaintenanceListScreen> createState() => _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends State<MaintenanceListScreen> {
  final _maintenanceRepo = MaintenanceRepo();
  final _vehiclesRepo = VehiclesRepo();
  
  bool _isLoading = false;
  Vehicle? _vehicle;
  List<MaintenanceLog> _logs = [];
  
  int? _vehicleId;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get vehicle ID from arguments
    if (_vehicleId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        _vehicleId = args;
        _loadData();
      }
    }
  }
  
  Future<void> _loadData() async {
    if (_vehicleId == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      _vehicle = await _vehiclesRepo.getById(_vehicleId!);
      _logs = await _maintenanceRepo.getForVehicle(_vehicleId!);
    } catch (e) {
      print('Error loading maintenance: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading maintenance: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _navigateToAddMaintenance() async {
    final result = await Navigator.pushNamed(
      context,
      '/maintenance-form',
      arguments: {'vehicleId': _vehicleId},
    );
    if (result == true) {
      _loadData();
    }
  }
  
  Future<void> _navigateToEditMaintenance(MaintenanceLog log) async {
    final result = await Navigator.pushNamed(
      context,
      '/maintenance-form',
      arguments: {'vehicleId': _vehicleId, 'log': log},
    );
    if (result == true) {
      _loadData();
    }
  }
  
  Future<void> _confirmDelete(MaintenanceLog log) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Maintenance Log',
      message: 'Delete this ${log.type.label} log from ${DateFormat.yMMMd().format(log.date)}?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    
    if (confirmed && log.id != null) {
      try {
        await _maintenanceRepo.delete(log.id!);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maintenance log deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting log: $e')),
          );
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final vehicleName = _vehicle?.nickname ?? 'Vehicle';
    
    return Scaffold(
      appBar: AppBar(
        title: Text('$vehicleName Maintenance'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddMaintenance,
        icon: const Icon(Icons.add),
        label: const Text('Add Maintenance'),
      ),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_vehicle == null) {
      return const EmptyState(
        icon: Icons.error_outline,
        message: 'Vehicle Not Found',
        subtitle: 'Could not load vehicle information',
      );
    }
    
    if (_logs.isEmpty) {
      return EmptyState(
        icon: Icons.build,
        message: 'No Maintenance Logs',
        subtitle: 'Add your first maintenance log to start tracking',
        actionLabel: 'Add Maintenance',
        onAction: _navigateToAddMaintenance,
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _logs.length,
        itemBuilder: (context, index) {
          final log = _logs[index];
          return _MaintenanceCard(
            log: log,
            onTap: () => _navigateToEditMaintenance(log),
            onDelete: () => _confirmDelete(log),
          );
        },
      ),
    );
  }
}

class _MaintenanceCard extends StatelessWidget {
  final MaintenanceLog log;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  
  const _MaintenanceCard({
    required this.log,
    required this.onTap,
    required this.onDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final mileageFormat = NumberFormat('#,###');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Service icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      log.type.icon,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Service type and date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.type.label,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          dateFormat.format(log.date),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              
              // Details row
              Row(
                children: [
                  Expanded(
                    child: _DetailItem(
                      icon: Icons.speed,
                      label: 'Mileage',
                      value: '${mileageFormat.format(log.mileage)} mi',
                    ),
                  ),
                  Expanded(
                    child: _DetailItem(
                      icon: Icons.attach_money,
                      label: 'Cost',
                      value: currencyFormat.format(log.cost),
                    ),
                  ),
                ],
              ),
              
              // Notes
              if (log.notes != null && log.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.note, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          log.notes!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  
  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}