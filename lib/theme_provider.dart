import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode'; 
  ThemeMode _themeMode = ThemeMode.system; 
  ThemeMode get themeMode => _themeMode; 

  bool get isDarkMode{
    if (_themeMode == ThemeMode.system){
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }


  Future<void> init() async{
    final prefs = await SharedPreferences.getInstance(); 
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme != null){
      switch (savedTheme){
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark': 
          _themeMode = ThemeMode.dark; 
          break;
        case 'system': 
          _themeMode = ThemeMode.system; 
          break;
      }
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async{
    _themeMode = mode; 
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    String modeString; 

    switch (mode){
      case ThemeMode.light:
        modeString = 'light';
        break;

      case ThemeMode.dark: 
        modeString = 'dark'; 
        break; 
      
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    await prefs.setString(_themeKey, modeString); 
  }

  Future<void> toggleTheme() async{
    if(_themeMode == ThemeMode.dark){
      await setThemeMode(ThemeMode.light);
    } else{
      await setThemeMode(ThemeMode.dark);
    }
  }

}