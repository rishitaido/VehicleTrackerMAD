import 'package:flutter/material.dart';
import '../utility/widgets.dart';

class GarageScreen extends StatefulWidget {
  const GarageScreen({super.key});

  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  bool _isLoading = false;

  final List<Map<String, dynamic>> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() => _isLoading = false);
  }

  Future<void> _navigateToAddVehicle() async {
    final result = await Navigator.pushNamed(context, '/vehicle-form');
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
      return EmptyState(
        icon: Icons.directions_car,
        message: 'No Vehicles Yet',
        subtitle: 'Add your first vehicle to start tracking maintenance',
        actionLabel: 'Add Vehicle',
        onAction: _navigateToAddVehicle,
      );
    }

    // Still need to implement vehicle list
    return RefreshIndicator(
      onRefresh: _loadVehicles,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = _vehicles[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.directions_car, size: 40),
              title: Text(vehicle['nickname'] ?? 'Vehicle'),
              subtitle: Text('${vehicle['year']} ${vehicle['make']} ${vehicle['model']}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Will implement navigation later
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vehicle detail!')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}