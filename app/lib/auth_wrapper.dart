import 'package:app/models/user.dart' as AppUser;
import 'package:app/pages/admin.dart';
import 'package:app/pages/home.dart';
import 'package:app/pages/login.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserAuthProvider>(context);

    return StreamBuilder<User?>(
      stream: authProvider.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // No user signed in -> go to login
        if (!snapshot.hasData) {
          return const Login();
        }

        // User signed in -> load profile once
        final uid = snapshot.data!.uid;
        final futureProfile = authProvider.getProfile(uid);

        return FutureBuilder<AppUser.AppUser?>(
          future: futureProfile,
          builder: (context, profileSnap) {
            if (profileSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!profileSnap.hasData) {
              return const Login();
            }

            final userProfile = profileSnap.data!;
            if (userProfile.type == "admin") {
              return AdminScreen();
            } else {
              print("returning home screen");
              return HomeScreen();
            }
          },
        );
      },
    );
  }
}
