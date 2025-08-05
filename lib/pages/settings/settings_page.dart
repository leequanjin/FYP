import 'package:flutter/material.dart';
import 'package:moodly/pages/settings/auth/login_page.dart';
import 'package:moodly/pages/settings/auth/profile_page.dart';
import 'package:moodly/pages/settings/theme/theme_picker_page.dart';
import 'package:moodly/utils/auth_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void popPage(BuildContext context) {
    Navigator.pop(context);
  }

  void logout(BuildContext context) async {
    try {
      await authService.value.signOut();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Logged out successfully")),
        );
        popPage(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Logout failed: $e")),
        );
      }
    }
  }

  Future<bool?> showLogoutConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.value.currentUser;

    return ListView(
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Text('GENERAL', style: Theme.of(context).textTheme.labelLarge),
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          context,
          tiles: [
            SettingsTile(
              icon: Icons.person_outlined,
              title: 'Profile',
              subtitle: 'View & Edit Personal Information',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfilePage(),
                  ),
                );
              },
            ),
            SettingsTile(
              icon: Icons.workspace_premium_outlined,
              title: 'Subscription',
              subtitle: 'Purchase Subscription Plan',
              onTap: () {},
            ),
            SettingsTile(
              icon: Icons.color_lens_outlined,
              title: 'Themes',
              subtitle: 'Customize Color Themes',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ThemePickerPage()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Text('SUPPORT', style: Theme.of(context).textTheme.labelLarge),
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          context,
          tiles: [
            SettingsTile(
              icon: Icons.mail_outline,
              title: 'Contact',
              onTap: () {},
            ),
            SettingsTile(
              icon: Icons.feedback_outlined,
              title: 'Feedback',
              onTap: () {},
            ),
            SettingsTile(
              icon: Icons.info_outline,
              title: 'About Us',
              onTap: () {},
            ),
            if (user == null)
              SettingsTile(
                icon: Icons.login,
                title: 'Sign In',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
              ),
            if (user != null)
              SettingsTile(
                icon: Icons.logout,
                title: 'Logout',
                onTap: () async {
                  bool? confirmLogout = await showLogoutConfirmation(context);
                  if (confirmLogout == true) {
                    logout(context);
                  }
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard(
      BuildContext context, {
        required List<SettingsTile> tiles,
      }) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        children: List.generate(tiles.length * 2 - 1, (index) {
          if (index.isEven) {
            return tiles[index ~/ 2];
          } else {
            return Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
              indent: 8,
              endIndent: 8,
            );
          }
        }),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall)
          : null,
      onTap: onTap,
    );
  }
}
