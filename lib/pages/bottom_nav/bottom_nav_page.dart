import 'package:flutter/material.dart';
import 'package:moodly/pages/calendar/calendar_page.dart';
import 'package:moodly/pages/home/home_page.dart';
import 'package:moodly/pages/list/list_page.dart';
import 'package:moodly/pages/settings/settings_page.dart';
import 'package:moodly/pages/stats/stats_page.dart';
import 'package:moodly/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class BottomNavItem {
  final String title;
  final Widget page;

  const BottomNavItem({required this.title, required this.page});
}

class BottomNavPage extends StatefulWidget {
  const BottomNavPage({super.key});

  @override
  State<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  int _selectedIndex = 0;

  final List<BottomNavItem> _pages = const [
    BottomNavItem(title: "Home", page: HomePage()),
    BottomNavItem(title: "Calendar", page: CalendarPage()),
    BottomNavItem(title: "To-Do List", page: ListPage()),
    BottomNavItem(title: "Stats", page: StatsPage()),
    BottomNavItem(title: "Settings", page: SettingsPage()),
  ];

  void _onTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Icon(Icons.menu),
        ),
        title: Text(
          _pages[_selectedIndex].title,
        ),
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
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            child: _pages[_selectedIndex].page,
          ),
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onTap,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'To-Do List',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
