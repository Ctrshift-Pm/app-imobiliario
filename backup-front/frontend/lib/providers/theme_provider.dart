import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  // Carrega o tema guardado na memória do dispositivo ao iniciar a app.
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Lê a preferência; se não existir, usa 'system' como padrão.
    final theme = prefs.getString('theme') ?? 'system';
    if (theme == 'light') {
      _themeMode = ThemeMode.light;
    } else if (theme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners(); // Notifica a UI para se redesenhar com o tema correto.
  }

  // Altera e guarda a nova preferência de tema.
  void setTheme(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    
    _themeMode = themeMode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    String themeString = 'system';
    if (themeMode == ThemeMode.light) {
      themeString = 'light';
    } else if (themeMode == ThemeMode.dark) {
      themeString = 'dark';
    }
    await prefs.setString('theme', themeString);
  }
}