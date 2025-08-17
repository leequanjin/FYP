import 'package:flutter/material.dart';
import 'package:moodly/theme/theme_config.dart';
import 'package:moodly/utils/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  AppTheme _selectedTheme = AppTheme.indigoNights;
  bool _isDarkMode = false;

  AppTheme get selectedTheme => _selectedTheme;
  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData => getThemeData(_selectedTheme, _isDarkMode);

  ThemeProvider() {
    _loadPreferences();
  }

  static const List<AppTheme> premiumThemes = [
    AppTheme.redWine,
    AppTheme.greenForest,
    AppTheme.mangoMojito,
  ];

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _savePreferences();
    notifyListeners();
  }

  void setDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      _savePreferences();
      notifyListeners();
    }
  }

  void setTheme(AppTheme theme) {
    _selectedTheme = theme;
    _savePreferences();
    notifyListeners();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    final themeIndex = prefs.getInt('themeIndex') ?? AppTheme.indigoNights.index;
    AppTheme savedTheme = AppTheme.values[themeIndex];

    final isPremium = await authService.value.checkSubscriptionStatus();

    if (premiumThemes.contains(savedTheme) && !isPremium) {
      _selectedTheme = AppTheme.indigoNights;
      await prefs.setInt('themeIndex', _selectedTheme.index);
    } else {
      _selectedTheme = savedTheme;
    }

    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setInt('themeIndex', _selectedTheme.index);
  }
}
