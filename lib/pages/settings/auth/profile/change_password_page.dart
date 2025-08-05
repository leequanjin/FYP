import 'package:flutter/material.dart';
import 'package:moodly/pages/settings/auth/auth_app_bar.dart';
import 'package:moodly/utils/auth_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool _isPasswordVisible = false;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerCurrentPassword =
      TextEditingController();
  final TextEditingController _controllerNewPassword = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerCurrentPassword.dispose();
    _controllerNewPassword.dispose();
    super.dispose();
  }

  void updatePassword() async {
    try {
      if (_controllerCurrentPassword.text.trim() ==
          _controllerNewPassword.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Current Password & New Password cannot be the same.',
            ),
            showCloseIcon: true,
          ),
        );
      } else {
        await authService.value.resetPasswordFromCurrentPassword(
          email: _controllerEmail.text.trim(),
          currentPassword: _controllerCurrentPassword.text.trim(),
          newPassword: _controllerNewPassword.text.trim(),
        );
        showSnackBarSuccess();
      }
    } catch (e) {
      showSnackBarFailure();
    }
  }

  void showSnackBarSuccess() async {
    ScaffoldMessenger.of(context).clearMaterialBanners();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Password changed successfully.'),
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
        content: const Text('Password change failed.'),
        showCloseIcon: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(titleText: 'Change Password'),
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
                          Icon(
                            Icons.password_outlined,
                            size: 100,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          _gap(),
                          Text(
                            "Change Password",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Enter your current and new credentials below.",
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          _gap(),
                          TextFormField(
                            controller: _controllerEmail,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Please enter your email';
                              final isValid = RegExp(
                                r"^[a-zA-Z0-9._%+-]+@[a-zA-Z]+\.[a-zA-Z]+",
                              ).hasMatch(value);
                              return isValid
                                  ? null
                                  : 'Please enter a valid email';
                            },
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: const OutlineInputBorder(),
                              fillColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainer,
                            ),
                          ),
                          _gap(),
                          TextFormField(
                            controller: _controllerCurrentPassword,
                            obscureText: !_isPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Please enter your current password';
                              if (value.length < 6)
                                return 'Password must be at least 6 characters';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Current Password',
                              hintText: 'Enter your current password',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              border: const OutlineInputBorder(),
                              fillColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainer,
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
                          TextFormField(
                            controller: _controllerNewPassword,
                            obscureText: !_isPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Please enter your new password';
                              if (value.length < 6)
                                return 'Password must be at least 6 characters';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              hintText: 'Enter your new password',
                              prefixIcon: const Icon(Icons.lock_reset_rounded),
                              border: const OutlineInputBorder(),
                              fillColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainer,
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  updatePassword();
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  'Change Password',
                                  style: TextStyle(
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
