import 'package:flutter/material.dart';
import 'package:moodly/theme/app_themes.dart';

enum AppTheme {
  indigoNights,
  hippieBlue,
  redWine,
  greenForest,
  mangoMojito,
}

ThemeData getThemeData(AppTheme theme, bool isDarkMode) {
  switch (theme) {
    case AppTheme.indigoNights:
      return isDarkMode ? IndigoNights.dark : IndigoNights.light;
    case AppTheme.hippieBlue:
      return isDarkMode ? HippieBlue.dark : HippieBlue.light;
    case AppTheme.redWine:
      return isDarkMode ? RedWine.dark : RedWine.light;
    case AppTheme.greenForest:
      return isDarkMode ? GreenForest.dark : GreenForest.light;
    case AppTheme.mangoMojito:
      return isDarkMode ? MangoMojito.dark : MangoMojito.light;
  }
}

