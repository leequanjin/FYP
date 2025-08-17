import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moodly/pages/bottom_nav/bottom_nav_page.dart';
import 'package:moodly/pages/settings/auth/app_loading_page.dart';
import 'package:moodly/utils/auth_service.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, this.pageIfNotConnected});

  final Widget? pageIfNotConnected;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authService,
      builder: (context, authService, child) {
        return StreamBuilder<User?>(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppLoadingPage();
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const BottomNavPage();
            }

            return const BottomNavPage();
          },
        );
      },
    );
  }
}
