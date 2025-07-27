import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moodly/pages/auth/app_loading_page.dart';
import 'package:moodly/pages/auth/login_page.dart';
import 'package:moodly/pages/bottom_nav/bottom_nav_page.dart';
import 'package:moodly/utils/auth_service.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, this.pageIfNotConnected});

  final Widget? pageIfNotConnected;

  Future<bool> _isUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc.exists && userDoc.data()?['role'] == 'user';
  }

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
              return pageIfNotConnected ?? const LoginPage();
            }

            return FutureBuilder<bool>(
              future: _isUserRole(),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoadingPage();
                }

                if (roleSnapshot.data == true) {
                  return const BottomNavPage();
                } else {
                  return pageIfNotConnected ?? const LoginPage();
                }
              },
            );
          },
        );
      },
    );
  }
}
