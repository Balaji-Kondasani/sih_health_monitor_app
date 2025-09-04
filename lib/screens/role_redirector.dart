import 'package:flutter/material.dart';
import 'package:sih_health_monitor_app/screens/dashboard_screen.dart';
import 'package:sih_health_monitor_app/screens/home_screen.dart';
import 'package:sih_health_monitor_app/screens/login_screen.dart';
import 'package:sih_health_monitor_app/services/supabase_service.dart';

class RoleRedirector extends StatefulWidget {
  const RoleRedirector({super.key});

  @override
  State<RoleRedirector> createState() => _RoleRedirectorState();
}

class _RoleRedirectorState extends State<RoleRedirector> {
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _redirectUser();
  }

  Future<void> _redirectUser({int attempt = 1}) async {

    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final profile = await _supabaseService.getCurrentUserProfile();

      if (mounted) {
        if (profile != null) {
          // Profile found, proceed with navigation
          if (profile.role == 'OFFICIAL') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          } else {
            // Default to ASHA_WORKER screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        } else {
          // --- THE FIX ---
          // Profile not found yet. If we have tried less than 3 times,
          // wait 2 seconds and try again.
          if (attempt < 3) {
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) {
              _redirectUser(attempt: attempt + 1); // Retry the check
            }
          } else {
            // We have retried and still failed, so navigate to login.
            _navigateToLogin("Failed to load user profile. Please try again.");
          }
        }
      }
    } catch (e) {
      // Handle any other errors during profile fetch by sending the user to login.
      if (mounted) {
        _navigateToLogin("An error occurred. Please log in again.");
      }
    }
  }

  void _navigateToLogin(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while the redirection logic runs.
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

