import 'package:flutter/material.dart';
import 'package:moodly/theme/theme_config.dart';

class ThemeProvider with ChangeNotifier {
  AppTheme _selectedTheme = AppTheme.indigoNights;
  bool _isDarkMode = false;

  AppTheme get selectedTheme => _selectedTheme;
  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData => getThemeData(_selectedTheme, _isDarkMode);

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setTheme(AppTheme theme) {
    _selectedTheme = theme;
    notifyListeners();
  }
}
