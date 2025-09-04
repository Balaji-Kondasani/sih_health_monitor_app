import 'package:flutter/material.dart';
import 'package:sih_health_monitor_app/screens/auth_wrapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// The main entry point for the application.
Future<void> main() async {
  // Ensure that the Flutter binding is initialized before calling Supabase.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with your project URL and anon key.
  // IMPORTANT: Replace these placeholder values with your actual Supabase credentials.
  await Supabase.initialize(
    url: 'https://xqjbccbciiafyuvizwvm.supabase.co', // <-- Find this in your Supabase project settings > API
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhxamJjY2JjaWlhZnl1dml6d3ZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY4OTc0MjYsImV4cCI6MjA3MjQ3MzQyNn0.FHTtfy7I9LmcRt9dgsvFq8yhW_M6wkUHpA3pUQ9ijXU', // <-- Find this in your Supabase project settings > API
  );

  // Run the main app widget.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Monitor',
      theme: ThemeData(
        // We use Colors.teal as the primary theme color for a professional, health-tech feel.
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      // The AuthWrapper is the first widget in our UI tree.
      // It will decide which screen to show based on the user's login status.
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

