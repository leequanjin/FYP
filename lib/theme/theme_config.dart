import 'package:flutter/material.dart';
import 'package:moodly/theme/app_themes.dart';

enum AppTheme { indigoNights, hippieBlue }

ThemeData getThemeData(AppTheme theme, bool isDarkMode) {
  switch (theme) {
    case AppTheme.indigoNights:
      return isDarkMode ? IndigoNights.dark : IndigoNights.light;
    case AppTheme.hippieBlue:
      return isDarkMode ? HippieBlue.dark : HippieBlue.light;
  }
}

