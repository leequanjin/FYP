import 'package:flutter/material.dart';
import 'package:moodly/pages/settings/auth/auth_app_bar.dart';
import 'package:moodly/theme/theme_config.dart';
import 'package:moodly/theme/theme_provider.dart';
import 'package:moodly/utils/auth_service.dart';
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
      body: FutureBuilder<bool>(
        future: authService.value.checkSubscriptionStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final isPremium = snapshot.data ?? false;

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: AppTheme.values.map((theme) {
                  final themeData = getThemeData(theme, isDarkMode);
                  final isSelected = themeProvider.selectedTheme == theme;

                  final isLocked = !isPremium &&
                      (theme == AppTheme.redWine ||
                          theme == AppTheme.greenForest ||
                          theme == AppTheme.mangoMojito);

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
                      color: isLocked
                          ? Theme.of(context)
                          .disabledColor
                          .withValues(alpha: 0.05)
                          : Theme.of(context).colorScheme.surface,
                    ),
                    child: ListTile(
                      title: Text(
                        themeName(theme),
                        style: TextStyle(
                          color: isLocked
                              ? Theme.of(context).disabledColor
                              : null,
                        ),
                      ),
                      leading: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: themeData.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? themeData.colorScheme.primary
                                : themeData.colorScheme.primaryContainer,
                            width: 1,
                          ),
                        ),
                        child: isLocked
                            ? const Icon(Icons.lock, size: 16, color: Colors.grey)
                            : null,
                      ),
                      trailing: isSelected && !isLocked
                          ? const Icon(Icons.check)
                          : null,
                      onTap: isLocked
                          ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'This theme is for premium users only.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                          : () => themeProvider.setTheme(theme),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
