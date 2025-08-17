import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:moodly/pages/settings/auth/auth_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinput/pinput.dart';

class LockPage extends StatefulWidget {
  const LockPage({super.key});

  @override
  State<LockPage> createState() => _LockPageState();
}

class _LockPageState extends State<LockPage> {
  bool _appLockEnabled = false;
  bool _biometricEnabled = false;
  String? _savedPin;
  final LocalAuthentication auth = LocalAuthentication();
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _appLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
      _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      _savedPin = prefs.getString('user_pin');
    });
  }

  Future<void> _createPin() async {
    final prefs = await SharedPreferences.getInstance();
    String? newPin;
    String? confirmPin;
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceBright,
          title: const Center(child: Text("Set PIN")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "PIN is required to enable App Lock",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),

              const Text("Enter new PIN"),
              const SizedBox(height: 12),
              Pinput(
                length: 4,
                obscureText: true,
                controller: newPinController,
                onChanged: (value) => newPin = value,
              ),

              const SizedBox(height: 20),
              const Divider(),

              const Text("Confirm new PIN"),
              const SizedBox(height: 12),
              Pinput(
                length: 4,
                obscureText: true,
                controller: confirmPinController,
                onChanged: (value) => confirmPin = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (newPin != null &&
                    confirmPin != null &&
                    newPin == confirmPin &&
                    newPin!.isNotEmpty) {
                  prefs.setString('user_pin', newPin!);
                  setState(() {
                    _savedPin = newPin;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("PIN set successfully")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("PINs do not match"),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleAppLock(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value) {
      final pin = prefs.getString('user_pin');
      if (pin == null || pin.isEmpty) {
        await _createPin();

        final newPin = prefs.getString('user_pin');
        if (newPin == null || newPin.isEmpty) {
          return;
        }
      }
    }

    await prefs.setBool('app_lock_enabled', value);

    setState(() {
      _appLockEnabled = value;
      if (!value) {
        _biometricEnabled = false;
        prefs.setBool('biometric_enabled', false);
      }
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    if (!_appLockEnabled) return;
    final prefs = await SharedPreferences.getInstance();

    if (value) {
      bool canCheck = await auth.canCheckBiometrics;
      if (!canCheck) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No biometric available on this device"),
          ),
        );
        return;
      }
    }

    await prefs.setBool('biometric_enabled', value);
    setState(() {
      _biometricEnabled = value;
    });
  }

  Future<void> _savePin() async {
    if (!_appLockEnabled) return;

    if (_pinController.text.length != 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("PIN must be 4 digits")));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pin', _pinController.text);
    setState(() {
      _savedPin = _pinController.text;
    });

    _pinController.clear();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("PIN saved successfully")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(titleText: 'App Lock'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              SwitchListTile(
                title: const Text("Enable App Lock"),
                value: _appLockEnabled,
                onChanged: _toggleAppLock,
              ),
              const Divider(height: 30),

              Opacity(
                opacity: _appLockEnabled ? 1.0 : 0.5,
                child: IgnorePointer(
                  ignoring: !_appLockEnabled,
                  child: Column(
                    children: [
                      const Text(
                        "Set your PIN",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: Pinput(
                          controller: _pinController,
                          length: 4,
                          obscureText: false,
                          autofocus: false,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                                width: 1,
                              ),
                            ),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surface,
                          ),
                          onPressed: _savePin,
                          child: Text(
                            _savedPin == null ? "Save PIN" : "Change PIN",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const Divider(height: 20),

              Opacity(
                opacity: _appLockEnabled ? 1.0 : 0.5,
                child: IgnorePointer(
                  ignoring: !_appLockEnabled,
                  child: SwitchListTile(
                    title: const Text("Enable Biometric Login"),
                    value: _biometricEnabled,
                    onChanged: _toggleBiometric,
                  ),
                ),
              ),

              const Divider(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
