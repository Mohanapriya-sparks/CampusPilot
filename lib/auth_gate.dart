import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/opportunity_explorer_screen.dart';
import 'state/app_state.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final user = authSnapshot.data;
        if (user == null) return const LoginScreen();

        return FutureBuilder<void>(
          future: AppState.instance.loadForUser(user.uid),
          builder: (context, stateSnapshot) {
            if (stateSnapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            return AnimatedBuilder(
              animation: AppState.instance,
              builder: (context, _) {
                return const OpportunityExplorerScreen();
              },
            );
          },
        );
      },
    );
  }
}
