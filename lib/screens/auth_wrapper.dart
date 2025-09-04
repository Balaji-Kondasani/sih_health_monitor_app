import 'package:flutter/material.dart';
import 'package:sih_health_monitor_app/screens/login_screen.dart';
import 'package:sih_health_monitor_app/screens/role_redirector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Supabase.instance.client.auth.onAuthStateChange provides a stream of auth events.
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // While waiting for the initial auth state, show a loading indicator.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;

        // If the user has a valid session (is logged in), show the RoleRedirector.
        if (session != null) {
          return const RoleRedirector();
        }

        // Otherwise, if the user is logged out, show the LoginScreen.
        return const LoginScreen();
      },
    );
  }
}

