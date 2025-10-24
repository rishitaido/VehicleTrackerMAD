import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utility/widgets.dart';
import '../repos.dart';
import '../models.dart';

class GarageScreen extends StatefulWidget {
  const GarageScreen({super.key});

  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  final _vehiclesRepo = VehiclesRepo();
  final _maintenanceRepo = MaintenanceRepo();
  
  bool _isLoading = false;
  List<Vehicle> _vehicles = [];
  Map<int, int> _maintenanceCounts = {}; // vehicleId -> count
  Map<int, double> _totalCosts = {}; // vehicleId -> total cost
  
  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }
  
  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
    
    try {
      // Load vehicles
      _vehicles = await _vehiclesRepo.getAll();
      
      // Load maintenance counts and costs for each vehicle
      for (var vehicle in _vehicles) {
        if (vehicle.id != null) {
          _maintenanceCounts[vehicle.id!] = await _maintenanceRepo.getCountForVehicle(vehicle.id!);
          _totalCosts[vehicle.id!] = await _maintenanceRepo.getTotalCostForVehicle(vehicle.id!);
        }
      }
    } catch (e) {
      print('Error loading vehicles: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading vehicles: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _navigateToAddVehicle() async {
    final result = await Navigator.pushNamed(context, '/vehicle-form');
    if (result == true) {
      _loadVehicles();
    }
  }
  
  Future<void> _navigateToEditVehicle(Vehicle vehicle) async {
    final result = await Navigator.pushNamed(
      context,
      '/vehicle-form',
      arguments: vehicle,
    );
    if (result == true) {
      _loadVehicles();
    }
  }
  
  Future<void> _navigateToSettings() async {
    await Navigator.pushNamed(context, '/settings');
  }
  
  Future<void> _navigateToReminders() async {
    await Navigator.pushNamed(context, '/reminders');
  }
  
  Future<void> _navigateToMaintenanceList(Vehicle vehicle) async {
    await Navigator.pushNamed(
      context,
      '/maintenance-list',
      arguments: vehicle.id,
    );
    // Refresh data when returning
    _loadVehicles();
  }
  
  Future<void> _confirmDelete(Vehicle vehicle) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Vehicle',
      message: 'Delete "${vehicle.nickname}"?\n\nAll maintenance logs and reminders will also be deleted.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    
    if (confirmed && vehicle.id != null) {
      try {
        await _vehiclesRepo.delete(vehicle.id!);
        _loadVehicles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${vehicle.nickname} deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting vehicle: $e')),
          );
        }
      }
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Garage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: _navigateToReminders,
            tooltip: 'Reminders',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _navigateToSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddVehicle,
        icon: const Icon(Icons.add),
        label: const Text('Add Vehicle'),
      ),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_vehicles.isEmpty) {
      return EmptyState(
        icon: Icons.directions_car,
        message: 'No Vehicles Yet',
        subtitle: 'Add your first vehicle to start tracking maintenance',
        actionLabel: 'Add Vehicle',
        onAction: _navigateToAddVehicle,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVehicles,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = _vehicles[index];
          return _VehicleCard(
            vehicle: vehicle,
            maintenanceCount: _maintenanceCounts[vehicle.id] ?? 0,
            totalCost: _totalCosts[vehicle.id] ?? 0.0,
            onTap: () => _navigateToMaintenanceList(vehicle),
            onEdit: () => _navigateToEditVehicle(vehicle),
            onDelete: () => _confirmDelete(vehicle),
          );
        },
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final int maintenanceCount;
  final double totalCost;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VehicleCard({
    required this.vehicle,
    required this.maintenanceCount,
    required this.totalCost,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

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
                  // Icon
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.directions_car,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Vehicle info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.nickname,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Menu
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
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
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              // Stats row
              Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      icon: Icons.speed,
                      label: 'Mileage',
                      value: '${NumberFormat('#,###').format(vehicle.currentMileage)} mi',
                    ),
                  ),
                  Expanded(
                    child: _StatItem(
                      icon: Icons.build,
                      label: 'Services',
                      value: maintenanceCount.toString(),
                    ),
                  ),
                  Expanded(
                    child: _StatItem(
                      icon: Icons.attach_money,
                      label: 'Total Cost',
                      value: currencyFormat.format(totalCost),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}
