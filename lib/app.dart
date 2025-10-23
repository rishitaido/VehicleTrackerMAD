import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/garage_screen.dart';
import 'screens/vehicle_form_screen.dart';
import 'screens/maintenance_list_screen.dart';
import 'screens/maintenance_form_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/settings_screen.dart';

class MyApp extends StatelessWidget{
  const MyApp({super.key}); 
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Vehicle Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark, 
      themeMode: ThemeMode.system,

      initialRoute: '/',
      routes: {
        '/': (context) => GarageScreen(),
        '/vehicle-form': (context) => const VehicleFormScreen(),
        'Mantenance-list': (context) => const MaintenanceListScreen(),
        'reminders': (context) => RemindersScreen(), 
        'settings': (context) => SettingsScreen(),
      },
    );
  }
}