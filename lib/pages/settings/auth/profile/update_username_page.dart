import 'package:flutter/material.dart';
import 'package:moodly/pages/settings/auth/auth_app_bar.dart';
import 'package:moodly/utils/auth_service.dart';

class UpdateUsernamePage extends StatefulWidget {
  const UpdateUsernamePage({super.key});

  @override
  State<UpdateUsernamePage> createState() => _UpdateUsernamePageState();
}

class _UpdateUsernamePageState extends State<UpdateUsernamePage> {
  final TextEditingController _controllerUsername = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controllerUsername.dispose();
    super.dispose();
  }

  void updateUsername() async {
    try {
      final newUsername = _controllerUsername.text.trim();
      await authService.value.updateUsername(username: newUsername);
      showSnackBarSuccess();
      if (mounted) Navigator.pop(context);

    } catch (e) {
      showSnackBarFailure();
    }
  }

  void showSnackBarSuccess() {
    ScaffoldMessenger.of(context).clearMaterialBanners();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Username changed successfully.'),
        showCloseIcon: true,
      ),
    );
  }

  void showSnackBarFailure() {
    ScaffoldMessenger.of(context).clearMaterialBanners();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: const Text('Username change failed.'),
        showCloseIcon: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(titleText: 'Update Username'),
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
                          Icon(Icons.account_circle, size: 100, color: Theme.of(context).colorScheme.primary),
                          _gap(),
                          Text(
                            "Update Username",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Enter your new username below.",
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          _gap(),
                          TextFormField(
                            controller: _controllerUsername,
                            validator: (value) {
                              final trimmedValue = value?.trim() ?? '';

                              if (trimmedValue.isEmpty) {
                                return 'Please enter a username';
                              }
                              if (trimmedValue.length < 2) {
                                return 'Username must be at least 2 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Username',
                              hintText: 'Enter your new username',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: const OutlineInputBorder(),
                              fillColor: Theme.of(context).colorScheme.surfaceContainer,
                            ),
                          ),
                          _gap(),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  updateUsername();
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  'Update',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
