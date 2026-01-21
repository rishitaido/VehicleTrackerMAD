import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../repos.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _vehiclesRepo = VehiclesRepo();
  final _maintenanceRepo = MaintenanceRepo();
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Theme Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
    
          RadioListTile<ThemeMode>(
            secondary: const Icon(Icons.light_mode),
            title: const Text('Light Mode'),
            subtitle: const Text('Always use light theme'),
            value: ThemeMode.light,
            groupValue: themeProvider.themeMode,
            onChanged: (value) {
              if (value != null) {
                themeProvider.setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            subtitle: const Text('Always use dark theme'),
            value: ThemeMode.dark,
            groupValue: themeProvider.themeMode,
            onChanged: (value) {
              if (value != null) {
                themeProvider.setThemeMode(value);
              }
            },
          ),
          
          const Divider(),
          
          // Data Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Data',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Statistics'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showStatistics(context),
          ),
          
          const Divider(),
          
          // About Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'About',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: const Text('Vehicle Maintenance Tracker v1.1.0'),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Documentation'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Vehicle Tracker',
                applicationVersion: '1.1.0',
                applicationIcon: const Icon(Icons.directions_car, size: 48),
                children: const [
                  Text(
                    'Track your vehicle maintenance, set reminders, '
                    'and never miss a service date!\n\n'
                    'Features:\n'
                    '• Vehicle management\n'
                    '• Maintenance logs\n'
                    '• Analytics Dashboard\n'
                    '• Automatic reminders\n'
                    '• Light/Dark themes',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
  
  Future<void> _showStatistics(BuildContext context) async {
    try {
      final vehicles = await _vehiclesRepo.getAll();
      
      int totalVehicles = vehicles.length;
      int totalLogs = 0;
      double totalCost = 0;
      int totalMileage = 0;
      
      for (var vehicle in vehicles) {
        final logs = await _maintenanceRepo.getForVehicle(vehicle.id!);
        totalLogs += logs.length;
        totalCost += await _maintenanceRepo.getTotalCostForVehicle(vehicle.id!);
        totalMileage += vehicle.currentMileage;
      }
      
      if (!context.mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('App Statistics'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatRow(
                icon: Icons.directions_car,
                label: 'Total Vehicles',
                value: totalVehicles.toString(),
              ),
              const SizedBox(height: 12),
              _StatRow(
                icon: Icons.build,
                label: 'Total Services',
                value: totalLogs.toString(),
              ),
              const SizedBox(height: 12),
              _StatRow(
                icon: Icons.attach_money,
                label: 'Total Spent',
                value: NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(totalCost),
              ),
              const SizedBox(height: 12),
              _StatRow(
                icon: Icons.speed,
                label: 'Total Mileage',
                value: '${NumberFormat('#,###').format(totalMileage)} mi',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading statistics: $e')),
      );
    }
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}