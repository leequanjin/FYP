import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moodly/pages/auth/login_page.dart';
import 'package:moodly/pages/auth/profile_page.dart';
import 'package:moodly/utils/auth_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void popPage(BuildContext context) {
    Navigator.pop(context);
  }

  void logout(BuildContext context) async {
    try {
      await authService.value.signOut();
      popPage(context);
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  Future<bool?> showLogoutConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
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
              onTap: () {},
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
            SettingsTile(
              icon: Icons.login,
              title: 'Sign In',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
            SettingsTile(
              icon: Icons.login,
              title: 'Logout',
              onTap: () async {
                {
                  bool? confirmLogout = await showLogoutConfirmation(context);
                  if (confirmLogout == true) {
                    logout(context);
                  }
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
