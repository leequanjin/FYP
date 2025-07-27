import 'package:flutter/material.dart';
import 'package:moodly/pages/bottom_nav/bottom_nav_page.dart';
import 'package:moodly/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await deleteDatabase(await getDatabasesPath().then((path) => '$path/master_db.db'));
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moodly',
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const BottomNavPage(),
    );
  }
}
