import 'package:flutter/material.dart';
import 'package:moodly/theme/theme_config.dart';
import 'package:moodly/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemePickerPage extends StatelessWidget {
  const ThemePickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    String themeName(AppTheme theme) {
      switch (theme) {
        case AppTheme.indigoNights:
          return 'Indigo Nights';
        case AppTheme.hippieBlue:
          return 'Hippie Blue';
        case AppTheme.redWine:
          return 'Red Wine';
        case AppTheme.greenForest:
          return 'Green Forest';
        case AppTheme.mangoMojito:
          return 'Mango Mojito';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Picker'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () => themeProvider.toggleDarkMode(),
          ),
        ],
      ),
      body: ListView(
        children: AppTheme.values.map((theme) {
          final themeData = getThemeData(theme, isDarkMode);
          final isSelected = themeProvider.selectedTheme == theme;

          return ListTile(
            title: Text(themeName(theme)),
            leading: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: themeData.colorScheme.primaryContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey,
                  width: isSelected ? 2 : 1,
                ),
              ),
            ),
            trailing: isSelected ? const Icon(Icons.check) : null,
            onTap: () => themeProvider.setTheme(theme),
          );
        }).toList(),
      )
    );
  }
}
