import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'theme_provider.dart';
import 'screens/garage_screen.dart';
import 'screens/vehicle_form_screen.dart';
import 'screens/maintenance_list_screen.dart';
import 'screens/maintenance_form_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/settings_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider()..init(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Vehicle Tracker',
            debugShowCheckedModeBanner: false,
            
            // Theme configuration
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            
            // Route configuration
            initialRoute: '/',
            routes: {
              '/': (context) => const GarageScreen(),
              '/vehicle-form': (context) => const VehicleFormScreen(),
              '/maintenance-list': (context) => const MaintenanceListScreen(),
              '/maintenance-form': (context) => const MaintenanceFormScreen(),
              '/reminders': (context) => const RemindersScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}