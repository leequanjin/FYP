import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moodly/pages/bottom_nav/bottom_nav_page.dart';
import 'package:moodly/theme/theme_provider.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:local_auth/local_auth.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();
  // await deleteDatabase(await getDatabasesPath().then((path) => '$path/master_db.db'));
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final TextEditingController controller = TextEditingController();
  String? savedPin;
  bool biometricAvailable = false;
  bool biometricEnabled = false;
  bool isLoading = false;
  String? pinError;
  bool appLockEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? pin = prefs.getString('user_pin');
    bool enabled = prefs.getBool('biometric_enabled') ?? false;
    bool lockEnabled = prefs.getBool('app_lock_enabled') ?? false;
    bool available = false;

    try {
      available = await auth.canCheckBiometrics;
    } catch (_) {}

    setState(() {
      savedPin = pin;
      biometricEnabled = enabled;
      appLockEnabled = lockEnabled;
      biometricAvailable = available && enabled;
    });

    if (!appLockEnabled) {
      _navigateToSecondScreen();
      return;
    }

    if (biometricAvailable) {
      _biometricAuthentication();
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text('Enter PIN', style: TextStyle(fontSize: 28)),
              const SizedBox(height: 10),
              Text(
                savedPin == null
                    ? 'No PIN set. Please go to settings.'
                    : 'Please enter your 4-digit PIN to continue',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              if (savedPin != null)
                Column(
                  children: [
                    Pinput(
                      controller: controller,
                      length: 4,
                      onCompleted: _onCompleted,
                      obscureText: true,
                      autofocus: true,
                    ),
                    if (pinError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        pinError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              const Spacer(),
              if (biometricAvailable) ...[
                const Text('or', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                InkWell(
                  onTap: isLoading ? null : _biometricAuthentication,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(strokeWidth: 2)
                        : Icon(Icons.fingerprint, size: 32, color: Theme.of(context).colorScheme.primary,),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Use biometric', style: TextStyle(fontSize: 18)),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _onCompleted(String enteredPin) {
    if (enteredPin == savedPin) {
      setState(() => pinError = null);
      _navigateToSecondScreen();
    } else {
      setState(() {
        pinError = "Incorrect PIN. Try again.";
      });
      controller.clear();
    }
  }

  void _navigateToSecondScreen() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => BottomNavPage()));
  }

  Future<void> _biometricAuthentication() async {
    if (!biometricAvailable) return;

    setState(() => isLoading = true);

    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to continue',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        _navigateToSecondScreen();
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }
}
