import 'package:flutter/material.dart';
import 'package:moodly/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class AuthAppBar extends AppBar {
  AuthAppBar({super.key, required String titleText})
    : super(
        title: Text(titleText),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return IconButton(
                  onPressed: () {
                    themeProvider.toggleDarkMode();
                  },
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  ),
                );
              },
            ),
          ),
        ],
      );
}
