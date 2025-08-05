import 'package:flutter/material.dart';
import 'package:moodly/pages/settings/auth/auth_app_bar.dart';
import 'package:moodly/pages/settings/auth/auth_layout.dart';
import 'package:moodly/utils/auth_service.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  bool _isPasswordVisible = false;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }

  void deleteAccount() async {
    try {
      await authService.value.deleteAccount(
        email: _controllerEmail.text.trim(),
        password: _controllerPassword.text.trim(),
      );
      showSnackBarSuccess();
      pushReplacementPage();
    } catch (e) {
      showSnackBarFailure();
    }
  }

  void pushReplacementPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthLayout()),
    );
  }

  void showSnackBarSuccess() async {
    ScaffoldMessenger.of(context).clearMaterialBanners();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Account deleted successfully.'),
        duration: Duration(seconds: 1),
        showCloseIcon: true,
      ),
    );

    await Future.delayed(const Duration(seconds: 1));

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  void showSnackBarFailure() {
    ScaffoldMessenger.of(context).clearMaterialBanners();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: const Text('Delete account failed.'),
        showCloseIcon: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(titleText: 'Delete Account'),
      body: SafeArea(
        child: Container(
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Center(
            child: Card(
              color: Theme.of(context).colorScheme.surface,
              elevation: 8,
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 350),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_forever,
                              size: 100,
                              color: Theme.of(context).colorScheme.error),
                          _gap(),
                          Text(
                            "Delete Account",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Enter your email and password to confirm account deletion.",
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          _gap(),
                          TextFormField(
                            controller: _controllerEmail,
                            validator: (value) {
                              final trimmed = value?.trim() ?? '';
                              if (trimmed.isEmpty) {
                                return 'Please enter your email';
                              }
                              final emailRegex = RegExp(
                                r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$",
                              );
                              if (!emailRegex.hasMatch(trimmed)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          _gap(),
                          TextFormField(
                            controller: _controllerPassword,
                            obscureText: !_isPasswordVisible,
                            validator: (value) {
                              final trimmed = value?.trim() ?? '';
                              if (trimmed.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (trimmed.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon:
                              const Icon(Icons.lock_outline_rounded),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                          _gap(),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                Theme.of(context).colorScheme.error,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  deleteAccount();
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  'Delete Account',
                                  style: TextStyle(
                                    color:
                                    Theme.of(context).colorScheme.onError,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}
