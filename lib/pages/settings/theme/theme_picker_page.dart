import 'package:flutter/material.dart';
import 'package:moodly/pages/settings/auth/auth_app_bar.dart';
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
      appBar: AuthAppBar(titleText: 'Themes'),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: AppTheme.values.map((theme) {
              final themeData = getThemeData(theme, isDarkMode);
              final isSelected = themeProvider.selectedTheme == theme;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? themeData.colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: ListTile(
                  title: Text(themeName(theme)),
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: themeData.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? themeData.colorScheme.primary : themeData.colorScheme.primaryContainer,
                        width: 1,
                      ),
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () => themeProvider.setTheme(theme),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );

  }
}
