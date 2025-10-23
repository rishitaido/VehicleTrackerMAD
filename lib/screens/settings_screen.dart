import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Get current theme mode
  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;
  
  @override
  Widget build(BuildContext context) {
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
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          SwitchListTile(
            secondary: Icon(
              _isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            title: const Text('Dark Mode'),
            subtitle: Text(
              _isDarkMode ? 'Using dark theme' : 'Using light theme',
            ),
            value: _isDarkMode,
            onChanged: (value) {
              // Theme switching will be implemented later, currently follows system theme
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Theme currently follows system settings. '
                    'Manual toggle coming soon!',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),

          const Divider(),
          
          // Data Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Data',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Export maintenance logs to CSV'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('CSV export - Optional feature'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Database'),
            subtitle: const Text('Create a backup of your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backup - Optional feature'),
                ),
              );
            },
          ),
          const Divider(),
          
          // About Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'About',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Vehicle Maintenance Tracker v1.0'),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Documentation'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Vehicle Tracker',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.directions_car, size: 48),
                children: [
                  const Text(
                    'Track your vehicle maintenance, set reminders, '
                    'and never miss a service date!',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
